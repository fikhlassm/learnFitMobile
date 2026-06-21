import 'package:flutter/material.dart';
import 'pages/intro_page1.dart';
import 'pages/intro_page2.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/verification_page.dart';
import 'pages/welcome_page.dart';
import 'pages/forgot_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/intro1',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/intro1':
            return MaterialPageRoute(builder: (_) => const IntroPage1());
          case '/intro2':
            return MaterialPageRoute(builder: (_) => const IntroPage2());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegistrationPage());
          case '/verify':
            final email = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => VerificationPage(email: email),
            );
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomePage());
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
          default:
            return MaterialPageRoute(builder: (_) => const IntroPage1());
        }
      },
    );
  }
}