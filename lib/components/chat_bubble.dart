import 'package:flutter/material.dart';
import 'package:global_chat_app/services/chat/chat_service.dart';
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String userID;
  final String timestamp;
  // language translation
  final String userTargetLanguage;
  final String chatCurrentLanguage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.userID,
    required this.timestamp,
    // language translation
    required this.userTargetLanguage,
    required this.chatCurrentLanguage,
    });

  // show options
  void _showOptions(BuildContext context, String messageID, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // report message button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report Message'),  
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageID, userID);
                },
              ),
              // block user button
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),  
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userID);                  
                },
              ),
              // cancel button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),  
                onTap: () => Navigator.pop(context),
              ),
            ],
          )
        );
      },
    );
  }

  // report message
  void _reportMessage(BuildContext context, String messageID, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report this message?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageID, userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Message reported"),
                )
              );
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  // block user
  void _blockUser(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block Message"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // block button
          TextButton(
            onPressed: () {
              // perform block
              ChatService().blockUser(userID);
              // dismiss dialog
              Navigator.pop(context);
              // dismiss page
              Navigator.pop(context);
              // let user know of the result
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User blocked"),
                )
              );
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No FutureBuilder for translation here; already handled in ChatPage
    final displayedMessage = message;

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // show options
          _showOptions(context, messageID, userID);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey.shade700,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 25),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(displayedMessage, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 2.0),
            Text(
              timestamp,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}