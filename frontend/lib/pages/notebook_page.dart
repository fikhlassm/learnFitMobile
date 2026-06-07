import 'package:flutter/material.dart';
import '../services/study_session_service.dart';
import 'feynman_session_page.dart';
import 'pomodoro_session_page.dart';
import 'active_recall_session_page.dart';
import 'blurting_session_page.dart';
import 'quiz_page.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  List<dynamic> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadStudySessions();
  }

  Future<void> _loadStudySessions() async {
  try {
    final data =
        await StudySessionService
            .getStudySessions();

    print(
      'STUDY SESSION API = $data',
    );

    setState(() {
      _notes = data;
    });
  } catch (e) {
    print(e);
  }
}

  String _getMethodName(int id) {
    switch (id) {
      case 1: return 'Pomodoro';
      case 2: return 'Feynman Technique';
      case 3: return 'Active Recall';
      case 4: return 'Blurting';
      default: return 'Unknown';
    }
  }

  IconData _getMethodIcon(int id) {
    switch (id) {
      case 1: return Icons.timer_outlined;
      case 2: return Icons.record_voice_over_outlined;
      case 3: return Icons.psychology_outlined;
      case 4: return Icons.edit_note_rounded;
      default: return Icons.help_outline;
    }
  }

  Color _getMethodColor(int id) {
    switch (id) {
      case 1: return const Color(0xFF2196F3);
      case 2: return const Color(0xFFD32F2F);
      case 3: return const Color(0xFF2E7D32);
      case 4: return const Color(0xFFE65100);
      default: return Colors.grey;
    }
  }

  Color _getMethodBg(int id) {
    switch (id) {
      case 1: return const Color(0xFFE3F2FD);
      case 2: return const Color(0xFFFFF3F3);
      case 3: return const Color(0xFFE8F5E9);
      case 4: return const Color(0xFFFFF8E1);
      default: return Colors.grey.shade200;
    }
  }

  // ← DIUBAH: terima note map langsung, ambil id dan method dari sana
  Widget _sessionPageFor(
  Map<String, dynamic> note,
) {

  print(
    'NOTE CLICKED = $note',
  );

  final method =
      note['method'].toString();

  final title =
      note['title'].toString();

  final sessionId =
      int.tryParse(
        note['id'].toString(),
      ) ??
      0;

  print(
    'SESSION ID SENT = $sessionId',
  );

  switch (method) {
      case 'Pomodoro':
        return PomodoroSessionPage(topicTitle: title);
      case 'Active Recall':
        return ActiveRecallSessionPage(
          topicTitle: title,
<<<<<<< HEAD
          token: "0",
=======
          studySessionId: sessionId, // ← DIUBAH: pass session id
>>>>>>> 05783034e75ded4267471e14ed85c23cb3e5f981
        );
      case 'Feynman Technique':
        return FeynmanSessionPage(topicTitle: title);
      case 'Blurting':
        return BlurtingSessionPage(topicTitle: title);
      default:
        return FeynmanSessionPage(topicTitle: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Notebook',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Riwayat Catatan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Text(
                                    'Filter',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2196F3)),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.filter_alt_outlined, size: 16, color: Color(0xFF2196F3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._notes.map((note) {
                          final techniqueId = note['study_technique_id'] ?? 0;
                          // ← DIUBAH: sertakan 'id' dari API ke map
                          return _buildNoteCard(
                            context,
                            {
                              'id': note['id'] ?? 0,
                              'title': note['topic'] ?? '',
                              'date': 'Today',
                              'preview': note['content'] ?? '',
                              'method': _getMethodName(techniqueId),
                              'methodColor': _getMethodColor(techniqueId),
                              'methodBg': _getMethodBg(techniqueId),
                              'methodIcon': _getMethodIcon(techniqueId),
                            },
                          );
                        }),
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage()));
        },
        backgroundColor: const Color(0xFF2196F3),
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Belajar Mingguan',
                style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text('+15%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '12.5',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('jam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70)),
              ),
              const Spacer(),
              const Text(
                'Target:\n15j',
                style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 12.5 / 15,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Lihat Statistik Detail',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // ← DIUBAH: pass note map lengkap (termasuk 'id') ke _sessionPageFor
            builder: (_) => _sessionPageFor(note),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note['title'] as String,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                Text(note['date'] as String, style: const TextStyle(fontSize: 11.5, color: Color(0xFFAAAAAA))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              note['preview'] as String,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF999999), height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: note['methodBg'] as Color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(note['methodIcon'] as IconData, size: 13, color: note['methodColor'] as Color),
                  const SizedBox(width: 5),
                  Text(
                    note['method'] as String,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: note['methodColor'] as Color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.article_outlined, 'Notebook', true),
              _navItem(Icons.track_changes_outlined, 'Goals', false),
              _navItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: isActive ? const Color(0xFF2196F3) : Colors.grey[400]),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? const Color(0xFF2196F3) : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}