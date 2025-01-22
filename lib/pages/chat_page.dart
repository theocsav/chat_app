import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_chat_app/components/chat_bubble.dart';
import 'package:global_chat_app/components/my_textfield.dart';
import 'package:global_chat_app/helpers/date_helper.dart';
import 'package:global_chat_app/services/auth/auth_service.dart';
import 'package:global_chat_app/services/chat/chat_service.dart';
import 'package:global_chat_app/services/chat/translation_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverID;
  const ChatPage({
    super.key,
    required this.receiverName,
    required this.receiverID,
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  // user and receiver languages
  String? _userLanguage;
  String? _receiverLanguage;

  // translation cache
  final Map<String, String> _translationCache = {};
  final Set<String> _inFlightTranslations = {}; // track ongoing translations
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());

    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // then the amount of remaining space will be calculated
        // then scroll down
        Future.delayed(const Duration(milliseconds: 500),
        () => scrollDown(),
        );
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(const Duration(milliseconds: 500),
    () => scrollDown(),
    );

    // Fetch each language once
    _chatService.getUserLanguage().then((val) {
      setState(() => _userLanguage = val);
    });
    _chatService.getUserLanguageById(widget.receiverID).then((val) {
      setState(() => _receiverLanguage = val);
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }
  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      // clear textfield
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    // Only show one loading indicator if languages aren’t ready
    if (_userLanguage == null || _receiverLanguage == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print("Debug: _userLanguage=$_userLanguage, _receiverLanguage=$_receiverLanguage");
    if (_userLanguage == _receiverLanguage) {
      print("Debug: Same languages, no translation needed");
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // display messages
          Expanded(child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    // ensure doc exists
    if (!doc.exists) {
      return Container(); // placeholder
    }
    // ensure doc.data() is not null
    final rawData = doc.data();
    if (rawData == null) {
      return Container(); // skip due to no data
    }

    final data = rawData as Map<String, dynamic>;
    if (!data.containsKey("timestamp") || data["timestamp"] == null) {
      return Container(); // no timestamp
    }

    final ts = data["timestamp"];
    if (ts is! Timestamp) {
      return Container(); // invalid timestamp
    }

    final String docID = doc.id;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align message to the right if sender is current user, otherwise left
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Just use the languages, since we know they're loaded
    String userLang = _userLanguage!;
    String receiverLang = _receiverLanguage!;
    bool shouldTranslate = !isCurrentUser && userLang != receiverLang;

    final originalMessage = data["message"] ?? "";
    // Immediately store the original message in cache if not present:
    _translationCache.putIfAbsent(docID, () => originalMessage);

    // If shouldTranslate and not yet translated
    if (shouldTranslate &&
        _translationCache[docID] == originalMessage &&
        !_inFlightTranslations.contains(docID)) {
      _inFlightTranslations.add(docID);
      TranslationService().translateText(
        text: originalMessage,
        currentLanguage: receiverLang,
        targetLanguage: userLang,
      ).then((translated) {
        _inFlightTranslations.remove(docID);
        if (translated != originalMessage) {
          setState(() {
            _translationCache[docID] = translated;
          });
        }
      });
    }

    if (!shouldTranslate) {
      print("Debug: Skipping translation for docID=$docID (same language or current user)");
    }

    // Use cached value, or fallback to original message
    final finalMessage = _translationCache[docID] ?? originalMessage;

    return _buildChatBubble(data, docID, isCurrentUser, finalMessage);
  }

  Widget _buildChatBubble(
    Map<String, dynamic> data,
    String docID,
    bool isCurrentUser,
    String finalMessage
  ) {
    final DateHelper dateHelper = DateHelper();
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: finalMessage,
            isCurrentUser: isCurrentUser,
            messageID: docID,
            userID: data["senderID"],
            timestamp: dateHelper.formatDatetime(data["timestamp"].toDate()),
            userTargetLanguage: _userLanguage!,
            chatCurrentLanguage: _receiverLanguage!,
          ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0, top: 25.0),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
              focusNode: myFocusNode,
            )
          ),
          
          // send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25.0),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                ),
            ),
          ),
        ],
      ),
    );
  }
}