import 'package:flutter/material.dart';
import '../services/quiz_result_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _isLoading = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Skor per metode: [Pomodoro, Active Recall, Feynman, Blurting]
  // index: 0=Pomodoro, 1=Active Recall, 2=Feynman, 3=Blurting
  final List<int> _scores = [0, 0, 0, 0];

  // Menyimpan jawaban user per soal untuk dikirim ke API
  // format: [{ question_no, answer_index, answer_text, scores_added }]
  final List<Map<String, dynamic>> _userAnswers = [];

  static const List<String> _methods = [
    'Pomodoro',
    'Active Recall',
    'Feynman Technique',
    'Blurting',
  ];

  static const List<int> _techniqueIds = [1, 3, 2, 4];

  final List<Map<String, dynamic>> _questions = [
    // Q1 – Durasi Fokus
    {
      'no': 1,
      'dimensi': 'Durasi Fokus',
      'question': 'Berapa lama Anda bisa bertahan belajar tanpa kehilangan konsentrasi sama sekali?',
      'answers': [
        {'icon': Icons.timer_outlined, 'text': 'Sangat singkat, kurang dari 15 menit', 'scores': [2, 0, 0, 0]},
        {'icon': Icons.hourglass_bottom_outlined, 'text': 'Lumayan, sekitar 15–30 menit', 'scores': [1, 0, 0, 0]},
        {'icon': Icons.bolt_outlined, 'text': 'Lama, bisa lebih dari 30 menit tanpa henti', 'scores': [0, 1, 0, 0]},
      ],
    },
    // Q2 – Gaya Belajar
    {
      'no': 2,
      'dimensi': 'Gaya Belajar',
      'question': 'Saat belajar materi baru, Anda paling cepat mengerti jika melalui...',
      'answers': [
        {'icon': Icons.image_outlined, 'text': 'Gambar, grafik, atau coretan konsep', 'scores': [0, 0, 1, 0]},
        {'icon': Icons.hearing_outlined, 'text': 'Mendengarkan penjelasan orang lain', 'scores': [0, 0, 1, 0]},
        {'icon': Icons.touch_app_outlined, 'text': 'Latihan soal atau praktik langsung', 'scores': [0, 1, 0, 0]},
      ],
    },
    // Q3 – Tujuan Belajar
    {
      'no': 3,
      'dimensi': 'Tujuan Belajar',
      'question': 'Apa target utama Anda saat sedang belajar?',
      'answers': [
        {'icon': Icons.format_list_numbered_outlined, 'text': 'Utamanya menghafal fakta, istilah, atau rumus', 'scores': [0, 2, 0, 0]},
        {'icon': Icons.balance_outlined, 'text': 'Seimbang antara menghafal dan paham konsep', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.psychology_outlined, 'text': 'Benar-benar memahami konsep utuhnya secara mendalam', 'scores': [0, 0, 2, 0]},
      ],
    },
    // Q4 – Metakognisi
    {
      'no': 4,
      'dimensi': 'Metakognisi',
      'question': 'Apakah Anda tahu persis gaya atau teknik belajar apa yang paling ampuh untuk Anda?',
      'answers': [
        {'icon': Icons.check_circle_outline, 'text': 'Ya, saya sangat sadar cara terbaik saya belajar', 'scores': [1, 0, 0, 0]},
        {'icon': Icons.help_outline, 'text': 'Kadang-kadang berhasil, kadang tidak', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.search_outlined, 'text': 'Tidak, saya masih sering bingung dan coba-coba', 'scores': [0, 1, 0, 0]},
      ],
    },
    // Q5 – Kebiasaan Jadwal
    {
      'no': 5,
      'dimensi': 'Kebiasaan Jadwal',
      'question': 'Dalam seminggu, seberapa sering Anda membuat jadwal belajar yang terstruktur?',
      'answers': [
        {'icon': Icons.calendar_today_outlined, 'text': 'Tidak pernah sama sekali', 'scores': [2, 0, 0, 0]},
        {'icon': Icons.event_outlined, 'text': 'Sekitar 1–2 kali saja', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.date_range_outlined, 'text': 'Sering, 3 kali atau lebih', 'scores': [0, 0, 2, 0]},
      ],
    },
    // Q6 – Tingkat Stres
    {
      'no': 6,
      'dimensi': 'Tingkat Stres',
      'question': 'Ketika sedang belajar atau menghadapi tugas, apakah Anda sering merasa cemas/tertekan?',
      'answers': [
        {'icon': Icons.sentiment_very_dissatisfied_outlined, 'text': 'Ya, sangat sering cemas', 'scores': [2, 0, 0, 0]},
        {'icon': Icons.sentiment_neutral_outlined, 'text': 'Terkadang saja', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.sentiment_satisfied_outlined, 'text': 'Jarang, saya cenderung santai', 'scores': [0, 1, 0, 0]},
      ],
    },
    // Q7 – Kebutuhan Interaksi
    {
      'no': 7,
      'dimensi': 'Kebutuhan Interaksi',
      'question': 'Jika disuruh memilih, Anda lebih nyaman belajar dalam situasi...',
      'answers': [
        {'icon': Icons.person_outlined, 'text': 'Sendirian di tempat yang tenang', 'scores': [0, 1, 0, 0]},
        {'icon': Icons.groups_outlined, 'text': 'Bersama teman atau dalam kelompok belajar', 'scores': [0, 0, 2, 0]},
      ],
    },
    // Q8 – Preferensi Pengulangan
    {
      'no': 8,
      'dimensi': 'Preferensi Pengulangan',
      'question': 'Apakah Anda tipe orang yang suka me-review/mengulang materi sedikit demi sedikit di hari yang berbeda?',
      'answers': [
        {'icon': Icons.repeat_outlined, 'text': 'Sangat suka, saya selalu mereview berkala', 'scores': [0, 2, 0, 0]},
        {'icon': Icons.sync_outlined, 'text': 'Kadang-kadang kalau sempat', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.alarm_outlined, 'text': 'Tidak, saya lebih suka SKS (Sistem Kebut Semalam)', 'scores': [1, 0, 0, 0]},
      ],
    },
    // Q9 – Cara Mengatasi Kesulitan
    {
      'no': 9,
      'dimensi': 'Cara Mengatasi Kesulitan',
      'question': 'Jika ada materi yang sangat sulit dimengerti, apa yang Anda lakukan?',
      'answers': [
        {'icon': Icons.menu_book_outlined, 'text': 'Membaca ulang teks di buku berkali-kali', 'scores': [0, 2, 0, 0]},
        {'icon': Icons.edit_outlined, 'text': 'Menutup buku, lalu mencoba menulis ulang semua yang saya ingat di kertas kosong', 'scores': [0, 0, 0, 2]},
        {'icon': Icons.record_voice_over_outlined, 'text': 'Berusaha menjelaskan ulang materi tersebut (seolah sedang mengajar orang lain)', 'scores': [0, 0, 2, 0]},
      ],
    },
    // Q10 – Frekuensi Istirahat
    {
      'no': 10,
      'dimensi': 'Frekuensi Istirahat',
      'question': 'Seberapa sering Anda butuh berhenti sejenak untuk peregangan, cek HP, atau minum di tengah sesi belajar?',
      'answers': [
        {'icon': Icons.coffee_outlined, 'text': 'Sangat sering, saya gampang jenuh', 'scores': [2, 0, 0, 0]},
        {'icon': Icons.trending_flat_outlined, 'text': 'Jarang, saya biasa lanjut terus', 'scores': [0, 0, 0, 0]},
      ],
    },
    // Q11 – Ketahanan Belajar
    {
      'no': 11,
      'dimensi': 'Ketahanan Belajar',
      'question': '"Saya bisa duduk diam belajar lebih dari 45 menit terus-menerus tanpa terdistraksi."',
      'answers': [
        {'icon': Icons.check_outlined, 'text': 'Benar / Ya', 'scores': [0, 1, 0, 0]},
        {'icon': Icons.close_outlined, 'text': 'Salah / Tidak', 'scores': [2, 0, 0, 0]},
      ],
    },
    // Q12 – Minat Mengajar
    {
      'no': 12,
      'dimensi': 'Minat Mengajar',
      'question': 'Apakah Anda menikmati momen saat harus menjelaskan pelajaran kepada teman yang belum paham?',
      'answers': [
        {'icon': Icons.favorite_outline, 'text': 'Sangat menikmati dan suka', 'scores': [0, 0, 2, 0]},
        {'icon': Icons.remove_outlined, 'text': 'Biasa saja', 'scores': [0, 0, 0, 0]},
        {'icon': Icons.person_off_outlined, 'text': 'Tidak suka, saya mending menyerap untuk diri sendiri', 'scores': [0, 1, 0, 0]},
      ],
    },
  ];

  int get _totalQuestions => _questions.length;
  double get _progress => (_currentQuestion + 1) / _totalQuestions;
  String get _progressLabel => '${_currentQuestion + 1} / $_totalQuestions';
  bool get _isLastQuestion => _currentQuestion == _totalQuestions - 1;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _determineResult() {
    int maxScore = _scores.reduce((a, b) => a > b ? a : b);
    int winnerIndex = _scores.indexOf(maxScore);
    return _methods[winnerIndex];
  }

  int _determineTechniqueId() {
    int maxScore = _scores.reduce((a, b) => a > b ? a : b);
    int winnerIndex = _scores.indexOf(maxScore);
    return _techniqueIds[winnerIndex];
  }


  Future<void> _next() async {
    if (_selectedAnswer == null) return;

    // Akumulasi skor
    final answerScores = _questions[_currentQuestion]['answers'][_selectedAnswer!]['scores'] as List<int>;
    for (int i = 0; i < _scores.length; i++) {
      _scores[i] += answerScores[i];
    }

    // Simpan jawaban user
    _userAnswers.add({
      'question_no': _questions[_currentQuestion]['no'],
      'answer_index': _selectedAnswer,
      'answer_text': _questions[_currentQuestion]['answers'][_selectedAnswer!]['text'],
    });

    if (!_isLastQuestion) {
      // Transisi ke soal berikutnya
      await _fadeController.reverse();
      await _slideController.reverse();
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
      _slideController.forward();
      _fadeController.forward();
    } else {
      // Soal terakhir → POST quiz result lalu ke result page
      setState(() => _isLoading = true);

      final result      = _determineResult();
      final techniqueId = _determineTechniqueId();

      try {
        await QuizResultService.store(
          studyTechniqueId: techniqueId,
        );

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/quiz-result',
          arguments: {'method': result, 'scores': _scores},
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan hasil: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final answers = question['answers'] as List<Map<String, dynamic>>;

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
                        child: const Icon(Icons.chevron_left, color: Color(0xFF2196F3), size: 28),
                      ),
                    ),
                  ),
                  const Text(
                    'Quiz',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _progressLabel,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Progress Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFDDE3EE),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Dimensi Label ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question['dimensi'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Content ──
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          question['question'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.55,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Answer Options
                      ...List.generate(answers.length, (index) {
                        final answer = answers[index];
                        final isSelected = _selectedAnswer == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedAnswer = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2196F3).withOpacity(0.06) : Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF2196F3).withOpacity(0.15)
                                          : const Color(0xFFE8F0FE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(answer['icon'] as IconData, color: const Color(0xFF2196F3), size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      answer['text'] as String,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
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
                      }),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
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
                      onPressed: (_selectedAnswer != null && !_isLoading) ? _next : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        disabledBackgroundColor: const Color(0xFF2196F3).withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
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
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Jawabanmu membantu LearnFit menyesuaikan metode belajarmu.',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[500], height: 1.5),
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