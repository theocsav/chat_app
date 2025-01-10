import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // light mode
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
    );
  }
}