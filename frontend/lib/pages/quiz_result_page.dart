import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final String method;
  final List<int> scores; // [pomodoro, activeRecall, feynman, blurting]

  const QuizResultPage({
    super.key,
    required this.method,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final data = _methodData[method] ?? _methodData['Pomodoro']!;
    final totalScore = scores.fold(0, (sum, s) => sum + s);

    final scoreBreakdown = [
      {'label': 'Pomodoro', 'score': scores[0], 'color': const Color(0xFF2196F3)},
      {'label': 'Active Recall', 'score': scores[1], 'color': const Color(0xFF2E7D32)},
      {'label': 'Feynman Technique', 'score': scores[2], 'color': const Color(0xFFD32F2F)},
      {'label': 'Blurting', 'score': scores[3], 'color': const Color(0xFFE65100)},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Metode Belajar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // ── Banner metode ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: data['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(data['icon'] as IconData, color: data['iconColor'] as Color, size: 36),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✦ Rekomendasimu',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              method,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Berdasarkan hasil quizmu',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Skor Breakdown ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEFF3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skor Kesesuaian',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          ...scoreBreakdown.map((item) {
                            final score = item['score'] as int;
                            final color = item['color'] as Color;
                            final label = item['label'] as String;
                            final isWinner = label == method;
                            final pct = totalScore > 0 ? score / totalScore : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (isWinner)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Icon(Icons.star_rounded, size: 14, color: color),
                                        ),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                                            color: isWinner ? color : Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$score poin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                                          color: isWinner ? color : Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 5,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isWinner ? color : color.withOpacity(0.35),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Langkah-langkah metode ──
                    const Text(
                      'Cara Kerjanya',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),

                    ...List.generate((data['steps'] as List).length, (index) {
                      final step = (data['steps'] as List)[index];
                      final stepColor = data['stepColor'] as Color;
                      final stepTextColor = data['stepTextColor'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100, width: 1),
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
                                    '${index + 1}',
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
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── CTA → Navigasi Langsung ke HomePage Class ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                      arguments: {'initialIndex': 1},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mulai Belajar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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

// ─── Constants ───────────────────────────────────────────────────────────────
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
      {'title': 'Ulangi 4 Kali', 'desc': 'Lakukan siklus dan ambil istirahat panjang.'},
    ],
  },
  'Active Recall': {
    'bgColor': Color(0xFFD6F0E8),
    'icon': Icons.psychology_outlined,
    'iconColor': Color(0xFF2E7D32),
    'stepColor': Color(0xFFE8F5E9),
    'stepTextColor': Color(0xFF2E7D32),
    'steps': [
      {'title': 'Pelajari Materi', 'desc': 'Pahami konsep dasar secara mendalam dari bacaan.'},
      {'title': 'Buat Flashcard', 'desc': 'Tulis pertanyaan dan jawaban di sisi berbeda untuk menguji diri.'},
      {'title': 'Kuis Berkala', 'desc': 'Lakukan tes mandiri secara berkala untuk memperkuat ingatan jangka panjang.'},
    ],
  },
  'Feynman Technique': {
    'bgColor': Color(0xFFFDE8E8),
    'icon': Icons.record_voice_over_outlined,
    'iconColor': Color(0xFFD32F2F),
    'stepColor': Color(0xFFFFF3F3),
    'stepTextColor': Color(0xFFD32F2F),
    'steps': [
      {'title': 'Pilih Topik', 'desc': 'Tentukan konsep spesifik yang ingin kamu kuasai sepenuhnya.'},
      {'title': 'Jelaskan', 'desc': 'Jelaskan materi tersebut seolah-olah kamu mengajar anak usia 10 tahun.'},
      {'title': 'Evaluasi', 'desc': 'Identifikasi bagian yang sulit, pelajari lagi, lalu sederhanakan bahasanya.'},
    ],
  },
  'Blurting': {
    'bgColor': Color(0xFFFFF3D6),
    'icon': Icons.edit_note_rounded,
    'iconColor': Color(0xFFE65100),
    'stepColor': Color(0xFFFFF8E1),
    'stepTextColor': Color(0xFFE65100),
    'steps': [
      {'title': 'Baca', 'desc': 'Pelajari satu topik tertentu dalam durasi singkat.'},
      {'title': 'Tulis', 'desc': 'Tutup buku dan tuliskan semua hal yang kamu ingat di kertas kosong tanpa melihat catatan.'},
      {'title': 'Evaluasi', 'desc': 'Buka materi kembali, identifikasi poin yang kurang maupun salah.'},
    ],
  },
};