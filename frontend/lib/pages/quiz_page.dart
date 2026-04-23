import 'package:flutter/material.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;

  // Tracks score per method: index 0=Pomodoro, 1=Active Recall, 2=Feynman, 3=Blurting
  final List<int> _scores = [0, 0, 0, 0];

  // Each answer maps to a method index
  // 0 = Pomodoro (visual / focus)
  // 1 = Active Recall (auditory / group)
  // 2 = Feynman Technique (read-write)
  // 3 = Blurting (kinesthetic)
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Ketika belajar hal baru, kamu lebih mudah memahami melalui?',
      'answers': [
        {'icon': Icons.visibility_outlined, 'text': 'Melihat gambar atau diagram'},
        {'icon': Icons.groups_outlined, 'text': 'Mendengar penjelasan langsung'},
        {'icon': Icons.edit_note_outlined, 'text': 'Membaca dan mencatat sendiri'},
        {'icon': Icons.touch_app_outlined, 'text': 'Langsung mencoba dan praktik'},
      ],
    },
    {
      'question': 'Saat mengingat sesuatu, kamu biasanya mengingat melalui?',
      'answers': [
        {'icon': Icons.visibility_outlined, 'text': 'Gambaran visual di kepala'},
        {'icon': Icons.groups_outlined, 'text': 'Suara atau kata-kata'},
        {'icon': Icons.edit_note_outlined, 'text': 'Catatan atau tulisan'},
        {'icon': Icons.touch_app_outlined, 'text': 'Gerakan atau pengalaman'},
      ],
    },
    {
      'question': 'Ketika mengikuti instruksi, kamu lebih suka?',
      'answers': [
        {'icon': Icons.visibility_outlined, 'text': 'Melihat diagram langkah-langkah'},
        {'icon': Icons.groups_outlined, 'text': 'Mendengar penjelasan verbal'},
        {'icon': Icons.edit_note_outlined, 'text': 'Membaca panduan tertulis'},
        {'icon': Icons.touch_app_outlined, 'text': 'Langsung dipandu sambil praktik'},
      ],
    },
    {
      'question': 'Ketika bosan, kamu biasanya?',
      'answers': [
        {'icon': Icons.visibility_outlined, 'text': 'Melamun atau melihat sekeliling'},
        {'icon': Icons.groups_outlined, 'text': 'Mengobrol atau bersenandung'},
        {'icon': Icons.edit_note_outlined, 'text': 'Mencoret-coret kertas'},
        {'icon': Icons.touch_app_outlined, 'text': 'Bergerak atau memainkan sesuatu'},
      ],
    },
  ];

  // Method names mapped by index
  static const List<String> _methods = [
    'Pomodoro',
    'Active Recall',
    'Feynman Technique',
    'Blurting',
  ];

  int get _totalQuestions => _questions.length;
  double get _progress => (_currentQuestion + 1) / _totalQuestions;
  String get _progressLabel => '${((_progress) * 100).round()}%';
  bool get _isLastQuestion => _currentQuestion == _totalQuestions - 1;

  String _determineResult() {
    int maxScore = _scores.reduce((a, b) => a > b ? a : b);
    int winnerIndex = _scores.indexOf(maxScore);
    return _methods[winnerIndex];
  }

  void _next() {
    if (_selectedAnswer == null) return;

    // Accumulate score for selected answer's method
    _scores[_selectedAnswer!]++;

    if (!_isLastQuestion) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
    } else {
      final result = _determineResult();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(method: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF2196F3),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Quiz',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Progress Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _progressLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFDDE3EE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // ── Question Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Answer Options ──
                  ...List.generate(
                    (question['answers'] as List).length,
                    (index) {
                      final answer = question['answers'][index];
                      final isSelected = _selectedAnswer == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAnswer = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2196F3)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F0FE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    answer['icon'] as IconData,
                                    color: const Color(0xFF2196F3),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    answer['text'],
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2196F3)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 6 : 1.5,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Bottom Section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer != null ? _next : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        disabledBackgroundColor:
                            const Color(0xFF2196F3).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLastQuestion ? 'Lihat Hasilnya' : 'Selanjutnya',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Jawabanmu membantu LearnFit menyesuaikan metode belajarmu.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}