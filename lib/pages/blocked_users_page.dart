import 'package:flutter/material.dart';
import 'package:global_chat_app/components/user_tile.dart';
import 'package:global_chat_app/services/auth/auth_service.dart';
import 'package:global_chat_app/services/chat/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  // chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // show confirm unblock box
  void _showUnblockBox(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: const Text("Unblock User"),
        content: const Text("Are you sure you want to unblock this user?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")
          ),

          // unblock button
          TextButton(
            onPressed: () {
              _chatService.unblockUser(userID);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User unblocked")));
            },
            child: const Text("Unblock")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // get current user's id
    String userID = _authService.getCurrentUser()!.uid;
    // UI
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Blocked Users"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStream(userID),
        builder: (context, snapshot) {
          // errors
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading..."),
            );
          }
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final blockedUsers = snapshot.data ?? [];
          // no users
          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text("No blocked users"),
            );
          }
          // load complete 
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                name: user["name"],
                email: user["email"],
                onTap: () => _showUnblockBox(context, user["uid"]),
              );
            },
          );
        },
      ),
    );
  }
}