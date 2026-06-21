import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/attachment_service.dart';
import '../services/evaluation_service.dart';
import '../services/session_log_service.dart';
import '../services/study_session_service.dart';

class BlurtingSessionPage extends StatefulWidget {
  final int studySessionId;
  final String topicTitle;

  const BlurtingSessionPage({
    super.key,
    required this.studySessionId,
    this.topicTitle = 'Struktur Sel',
  });

  @override
  State<BlurtingSessionPage> createState() => _BlurtingSessionPageState();
}

class _BlurtingSessionPageState extends State<BlurtingSessionPage> {
  late final TextEditingController _titleController;
  final TextEditingController _notesController = TextEditingController();
  bool _showResponse = false;
  bool _isLoading = false;
  String _responseText = '';
  File? _attachedFile;
  String? _attachedFileName;
  DateTime? _sessionStartedAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topicTitle);
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    if (widget.studySessionId == 0) return;
    try {
      final session = await StudySessionService.getStudySession(
        widget.studySessionId,
      );
      final data = session['data'] ?? session;
      setState(() {
        _notesController.text = data['content'] ?? '';
      });
      if (mounted) _sessionStartedAt = DateTime.now();
    } catch (_) {}
  }

  void _saveTitle() {
    if (widget.studySessionId == 0) return;
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.topicTitle) {
      StudySessionService.updateStudySession(
        id: widget.studySessionId,
        topic: newTitle,
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final size = await file.length();
    if (size > 51200 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran file maksimal 50 MB')),
      );
      return;
    }
    setState(() {
      _attachedFile = file;
      _attachedFileName = result.files.single.name;
    });
  }

  Future<void> _cekHafalan() async {
    if (_notesController.text.trim().isEmpty) return;

    if (_attachedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokumen materi asli wajib dilampirkan terlebih dahulu'),
        ),
      );
      return;
    }

    if (widget.studySessionId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponse = false;
    });

    try {
      await AttachmentService.upload(
        studySessionId: widget.studySessionId,
        file: _attachedFile!,
      );

      final feedback = await EvaluationService.evaluate(
        studySessionId: widget.studySessionId,
        text: _notesController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showResponse = true;
        _responseText = feedback;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _selesaikanSesi() async {
    if (_isLoading) return;
    await StudySessionService.updateStudySession(
      id: widget.studySessionId,
      content: _notesController.text,
    );

    final seconds = _sessionStartedAt == null
        ? 1
        : DateTime.now().difference(_sessionStartedAt!).inSeconds.clamp(1, 86400);

    try {
      await SessionLogService.createSessionLog(
        studySessionId: widget.studySessionId,
        durationSeconds: seconds,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan waktu')),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
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
            child: TextField(
              controller: _titleController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _saveTitle(),
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
                    'Tuliskan hal apa saja yang kamu ketahui mengenai materi ini...',
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
                    ? _cekHafalan
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                child: const Text(
                  'Cek Hafalan',
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
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _attachedFile != null
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE8E8E8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _attachedFile != null ? Icons.attach_file : Icons.add,
              size: 18,
              color: _attachedFile != null
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF999999),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _attachedFileName ?? 'Tambahkan file materi ...',
                style: TextStyle(
                  fontSize: 13.5,
                  color: _attachedFile != null
                      ? Colors.black87
                      : Colors.grey[400],
                ),
              ),
            ),
            if (_attachedFile != null)
              GestureDetector(
                onTap: () => setState(() {
                  _attachedFile = null;
                  _attachedFileName = null;
                }),
                child: const Icon(Icons.close, size: 18, color: Colors.red),
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
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
            ),
          ),
          const SizedBox(width: 12),
          Text('Mengecek hafalanmu...',
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
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESPON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE65100),
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
