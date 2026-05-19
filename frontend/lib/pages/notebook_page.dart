import 'package:flutter/material.dart';
import 'feynman_session_page.dart';
import 'pomodoro_session_page.dart';
import 'active_recall_session_page.dart';
import 'blurting_session_page.dart';
import 'quiz_page.dart';
import 'new_note_sheet.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  // ── Filter state ──
  final Set<String> _activeFilters = {};

  static const List<Map<String, dynamic>> _notes = [
    {
      'title': 'Fungsi Eksponensial',
      'date': '25 Feb 2026',
      'preview':
          'Fungsi adalah serangkaian metode untuk perhitungan yang melibatkan...',
      'method': 'Pomodoro',
      'methodColor': Color(0xFF2196F3),
      'methodBg': Color(0xFFE3F2FD),
      'methodIcon': Icons.timer_outlined,
    },
    {
      'title': 'Sejarah Majapahit',
      'date': '25 Feb 2026',
      'preview': '...',
      'method': 'Feynman Technique',
      'methodColor': Color(0xFFD32F2F),
      'methodBg': Color(0xFFFFF3F3),
      'methodIcon': Icons.record_voice_over_outlined,
    },
    {
      'title': 'Struktur Sel',
      'date': '25 Feb 2026',
      'preview': '...',
      'method': 'Blurting',
      'methodColor': Color(0xFFE65100),
      'methodBg': Color(0xFFFFF8E1),
      'methodIcon': Icons.edit_note_rounded,
    },
    {
      'title': 'Rumus Fisika Semester 2',
      'date': '25 Feb 2026',
      'preview': '...',
      'method': 'Active Recall',
      'methodColor': Color(0xFF2E7D32),
      'methodBg': Color(0xFFE8F5E9),
      'methodIcon': Icons.psychology_outlined,
    },
  ];

  // ── Notes yang tampil setelah filter diterapkan ──
  List<Map<String, dynamic>> get _filteredNotes {
    if (_activeFilters.isEmpty) return _notes;
    return _notes
        .where((note) => _activeFilters.contains(note['method'] as String))
        .toList();
  }

  // ── Helper: routing ke session page yang benar berdasarkan method ──
  static Widget _sessionPageFor(String method, String title) {
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

  // ── Tampilkan filter dropdown sebagai overlay ──
  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    // Salin filter aktif sementara untuk preview sebelum apply
    final Set<String> tempFilters = Set.from(_activeFilters);
    const methods = ['Pomodoro', 'Feynman Technique', 'Active Recall', 'Blurting'];

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Stack(
          children: [
            // Tap di luar untuk tutup
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            Positioned(
              // Posisi dropdown: tepat di bawah tombol Filter
              top: position.top + (button.size.height),
              right: 16,
              child: StatefulBuilder(
                builder: (ctx2, setLocal) {
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Method checkboxes ──
                          ...methods.map((method) {
                            final isChecked = tempFilters.contains(method);
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setLocal(() {
                                  if (isChecked) {
                                    tempFilters.remove(method);
                                  } else {
                                    tempFilters.add(method);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? const Color(0xFF2196F3)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isChecked
                                              ? const Color(0xFF2196F3)
                                              : const Color(0xFFBBBBBB),
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: isChecked
                                          ? const Icon(Icons.check,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      method,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: isChecked
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isChecked
                                            ? const Color(0xFF2196F3)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 6),

                          // ── Tombol Reset & Apply ──
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                // Reset
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setLocal(() => tempFilters.clear());
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Colors.grey[600],
                                      side: BorderSide(
                                          color: Colors.grey[300]!),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Reset',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Apply
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _activeFilters.clear();
                                        _activeFilters.addAll(tempFilters);
                                      });
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Terapkan',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Title ──
            const Text(
              'Notebook',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ── Weekly Summary Card ──
                  _buildSummaryCard(),

                  const SizedBox(height: 24),

                  // ── Riwayat Catatan Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Catatan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      // ── Filter Button ──
                      Builder(
                        builder: (btnCtx) => GestureDetector(
                          onTap: () => _showFilterMenu(btnCtx),
                          child: Row(
                            children: [
                              // Badge jumlah filter aktif
                              if (_activeFilters.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_activeFilters.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.filter_alt_outlined,
                                size: 16,
                                color: _activeFilters.isNotEmpty
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF2196F3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Filter chips aktif (opsional, untuk visual feedback) ──
                  if (_activeFilters.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      children: _activeFilters.map((f) {
                        // Ambil warna dari data notes
                        final noteData = _notes.firstWhere(
                            (n) => n['method'] == f,
                            orElse: () => _notes.first);
                        return Chip(
                          label: Text(
                            f,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: noteData['methodColor'] as Color,
                            ),
                          ),
                          backgroundColor: noteData['methodBg'] as Color,
                          deleteIconColor: noteData['methodColor'] as Color,
                          onDeleted: () {
                            setState(() => _activeFilters.remove(f));
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Note Cards (filtered) ──
                  if (_filteredNotes.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredNotes
                        .map((note) => _buildNoteCard(context, note)),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── FAB: ke QuizPage agar user pilih metode dulu ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => NewNoteSheet.show(context),
        backgroundColor: const Color(0xFF2196F3),
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),

    );
  }

  // ── Empty state ketika tidak ada catatan yang cocok ──
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.filter_list_off_rounded,
              size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Tidak ada catatan untuk filter ini',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _activeFilters.clear()),
            child: const Text(
              'Hapus filter',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text(
                      '+15%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'jam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Target:\n15j',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Lihat Statistik Detail',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
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
            builder: (_) => _sessionPageFor(
              note['method'] as String,
              note['title'] as String,
            ),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
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
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  note['date'] as String,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              note['preview'] as String,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF999999),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: note['methodBg'] as Color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    note['methodIcon'] as IconData,
                    size: 13,
                    color: note['methodColor'] as Color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    note['method'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: note['methodColor'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? const Color(0xFF2196F3) : Colors.grey[400],
        ),
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