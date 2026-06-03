import 'package:flutter/material.dart';
import '../services/profile_service.dart'; // Pastikan path ini benar

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _profileService = ProfileService();
  
  // Controller untuk input field
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _gradeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  // 1. FETCH DATA PROFIL DARI BACKEND
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final result = await _profileService.getProfile();

      if (result['success']) {
        final data = result['data'];
        
        // DEBUG: Cek data apa yang diterima dari backend di Terminal/Console
        print('📦 Full Data Profile: $data');
        print('🎓 Grade Value: ${data['grade']}');

        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          
          // Fallback logic: Coba ambil 'grade', jika null coba 'academic_grade', dst.
          _gradeController.text = data['grade'] ?? 
                                  data['academic_grade'] ?? 
                                  data['class_level'] ?? 
                                  ''; 
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat data')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. UPDATE DATA PROFIL KE BACKEND
  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await _profileService.updateProfile(
        name: _nameController.text.trim(),
        grade: _gradeController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perubahan berhasil disimpan!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.pop(context); // Kembali ke halaman profil
        } else {
          String errorMsg = result['message'] ?? 'Gagal menyimpan perubahan';
          
          // Cek error validasi spesifik dari backend
          if (result['errors'] != null) {
            final errors = result['errors'];
            if (errors['name'] != null) errorMsg = errors['name'][0];
            if (errors['grade'] != null) errorMsg = errors['grade'][0];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // Tampilkan Loading Indicator jika sedang fetch data
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      )
                    else
                      _buildAvatarSection(),
                      
                    const SizedBox(height: 28),
                    
                    _buildField('FULL NAME', _nameController),
                    const SizedBox(height: 14),
                    
                    // Email read-only karena identitas utama
                    _buildField('EMAIL ADDRESS', _emailController,
                        keyboardType: TextInputType.emailAddress, readOnly: true),
                    
                    const SizedBox(height: 14),
                    _buildField('ACADEMIC GRADE', _gradeController,
                        readOnly: false, showGradeIcon: true), 
                    
                    const SizedBox(height: 32),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          const Expanded(
            child: Text(
              'Personal Information',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person, color: Colors.grey, size: 50),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool showGradeIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5),
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
            keyboardType: keyboardType,
            readOnly: readOnly,
            enabled: !_isSaving, // Disable saat saving
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: showGradeIcon
                  ? Icon(Icons.school_outlined,
                      color: Colors.grey[400], size: 20)
                  : null,
            ),
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'SAVE CHANGES',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8),
              ),
      ),
    );
  }
}