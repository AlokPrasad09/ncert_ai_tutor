import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const NCERTApp());
}

class NCERTApp extends StatelessWidget {
  const NCERTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NCERT AI Tutor",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}