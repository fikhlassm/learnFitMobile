import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'notebook_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import '../services/flash_card_service.dart';

// ─────────────────────────── Service helpers ───────────────────────────

class _HomeApiService {
  // Gunakan localhost untuk Web, atau IP laptop/10.0.2.2 untuk emulator
  static const String _baseUrl = 'http://localhost:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await _getToken();
    if (token == null) return {};
    try {
      final res = await http.get(Uri.parse('$_baseUrl/profile'), headers: _headers(token));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetchProfile: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> fetchTodayDailyStat() async {
    final token = await _getToken();
    if (token == null) return {'total_seconds': 0};
    try {
      final res = await http.get(Uri.parse('$_baseUrl/user-daily-stats'), headers: _headers(token));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>;
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final match = list.cast<Map<String, dynamic>>().firstWhere(
              (e) => e['date'] == todayStr,
              orElse: () => {},
            );
        return match;
      }
    } catch (e) {
      print('Error fetchDailyStat: $e');
    }
    return {'total_seconds': 0};
  }
}

// ─────────────────────────── HomePage ───────────────────────────

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(onNavTap: _onNavTap),
      NotebookPage(onSwitchToTab: (i) => setState(() => _selectedIndex = i)),
      const StatisticsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ═══════════════════════════ Bottom Nav ═══════════════════════════

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
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
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', isActive: selectedIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.article_outlined, activeIcon: Icons.article_rounded, label: 'Notebook', isActive: selectedIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.track_changes_outlined, activeIcon: Icons.track_changes_rounded, label: 'Goals', isActive: selectedIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', isActive: selectedIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 24, color: isActive ? const Color(0xFF2196F3) : Colors.grey[400]),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? const Color(0xFF2196F3) : Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════ Home Content ═══════════════════════════

class _HomeContent extends StatefulWidget {
  final ValueChanged<int> onNavTap;
  const _HomeContent({required this.onNavTap});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _loading = true;
  String _userName = '';
  String _streak = '-';
  String _dailyFocus = '-';
  String _masteryCount = '-';

  // Progress: berapa menit sudah belajar hari ini & target user
  int _studiedMinutes = 0;
  int _targetMinutes = 0; // 0 = belum diset

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _loadSavedTarget();
  }

  // ── Simpan & muat target dari SharedPreferences ──────────────────────

  Future<void> _loadSavedTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    // Hanya pakai target yang disimpan untuk hari ini
    final savedDate = prefs.getString('target_date') ?? '';
    if (savedDate == todayStr) {
      final saved = prefs.getInt('target_minutes') ?? 0;
      if (mounted) setState(() => _targetMinutes = saved);
    }
  }

  Future<void> _saveTarget(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await prefs.setInt('target_minutes', minutes);
    await prefs.setString('target_date', todayStr);
  }

  // ── Load data API ────────────────────────────────────────────────────

  Future<void> _loadHomeData() async {
    try {
      // Fetch Paralel: Profile, Daily Stats, DAN Total Flashcards
      // getTotalFlashcards() tidak butuh parameter token
      final results = await Future.wait([
        _HomeApiService.fetchProfile(),
        _HomeApiService.fetchTodayDailyStat(),
        FlashcardService.getTotalFlashcards(),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final dailyStat = results[1] as Map<String, dynamic>;
      final totalCards = results[2] as int;

      if (!mounted) return;

      setState(() {
        // Name
        _userName = (profile['name'] ?? '').toString().split(' ').first;

        // Streak
        _streak = '${profile['current_streak'] ?? 0} Hari';

        // Daily Focus (konversi detik → menit)
        final totalSeconds = dailyStat['total_seconds'];
        final minutes = totalSeconds != null ? (totalSeconds as num).toInt() ~/ 60 : 0;
        _studiedMinutes = minutes;

        if (minutes >= 60) {
          final h = minutes ~/ 60;
          final m = minutes % 60;
          _dailyFocus = m > 0 ? '${h}j ${m}m' : '${h}j';
        } else {
          _dailyFocus = '${minutes}m';
        }

        // Mastery
        _masteryCount = '$totalCards Cards';

        _loading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Dialog set target ────────────────────────────────────────────────

  void _showSetTargetDialog() {
    final hoursCtrl = TextEditingController(
      text: _targetMinutes > 0 ? (_targetMinutes ~/ 60).toString() : '',
    );
    final minutesCtrl = TextEditingController(
      text: _targetMinutes > 0 ? (_targetMinutes % 60).toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Set Target Belajar Hari Ini',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Berapa jam kamu akan belajar hari ini?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Jam',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: TextField(
                    controller: minutesCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Menit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final h = int.tryParse(hoursCtrl.text.trim()) ?? 0;
              final m = int.tryParse(minutesCtrl.text.trim()) ?? 0;
              final total = h * 60 + m;
              if (total > 0) {
                setState(() => _targetMinutes = total);
                _saveTarget(total);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 6),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildProgressCard(context),
              const SizedBox(height: 20),
              _buildRecommendationSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _loading
                    ? _shimmer(width: 100, height: 16)
                    : Text(
                        'Hi, ${_userName.isNotEmpty ? _userName : 'Pengguna'}!',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                const SizedBox(height: 2),
                const Text('Bagaimana kabarmu hari ini?', style: TextStyle(fontSize: 12.5, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard(Icons.local_fire_department_rounded, const Color(0xFFFF7043), 'Streak', _loading ? null : _streak),
          const SizedBox(width: 12),
          _statCard(Icons.access_time_rounded, const Color(0xFF2196F3), 'Daily Focus', _loading ? null : _dailyFocus),
          const SizedBox(width: 12),
          _statCard(Icons.auto_awesome_rounded, const Color(0xFF9C27B0), 'Mastery', _loading ? null : _masteryCount),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String label, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            value == null
                ? _shimmer(width: 48, height: 14)
                : Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // ── Progress Card ────────────────────────────────────────────────────

  Widget _buildProgressCard(BuildContext context) {
    final double progress = _targetMinutes > 0
        ? (_studiedMinutes / _targetMinutes).clamp(0.0, 1.0)
        : 0.0;
    final int pct = (progress * 100).round();

    final int remainingMin = (_targetMinutes - _studiedMinutes).clamp(0, 99999);
    final String remainingLabel = _targetMinutes == 0
        ? 'Target belum diset'
        : remainingMin == 0
            ? 'Target tercapai! 🎉'
            : remainingMin >= 60
                ? 'TERSISA ${remainingMin ~/ 60}J ${remainingMin % 60 > 0 ? '${remainingMin % 60}M' : ''}'
                : 'TERSISA ${remainingMin}M';

    final String progressLabel = _targetMinutes == 0
        ? 'Set target dulu untuk mulai tracking'
        : pct >= 100
            ? 'Kamu sudah mencapai target hari ini!'
            : 'Kamu Mencapai $pct% Target Harian!';

    // Format label target
    String targetLabel = '';
    if (_targetMinutes > 0) {
      final th = _targetMinutes ~/ 60;
      final tm = _targetMinutes % 60;
      targetLabel = th > 0 && tm > 0 ? '${th}j ${tm}m' : th > 0 ? '${th}j' : '${tm}m';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress Hari Ini',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(progressLabel, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
            const SizedBox(height: 14),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 10),
            // Info baris bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _targetMinutes > 0
                      ? 'FOKUS: $_dailyFocus / $targetLabel'
                      : 'FOKUS HARI INI: $_dailyFocus',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
                ),
                Text(remainingLabel, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85))),
              ],
            ),
            const SizedBox(height: 14),
            // Tombol set / ubah target
            GestureDetector(
              onTap: _showSetTargetDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flag_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _targetMinutes > 0 ? 'Ubah Target Hari Ini' : 'Set Target Hari Ini',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recommendation Section ───────────────────────────────────────────

  Widget _buildRecommendationSection(BuildContext context) {
    final techniques = [

  _TechniqueData(
    icon: Icons.timer_outlined,
    color: const Color(0xFF2196F3),
    title: 'Pomodoro',
    subtitle:
        'Bagi belajar ke dalam sesi fokus 25 menit diselingi istirahat singkat.',
    onTap: () => Navigator.pushNamed(
      context,
      '/new-note',
      arguments: {'preselectedMethod': 'Pomodoro'},
    ),
  ),

  _TechniqueData(
    icon:
        Icons.psychology_outlined,
    color:
        const Color(0xFF2E7D32),
    title: 'Active Recall',
    subtitle:
        'Latih daya ingat dengan menjawab pertanyaan tanpa melihat catatan.',
    onTap: () => Navigator.pushNamed(
      context,
      '/new-note',
      arguments: {'preselectedMethod': 'Active Recall'},
    ),
  ),

  _TechniqueData(
    icon:
        Icons.edit_note_outlined,
    color:
        const Color(0xFFFF7043),
    title: 'Blurting',
    subtitle:
        'Tulis semua yang kamu ingat tentang suatu topik secepat mungkin.',
    onTap: () => Navigator.pushNamed(
      context,
      '/new-note',
      arguments: {'preselectedMethod': 'Blurting'},
    ),
  ),

  _TechniqueData(
    icon:
        Icons.school_outlined,
    color:
        const Color(0xFF9C27B0),
    title: 'Feynman',
    subtitle:
        'Kuasai materi dengan menjelaskannya menggunakan bahasa sederhana.',
    onTap: () => Navigator.pushNamed(
      context,
      '/new-note',
      arguments: {'preselectedMethod': 'Feynman Technique'},
    ),
  ),
];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Teknik Belajar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          ...techniques.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _recCard(context, data: t),
              )),
        ],
      ),
    );
  }

  Widget _recCard(BuildContext context, {required _TechniqueData data}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: data.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(data.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: data.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: data.color, borderRadius: BorderRadius.circular(20)),
              child: const Text('Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer placeholder ──────────────────────────────────────────────

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
    );
  }
}

// ═══════════════════════════ Data model ═══════════════════════════

class _TechniqueData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _TechniqueData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}