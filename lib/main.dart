import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api/api_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/utils.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/news/bloc/news_bloc.dart';
import 'features/news/repository/news_repository.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const UserFriendlyApp());
}

class UserFriendlyApp extends StatelessWidget {
  const UserFriendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthRepository(apiService))
            ..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => NewsBloc(NewsRepository(apiService)),
        ),
      ],
      child: MaterialApp(
        title: 'User Friendly',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          AppSizes.init(context);
          return child!;
        },
        // SplashScreen always shows first.
        // It reads AuthBloc state itself inside _navigate() after the
        // 3-second brand moment and pushes the correct screen.
        home: const SplashScreen(),
      ),
    );
  }
}