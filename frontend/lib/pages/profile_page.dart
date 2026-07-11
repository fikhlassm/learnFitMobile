import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ✅ INSTANSIASI SERVICE YANG BENAR
  final _authService = AuthService();
  final _profileService = ProfileService(); 

  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;
  
  // Variabel untuk menyimpan data profil
  String _name = 'Loading...';
  // ignore: unused_field
  String _email = '';
  String _joinDate = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoadingProfile = true);

    // ✅ PANGGIL METHOD DARI ProfileService, BUKAN AuthService
    final result = await _profileService.getProfile();

    if (result['success']) {
      final data = result['data'];
      setState(() {
        _name = data['name'] ?? 'User';
        _email = data['email'] ?? '';
        // Asumsi backend mengirim field 'grade' atau sejenisnya

        
        // Format tanggal join jika ada, atau hardcode sementara
        if (data['created_at'] != null) {
           try {
            final date = DateTime.parse(data['created_at']);
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            _joinDate = 'Joined ${months[date.month - 1]} ${date.year}';
          } catch (e) {
            _joinDate = 'Joined recently';
          }
        } else {
          _joinDate = 'Joined recently';
        }
      });
    } else {
      if (!mounted) return;
      // Jika gagal, tampilkan nama default atau error
      setState(() {
        _name = 'Guest User';
      });
      // Opsional: Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal memuat profil')),
      );
    }
    
    setState(() => _isLoadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    _buildAccountSettings(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context),
                    const SizedBox(height: 16),
                    Text(
                      'LearnFit v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Profil Saya',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 46,
          backgroundColor: Colors.grey.shade200,
          child: _isLoadingProfile
              ? const CircularProgressIndicator()
              : const Icon(Icons.person, color: Colors.grey, size: 52),
        ),
        const SizedBox(height: 14),
        Text(
          _name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
              _joinDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _settingsItem(
                context,
                icon: Icons.person_outline_rounded,
                label: 'Personal Information',
                onTap: () => Navigator.pushNamed(context, '/personal-information'),
              ),
              _divider(),
              _settingsItem(
                context,
                icon: Icons.notifications_none_rounded,
                label: 'Study Reminders',
                onTap: () => Navigator.pushNamed(context, '/study-reminders'),
              ),
              _divider(),
              _settingsItem(
                context,
                icon: Icons.help_outline_rounded,
                label: 'Support Center',
                onTap: () => Navigator.pushNamed(context, '/support-center'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black54),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
      indent: 52,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade100),
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade400,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: _isLoggingOut ? null : _handleLogout,
            child: _isLoggingOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    // Logout tetap pakai AuthService
    final result = await _authService.logout();

    if (mounted) Navigator.pop(context);

    setState(() => _isLoggingOut = false);

    if (mounted) {
      if (result['success']) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Logout gagal')),
        );
      }
    }
  }
}