import 'package:global_chat_app/auth/auth_gate.dart';
import 'package:global_chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'themes/light_mode.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: lightMode,
      );
  }
} 