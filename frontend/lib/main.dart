import 'package:flutter/material.dart';
import 'pages/intro_page1.dart';
import 'pages/intro_page2.dart';
import 'pages/login_page.dart';   // ← pastikan ini ada

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
          case '/login':                                              // ← baru
            return MaterialPageRoute(builder: (_) => const LoginPage()); // ← baru
          default:
            return MaterialPageRoute(builder: (_) => const IntroPage1());
        }
      },
    );
  }
}