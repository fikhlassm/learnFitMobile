import 'package:flutter/material.dart';
import '../services/flash_card_service.dart';
import 'notebook_page.dart';

class ActiveRecallSessionPage extends StatefulWidget {
  final String topicTitle;
  final int studySessionId;

  const ActiveRecallSessionPage({
    super.key,
    required this.studySessionId,
    this.topicTitle = 'Rumus Fisika Semester 2',
  });

  @override
  State<ActiveRecallSessionPage> createState() =>
      _ActiveRecallSessionPageState();
}

class _ActiveRecallSessionPageState extends State<ActiveRecallSessionPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLatihan = true;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  List<Map<String, dynamic>> _cards = [];
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadFlashcards() async {
  try {
    final data = await FlashcardService.getFlashcards(
      studySessionId: widget.studySessionId,
    );

    setState(() {
      _cards =
          List<Map<String, dynamic>>.from(
        data.map(
          (item) => {
            'id': item['id'],
            'question': item['question'] ?? '',
            'answer': item['answer'] ?? '',
          },
        ),
      );
    });
  } catch (e) {
    print(e);
  }
}

  Future<void> _addFlashcard() async {
  if (questionController.text.isEmpty ||
      answerController.text.isEmpty) {
    return;
  }

  try {
    print(
      'ADD FLASHCARD SESSION = ${widget.studySessionId}',
    );

    print(
      'QUESTION = ${questionController.text}',
    );

    print(
      'ANSWER = ${answerController.text}',
    );

print(
  'BUTTON CLICKED',
);

await FlashcardService.createFlashcard(
      studySessionId: widget.studySessionId,
      question: questionController.text,
      answer: answerController.text,
    );

    print('FLASHCARD CREATED');

    questionController.clear();
    answerController.clear();

    await _loadFlashcards();

    setState(() {
      _isLatihan = true;

      if (_cards.isNotEmpty) {
        _currentIndex = _cards.length - 1;
      }
    });
  } catch (e) {
    print(
      'FLASHCARD ERROR = $e',
    );
  }
}

  @override
  void dispose() {
    _flipController.dispose();
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _flipController.reset();
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
        _flipController.reset();
      });
    }
  }

  void _selesaikanSesi() {
    Navigator.pop(
  context,
  true,
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
            _buildAppBar(),
            Expanded(
              child: _isLatihan ? _buildLatihanView() : _buildBuatKartuView(),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: const Icon(Icons.chevron_left, color: Color(0xFF2196F3), size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.topicTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black87, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLatihanView() {
    if (_cards.isEmpty) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _buildTabs(),
        const SizedBox(height: 40),

        const Icon(
          Icons.style_outlined,
          size: 80,
          color: Colors.grey,
        ),

        const SizedBox(height: 16),

        const Text(
          'Belum Ada Flashcard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Tambahkan kartu pertama pada tab Buat Kartu',
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _isLatihan = false;
            });
          },
          child: const Text(
            'Buat Flashcard',
          ),
        ),
      ],
    ),
  );
}
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'LATIHAN',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 20),
          Expanded(child: _buildFlashcard()),
          const SizedBox(height: 20),
          _buildNavButtons(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(child: _tabButton('Sesi Latihan', true)),
          Expanded(child: _tabButton('Buat Kartu', false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool isLatihan) {
    final isSelected = _isLatihan == isLatihan;
    return GestureDetector(
      onTap: () => setState(() => _isLatihan = isLatihan),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.black87 : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _cards.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_currentIndex + 1}/${_cards.length} kartu',
          style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildFlashcard() {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isFront = _flipAnimation.value < 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isFront
                  ? _buildCardFront()
                  : Transform(
                      transform: Matrix4.identity()..rotateY(3.14159),
                      alignment: Alignment.center,
                      child: _buildCardBack(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _cards[_currentIndex]['question'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'KLIK KARTU UNTUK MELIHAT JAWABAN',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'JAWABAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _cards[_currentIndex]['answer'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: _currentIndex > 0 ? _prevCard : null,
          child: const Text('Sebelumnya'),
        ),
        OutlinedButton(
          onPressed: _currentIndex < _cards.length - 1 ? _nextCard : null,
          child: const Text('Selanjutnya'),
        ),
      ],
    );
  }

  Widget _buildBuatKartuView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'KELOLA KARTU',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 16),

        _buildTabs(),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERTANYAAN / KONSEP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: questionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis pertanyaan disini...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'JAWABAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: answerController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis jawaban disini...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _addFlashcard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Daftar Kartu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Divider(
          color: Colors.grey.shade400,
        ),

        const SizedBox(height: 8),

        if (_cards.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Belum ada kartu',
              ),
            ),
          ),

        ..._cards.map((card) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(
                  width: 4,
                  color: Colors.black,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
            child: ListTile(
  title: Text(
    card['question'] ?? '',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: Text(
    card['answer'] ?? '',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
  trailing: PopupMenuButton<String>(
    onSelected: (value) async {
      if (value == 'edit') {
        _showEditDialog(card);
      }

      if (value == 'delete') {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Hapus Flashcard',
            ),
            content: const Text(
              'Yakin ingin menghapus kartu ini?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text(
                  'Batal',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Hapus',
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await FlashcardService.deleteFlashcard(
            id: card['id'],
          );

          await _loadFlashcards();
        }
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
          );
        }).toList(),
      ],
    ),
  );
}

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

Future<void> _showEditDialog(
  Map<String, dynamic> card,
) async {
  final questionEdit = TextEditingController(
    text: card['question'],
  );

  final answerEdit = TextEditingController(
    text: card['answer'],
  );

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Edit Flashcard'),
        content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: questionEdit,
        decoration: const InputDecoration(
          labelText: 'Pertanyaan',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: answerEdit,
        decoration: const InputDecoration(
          labelText: 'Jawaban',
        ),
      ),
    ],
  ),
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FlashcardService.updateFlashcard(
                id: card['id'],
                question: questionEdit.text,
                answer: answerEdit.text,
              );

              await _loadFlashcards();

setState(() {
  _showAnswer = false;

  if (_currentIndex >= _cards.length) {
    _currentIndex = _cards.isEmpty
        ? 0
        : _cards.length - 1;
  }
});

if (!mounted) return;

Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

  Widget _buildBottomButton() {
    return Container(
      color: const Color(0xFFF5F6FA),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _selesaikanSesi,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDDE3EE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Color(0xFF5B7BB8), size: 20),
              SizedBox(width: 8),
              Text(
                'Selesaikan Sesi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5B7BB8)),
              ),
            ],
          ),
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