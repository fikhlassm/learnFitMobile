import 'package:flutter/material.dart';
import 'notebook_page.dart';

class FeynmanSessionPage extends StatefulWidget {
  final String topicTitle;

  const FeynmanSessionPage({
    super.key,
    this.topicTitle = 'Sejarah Majapahit',
  });

  @override
  State<FeynmanSessionPage> createState() => _FeynmanSessionPageState();
}

class _FeynmanSessionPageState extends State<FeynmanSessionPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _showResponse = false;
  bool _isLoading = false;
  String _responseText = '';

  static const List<String> _sampleResponses = [
    'Pemahamanmu sudah cukup baik! Kamu berhasil menjelaskan konsep utama dengan bahasa yang sederhana. Namun, ada beberapa poin yang bisa diperdalam:\n\n• Coba jelaskan lebih detail tentang sistem pemerintahan Majapahit\n• Hubungkan peran Gajah Mada dengan ekspansi wilayah\n• Tambahkan konteks tentang kejatuhan kerajaan\n\nSecara keseluruhan, pemahaman dasarmu sudah solid. Perkuat dengan detail spesifik!',
    'Penjelasanmu menunjukkan pemahaman yang kuat terhadap materi ini. Kamu mampu menyederhanakan konsep kompleks dengan baik.\n\nBeberapa saran untuk penguatan:\n• Tambahkan contoh konkret untuk mendukung penjelasanmu\n• Perhatikan urutan kronologis peristiwa\n• Coba hubungkan dengan konteks yang lebih luas\n\nTerus latih kemampuan ini — kamu sudah di jalur yang benar!',
  ];

  void _cekPemahaman() async {
    if (_notesController.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _showResponse = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _showResponse = true;
      _responseText =
          _sampleResponses[DateTime.now().second % _sampleResponses.length];
    });
  }

  void _selesaikanSesi() {
    Navigator.pop(
  context,
  true,
);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildCatatanSection(),
                  const SizedBox(height: 12),
                  _buildAddFileButton(),
                  const SizedBox(height: 12),
                  if (_isLoading) _buildLoadingCard(),
                  if (_showResponse && !_isLoading) _buildResponseCard(),
                ],
              ),
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
            child: const Icon(Icons.chevron_left,
                color: Color(0xFF2196F3), size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.topicTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildCatatanSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CATATAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Otomatis tersimpan',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _notesController,
              maxLines: 8,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87, height: 1.6),
              decoration: InputDecoration(
                hintText:
                    'Tuliskan pemahamanmu mengenai materi yang kamu pelajari...',
                hintStyle: TextStyle(
                    color: Colors.grey[400], fontSize: 14, height: 1.6),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 14),
              child: ElevatedButton(
                onPressed: _notesController.text.trim().isNotEmpty
                    ? _cekPemahaman
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text(
                  'Cek Pemahaman',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFileButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tambahkan file materi ...',
                style: TextStyle(fontSize: 13.5, color: Colors.grey[400]),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
              ),
              child: const Icon(Icons.add, size: 16, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFFE57373)),
            ),
          ),
          const SizedBox(width: 12),
          Text('Menganalisis pemahamanmu...',
              style: TextStyle(fontSize: 13.5, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildResponseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESPON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE57373),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _responseText,
            style: const TextStyle(
                fontSize: 13.5, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF5B7BB8), size: 20),
              SizedBox(width: 8),
              Text(
                'Selesaikan Sesi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B7BB8),
                ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
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
        Icon(icon,
            size: 24,
            color: isActive ? const Color(0xFF2196F3) : Colors.grey[400]),
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