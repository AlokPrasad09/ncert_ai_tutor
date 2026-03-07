import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    checkLogin();
  }

  Future checkLogin() async {

    var token = await StorageService.getToken();

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (token != null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(token: token, email: ''),
        ),
      );

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.1).animate(controller),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[

              Image.asset(
                'assets/logo.png',
                width: 600,
                height: 600,
              ),

              SizedBox(height: 20),


            ],
          ),
        ),
      ),
    );
  }
}