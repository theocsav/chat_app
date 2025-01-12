import 'package:flutter/material.dart';
import 'package:global_chat_app/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String userID;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.userID,
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
                  
                },
              ),
              // cancel button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),  
                onTap: () {
                  
                },
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Message reported"),
              ));
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  // block user

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 25),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}