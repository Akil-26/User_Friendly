import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.configureBackgroundRefresh();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Friendly',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F766E),
      ),
      home: const HomeScreen(),
    );
  }
}
