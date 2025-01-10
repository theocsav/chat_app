import 'package:flutter/material.dart';
import 'package:global_chat_app/services/auth/auth_service.dart';
import 'package:global_chat_app/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

   void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // logo
              SizedBox(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // home list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("Home"),
                  leading: const Icon(Icons.home),
                  iconColor: Colors.grey,
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),
              // settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("Settings"),
                  leading: const Icon(Icons.settings),
                  iconColor: Colors.grey,
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);
                    
                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ]
          ),

          // logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              iconColor: Colors.grey,
              onTap: logout,
            ),
          ),

        ],
      ),
    );
  }
}