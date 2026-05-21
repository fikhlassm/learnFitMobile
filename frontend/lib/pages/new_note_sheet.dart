import 'package:flutter/material.dart';
import 'feynman_session_page.dart';
import 'pomodoro_session_page.dart';
import 'active_recall_session_page.dart';
import 'blurting_session_page.dart';
import 'quiz_page.dart';

// ── Data model tiap metode ──
class _MethodOption {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MethodOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

const _methods = [
  _MethodOption(
    id: 'Pomodoro',
    label: 'Pomodoro',
    description: 'Belajar menggunakan interval waktu tertentu.',
    icon: Icons.timer_outlined,
    color: Color(0xFF2196F3),
    bgColor: Color(0xFFE3F2FD),
  ),
  _MethodOption(
    id: 'Feynman Technique',
    label: 'Feynman',
    description: 'Ajarkan konsep dengan bahasa sederhana.',
    icon: Icons.record_voice_over_outlined,
    color: Color(0xFFD32F2F),
    bgColor: Color(0xFFFFF3F3),
  ),
  _MethodOption(
    id: 'Active Recall',
    label: 'Active Recall',
    description: 'Asah ingatan jangka panjang.',
    icon: Icons.psychology_outlined,
    color: Color(0xFF2E7D32),
    bgColor: Color(0xFFE8F5E9),
  ),
  _MethodOption(
    id: 'Blurting',
    label: 'Blurting',
    description: 'Tulis materi seingatnya lalu review.',
    icon: Icons.edit_note_rounded,
    color: Color(0xFFE65100),
    bgColor: Color(0xFFFFF8E1),
  ),
];

class NewNoteSheet extends StatefulWidget {
  const NewNoteSheet({super.key});

  /// Panggil ini dari FAB
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewNoteSheet(),
    );
  }

  @override
  State<NewNoteSheet> createState() => _NewNoteSheetState();
}

class _NewNoteSheetState extends State<NewNoteSheet> {
  final _titleController = TextEditingController();
  String? _selectedMethod;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ── Routing ke session page ──
  Widget _sessionPageFor(String method, String title) {
    switch (method) {
      case 'Pomodoro':
        return PomodoroSessionPage(topicTitle: title);
      case 'Active Recall':
        return ActiveRecallSessionPage(topicTitle: title);
      case 'Feynman Technique':
        return FeynmanSessionPage(topicTitle: title);
      case 'Blurting':
        return BlurtingSessionPage(topicTitle: title);
      default:
        return FeynmanSessionPage(topicTitle: title);
    }
  }

  void _startSession() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showSnackbar('Masukkan judul catatan terlebih dahulu.');
      return;
    }
    if (_selectedMethod == null) {
      _showSnackbar('Pilih teknik belajar terlebih dahulu.');
      return;
    }

    Navigator.pop(context); // tutup sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _sessionPageFor(_selectedMethod!, title),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Catatan Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close,
                      size: 18, color: Colors.black54),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Input Judul ──
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 14.5, color: Colors.black87),
            decoration: const InputDecoration(
              hintText: 'Masukkan judul catatan...',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14.5),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color(0xFF2196F3), width: 1.5),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8),
            ),
          ),

          const SizedBox(height: 16),

          // ── Quiz Suggestion Banner ──
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE8FF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 16, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Metode mana yang harus saya ambil?\nLakukan quiz!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: Color(0xFFAAAAAA)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section label ──
          const Text(
            'TEKNIK BELAJAR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          // ── Method Grid 2x2 ──
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: _methods.map((m) => _buildMethodCard(m)).toList(),
          ),

          const SizedBox(height: 20),

          // ── Start Session Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Session',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(_MethodOption method) {
    final isSelected = _selectedMethod == method.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? method.bgColor : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? method.color : const Color(0xFFEEEEEE),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? method.color.withOpacity(0.15)
                        : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    method.icon,
                    size: 16,
                    color: isSelected ? method.color : const Color(0xFFAAAAAA),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: method.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              method.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? method.color : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              method.description,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFFAAAAAA),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}