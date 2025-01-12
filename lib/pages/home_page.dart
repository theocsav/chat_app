import 'package:flutter/material.dart';
import 'package:global_chat_app/components/user_tile.dart';
import 'package:global_chat_app/pages/chat_page.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import 'package:global_chat_app/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot){
        // error
        if (snapshot.hasError) {
          return const Text("Error"); 
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading...");
        }
        // return list view
        return ListView(
          children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
        );
      }
      );
  }

  // build individual list tile for user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    // display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          // tapped on a user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        }
      );
    } else {
      return Container();
    }
  }
}