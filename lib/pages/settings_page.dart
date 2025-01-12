import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_chat_app/pages/blocked_users_page.dart';
import 'package:global_chat_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // light mode
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Light Mode",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    
                    // switch toggle
                    CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(context, listen: false).isLightMode,
                      onChanged: (value) =>
                        Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(),
                      activeColor: Colors.blue,
                    )
                  ],
                ),
              ),
              // blocked users
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Blocked Users",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    
                    // Button to go to blocked users page
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlockedUsersPage()
                        )
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey,
                        ),
                    )
                  ],
                ),
              ),  
            ],
          ),
        ),
      ),
    );
  }
}