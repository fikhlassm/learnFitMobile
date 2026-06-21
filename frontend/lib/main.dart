import 'package:flutter/material.dart';
import 'pages/intro_page1.dart';
import 'pages/intro_page2.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/verification_page.dart';
import 'pages/welcome_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/quiz_page.dart';
import 'pages/quiz_result_page.dart';
import 'pages/home_page.dart';
import 'pages/new_note_sheet.dart';
import 'pages/pomodoro_session_page.dart';
import 'pages/feynman_session_page.dart';
import 'pages/blurting_session_page.dart';
import 'pages/active_recall_session_page.dart';
import 'pages/personal_information_page.dart';
import 'pages/study_reminders_page.dart';
import 'pages/support_center.dart';

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
          case '/quiz':
            return MaterialPageRoute(builder: (_) => const QuizPage());
          case '/quiz-result':
            final args = settings.arguments as Map<String, dynamic>?;
            final method = args?['method'] as String? ?? 'Pomodoro';
            final scores = (args?['scores'] as List?)?.cast<int>() ?? [0, 0, 0, 0];
            return MaterialPageRoute(
              builder: (_) => QuizResultPage(method: method, scores: scores),
            );
          case '/home':
            final args = settings.arguments as Map<String, dynamic>?;
            final initialIndex = args?['initialIndex'] as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => HomePage(initialIndex: initialIndex),
            );
          case '/new-note':
            final args = settings.arguments as Map<String, dynamic>?;
            final preselectedMethod = args?['preselectedMethod'] as String?;
            return MaterialPageRoute(
              builder: (_) => NewNoteSheet(preselectedMethod: preselectedMethod),
            );
          case '/pomodoro-session':
            final a = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PomodoroSessionPage(
                studySessionId: a?['studySessionId'] as int? ?? 0,
                topicTitle: a?['topicTitle'] as String? ?? 'Fungsi Eksponensial',
              ),
            );
          case '/feynman-session':
            final a = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => FeynmanSessionPage(
                topicTitle: a?['topicTitle'] as String? ?? 'Sejarah Majapahit',
              ),
            );
          case '/blurting-session':
            final a = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => BlurtingSessionPage(
                topicTitle: a?['topicTitle'] as String? ?? 'Struktur Sel',
              ),
            );
          case '/active-recall-session':
            final a = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ActiveRecallSessionPage(
                studySessionId: a?['studySessionId'] as int? ?? 0,
                topicTitle: a?['topicTitle'] as String? ?? 'Rumus Fisika Semester 2',
              ),
            );
          case '/personal-information':
            return MaterialPageRoute(builder: (_) => const PersonalInformationPage());
          case '/study-reminders':
            return MaterialPageRoute(builder: (_) => const StudyRemindersPage());
          case '/support-center':
            return MaterialPageRoute(builder: (_) => const SupportCenterPage());
          default:
            return MaterialPageRoute(builder: (_) => const IntroPage1());
        }
      },
    );
  }
}
