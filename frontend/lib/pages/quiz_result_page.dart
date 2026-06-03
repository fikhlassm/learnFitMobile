import 'package:flutter/material.dart';
import 'feynman_session_page.dart';
import 'pomodoro_session_page.dart';
import 'active_recall_session_page.dart';
import 'blurting_session_page.dart';

class QuizResultPage extends StatelessWidget {
  final String method;
  final String topicTitle;

  const QuizResultPage({
    super.key,
    required this.method,
    this.topicTitle = '',
  });

  // ── Routing ke session page yang benar ──
  void _navigateToSession(BuildContext context) {
    final topic =
        topicTitle.isNotEmpty ? topicTitle : _defaultTopic[method] ?? 'Materi';

    final Widget page;
    if (method == 'Pomodoro') {
      page = PomodoroSessionPage(topicTitle: topic);
    } else if (method == 'Active Recall') {
      page = ActiveRecallSessionPage(topicTitle: topic, token: "0");
    } else if (method == 'Feynman Technique') {
      page = FeynmanSessionPage(topicTitle: topic);
    } else if (method == 'Blurting') {
      page = BlurtingSessionPage(topicTitle: topic);
    } else {
      page = PomodoroSessionPage(topicTitle: topic);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final data = _methodData[method] ?? _methodData['Pomodoro']!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Title ──
            const Text(
              'Metode Belajar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // ── Hero Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: data['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      color: data['iconColor'] as Color,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Method Name ──
            Text(
              method,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // ── Steps ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: List.generate(
                    (data['steps'] as List).length,
                    (index) {
                      final step = (data['steps'] as List)[index];
                      final stepColor = data['stepColor'] as Color;
                      final stepTextColor = data['stepTextColor'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: stepColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '0${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: stepTextColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      step['desc'],
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey[500],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Tombol Mulai Belajar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  // ✅ Panggil _navigateToSession, BUKAN hardcode FeynmanSessionPage
                  onPressed: () => _navigateToSession(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mulai Belajar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Default topic per method ──
const Map<String, String> _defaultTopic = {
  'Pomodoro': 'Fungsi Eksponensial',
  'Active Recall': 'Rumus Fisika Semester 2',
  'Feynman Technique': 'Sejarah Majapahit',
  'Blurting': 'Struktur Sel',
};

// ── Method Data ──
const Map<String, Map<String, dynamic>> _methodData = {
  'Pomodoro': {
    'bgColor': Color(0xFFDEEBFB),
    'icon': Icons.timer_outlined,
    'iconColor': Color(0xFF2196F3),
    'stepColor': Color(0xFFE8F0FE),
    'stepTextColor': Color(0xFF2196F3),
    'steps': [
      {'title': 'Fokus 25 Menit', 'desc': 'Kerjakan tugas tanpa gangguan.'},
      {'title': 'Istirahat 5 Menit', 'desc': 'Penyegaran singkat.'},
      {
        'title': 'Ulangi 4 Kali',
        'desc': 'Lakukan siklus dan ambil istirahat panjang.'
      },
    ],
  },
  'Active Recall': {
    'bgColor': Color(0xFFD6F0E8),
    'icon': Icons.psychology_outlined,
    'iconColor': Color(0xFF2E7D32),
    'stepColor': Color(0xFFE8F5E9),
    'stepTextColor': Color(0xFF2E7D32),
    'steps': [
      {
        'title': 'Pelajari Materi',
        'desc': 'Pahami konsep dasar secara mendalam dari bacaan.'
      },
      {
        'title': 'Buat Flashcard',
        'desc':
            'Tulis pertanyaan dan jawaban di sisi berbeda untuk menguji diri.'
      },
      {
        'title': 'Kuis Berkala',
        'desc':
            'Lakukan tes mandiri secara berkala untuk memperkuat ingatan jangka panjang.'
      },
    ],
  },
  'Feynman Technique': {
    'bgColor': Color(0xFFFDE8E8),
    'icon': Icons.record_voice_over_outlined,
    'iconColor': Color(0xFFD32F2F),
    'stepColor': Color(0xFFFFF3F3),
    'stepTextColor': Color(0xFFD32F2F),
    'steps': [
      {
        'title': 'Pilih Topik',
        'desc': 'Tentukan konsep spesifik yang ingin kamu kuasai sepenuhnya.'
      },
      {
        'title': 'Jelaskan',
        'desc':
            'Jelaskan materi tersebut seolah-olah kamu mengajar anak usia 10 tahun.'
      },
      {
        'title': 'Evaluasi',
        'desc':
            'Identifikasi bagian yang sulit, pelajari lagi, lalu sederhanakan bahasanya.'
      },
    ],
  },
  'Blurting': {
    'bgColor': Color(0xFFFFF3D6),
    'icon': Icons.edit_note_rounded,
    'iconColor': Color(0xFFE65100),
    'stepColor': Color(0xFFFFF8E1),
    'stepTextColor': Color(0xFFE65100),
    'steps': [
      {
        'title': 'Baca',
        'desc': 'Pelajari satu topik tertentu dalam durasi singkat.'
      },
      {
        'title': 'Tulis',
        'desc':
            'Tutup buku dan tuliskan semua hal yang kamu ingat di kertas kosong tanpa melihat catatan.'
      },
      {
        'title': 'Evaluasi',
        'desc':
            'Buka materi kembali, identifikasi poin yang kurang maupun salah.'
      },
    ],
  },
};