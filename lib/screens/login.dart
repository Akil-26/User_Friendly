import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Login flow is not configured yet.\n\nOpen Home to view your personalized news feed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
