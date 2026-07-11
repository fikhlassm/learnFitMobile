import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/attachment_service.dart';
import '../services/evaluation_service.dart';
import '../services/session_log_service.dart';
import '../services/study_session_service.dart';

class FeynmanSessionPage extends StatefulWidget {
  final int studySessionId;
  final String topicTitle;

  const FeynmanSessionPage({
    super.key,
    required this.studySessionId,
    this.topicTitle = 'Sejarah Majapahit',
  });

  @override
  State<FeynmanSessionPage> createState() => _FeynmanSessionPageState();
}

class _FeynmanSessionPageState extends State<FeynmanSessionPage> {
  static const int _minLogSeconds = 15;
  static const int _minNotesChars = 3;

  late final TextEditingController _titleController;
  final TextEditingController _notesController = TextEditingController();
  bool _showResponse = false;
  bool _isLoading = false;
  bool _hasLoggedSession = false;
  bool _isExiting = false;
  bool _allowPop = false;
  String _responseText = '';
  Attachment? _remoteAttachment; // persisted source file (source of truth)
  bool _isFileBusy = false; // uploading or deleting a file
  DateTime? _sessionStartedAt;

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    _titleController = TextEditingController(text: widget.topicTitle);
    _loadSessionData();
    _loadAttachment();
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
    } catch (_) {}
  }

  // Restore any file already persisted for this session so the UI reflects the
  // real backend state on re-entry (refresh, re-open, resumed session).
  Future<void> _loadAttachment() async {
    if (widget.studySessionId == 0) return;
    try {
      final attachments =
          await AttachmentService.list(widget.studySessionId);
      if (!mounted || attachments.isEmpty) return;
      setState(() => _remoteAttachment = attachments.first);
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
    if (_isFileBusy) return;
    if (widget.studySessionId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid')),
      );
      return;
    }

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

    // Upload immediately so the persisted state always matches the UI. If the
    // user leaves right after, the file is already saved (or never was).
    setState(() => _isFileBusy = true);
    try {
      // Replace any existing source: remove the old one first to avoid
      // leaving an orphaned file on the backend.
      if (_remoteAttachment != null) {
        await AttachmentService.delete(
          studySessionId: widget.studySessionId,
          attachmentId: _remoteAttachment!.id,
        );
      }
      final uploaded = await AttachmentService.upload(
        studySessionId: widget.studySessionId,
        file: file,
      );
      if (!mounted) return;
      setState(() {
        _remoteAttachment = uploaded;
        _isFileBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFileBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  // Propagate deletion to the backend so record + storage + chunks are removed
  // and no orphaned data remains. UI only clears after the server confirms.
  Future<void> _deleteFile() async {
    if (_isFileBusy || _remoteAttachment == null) return;
    if (widget.studySessionId == 0) return;

    setState(() => _isFileBusy = true);
    try {
      await AttachmentService.delete(
        studySessionId: widget.studySessionId,
        attachmentId: _remoteAttachment!.id,
      );
      if (!mounted) return;
      setState(() {
        _remoteAttachment = null;
        _isFileBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFileBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _cekPemahaman() async {
    if (_notesController.text.trim().length < _minNotesChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis minimal 3 karakter')),
      );
      return;
    }

    if (_remoteAttachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokumen sumber wajib dilampirkan terlebih dahulu'),
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
      // File already uploaded at pick time; go straight to evaluation.
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

  Future<void> _exitSession() async {
    if (_isExiting || _isLoading) return;
    _isExiting = true;

    await StudySessionService.updateStudySession(
      id: widget.studySessionId,
      content: _notesController.text,
    );

    final seconds = _sessionStartedAt == null
        ? 0
        : DateTime.now().difference(_sessionStartedAt!).inSeconds.clamp(1, 86400);

    if (!_hasLoggedSession && seconds >= _minLogSeconds) {
      _hasLoggedSession = true;
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
    }

    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.pop(context, true);
  }

  Future<void> _selesaikanSesi() => _exitSession();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _exitSession();
      },
      child: Scaffold(
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

      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: _exitSession,
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
          const SizedBox(width: 36),
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
            color: Colors.black.withValues(alpha: 0.04),
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
                  'Tersimpan saat sesi selesai',
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
                onPressed: _notesController.text.trim().length >= _minNotesChars
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
    final hasFile = _remoteAttachment != null;
    return GestureDetector(
      onTap: _isFileBusy ? null : _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE8E8E8),
          ),
        ),
        child: Row(
          children: [
            if (_isFileBusy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                hasFile ? Icons.attach_file : Icons.add,
                size: 18,
                color: hasFile
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF999999),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _remoteAttachment?.fileName ?? 'Tambahkan file materi ...',
                style: TextStyle(
                  fontSize: 13.5,
                  color: hasFile ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
            if (hasFile && !_isFileBusy)
              GestureDetector(
                onTap: _deleteFile,
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


}
