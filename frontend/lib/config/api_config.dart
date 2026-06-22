// ponytail: single source of truth for the API host. Override at build time:
//   flutter run --dart-define=API_HOST=http://10.0.2.2:8000/api
//   flutter run --dart-define=API_HOST=http://localhost:8000/api
class ApiConfig {
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'https://learnfit-0b10b17e8a10.herokuapp.com/api',
  );

  static String get base => _host;

  static String url(String path) =>
      path.startsWith('/') ? '$_host$path' : '$_host/$path';

  // auth
  static String get login => '$_host/login';
  static String get logout => '$_host/logout';
  static String get register => '$_host/register';
  static String get forgotPassword => '$_host/forgot-password';
  static String get otpResend => '$_host/otp/resend';
  static String get otpVerify => '$_host/otp/verify';

  // profile
  static String get profile => '$_host/profile';
  static String get profileAvatar => '$_host/profile/avatar';

  // stats
  static String get userDailyStats => '$_host/user-daily-stats';

  // flashcards
  static String get flashcards => '$_host/flashcards';
  static String get flashcardsTotal => '$_host/flashcards/total';
  static String flashcard(int id) => '$_host/flashcards/$id';

  // quiz
  static String get quizResults => '$_host/quiz-results';

  // study sessions
  static String get studySessions => '$_host/study-sessions';
  static String studySession(int id) => '$_host/study-sessions/$id';
  static String studySessionAttachment(int id) =>
      '$_host/study-sessions/$id/attachments';
  static String studySessionEvaluate(int id) =>
      '$_host/study-sessions/$id/evaluate';

  // session logs
  static String get sessionLogs => '$_host/session-logs';
}
