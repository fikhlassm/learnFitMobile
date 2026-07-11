import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/reminder_notification_service.dart';

class StudyRemindersPage extends StatefulWidget {
  const StudyRemindersPage({super.key});

  @override
  State<StudyRemindersPage> createState() => _StudyRemindersPageState();
}

class _StudyRemindersPageState extends State<StudyRemindersPage> {
  bool _dailyTargetEnabled = true;
  bool _streakReminderEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedFrequency = 0; // 0=Setiap hari, 1=Hari kerja
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  final List<String> _frequencies = ['Setiap hari', 'Hari kerja'];

  static const _dailyTargetKey = 'reminders_daily_target_enabled';
  static const _streakKey = 'reminders_streak_enabled';
  static const _frequencyKey = 'reminders_frequency';
  static const _hourKey = 'reminders_time_hour';
  static const _minuteKey = 'reminders_time_minute';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dailyTargetEnabled = prefs.getBool(_dailyTargetKey) ?? true;
      _streakReminderEnabled = prefs.getBool(_streakKey) ?? true;
      _selectedFrequency = prefs.getInt(_frequencyKey) ?? 0;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt(_hourKey) ?? 20,
        minute: prefs.getInt(_minuteKey) ?? 0,
      );
      _isLoading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveReminderSettings() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dailyTargetKey, _dailyTargetEnabled);
      await prefs.setBool(_streakKey, _streakReminderEnabled);
      await prefs.setInt(_frequencyKey, _selectedFrequency);
      await prefs.setInt(_hourKey, _reminderTime.hour);
      await prefs.setInt(_minuteKey, _reminderTime.minute);

      final notifications = ReminderNotificationService.instance;
      await notifications.init();
      await notifications.cancelAll();

      if (_dailyTargetEnabled || _streakReminderEnabled) {
        final granted = await notifications.requestPermission();
        if (!granted) {
          throw Exception('Izin notifikasi ditolak');
        }

        final weekdaysOnly = _selectedFrequency == 1;
        if (_dailyTargetEnabled) {
          await notifications.scheduleDailyTarget(
            hour: _reminderTime.hour,
            minute: _reminderTime.minute,
            weekdaysOnly: weekdaysOnly,
            includeStreakCopy: _streakReminderEnabled,
          );
        } else {
          await notifications.scheduleStreakOnly(
            hour: _reminderTime.hour,
            minute: _reminderTime.minute,
            weekdaysOnly: weekdaysOnly,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil disimpan!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengingat: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(),
                        )
                      else ...[
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('PENGINGAT AKTIF'),
                        const SizedBox(height: 10),
                        _buildRemindersCard(),
                        const SizedBox(height: 24),
                        _buildSectionLabel('FREKUENSI PENGINGAT'),
                        const SizedBox(height: 10),
                        _buildFrequencyCard(),
                        const SizedBox(height: 32),
                        _buildSaveButton(context),
                      ],
                    ],
                  ),
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
              'Study Reminders',
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_rounded,
              color: Color(0xFF2196F3), size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jangan Lewatkan Sesi',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'Sesuaikan preferensi notifikasi Anda untuk\ntetap pada jalur tujuan belajar Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.6),
      ),
    );
  }

  Widget _buildRemindersCard() {
    return Container(
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
          _reminderToggle(
            title: 'Target Belajar Harian',
            subtitle: 'Dijadwalkan untuk\n${_reminderTime.format(context)}',
            subtitleColor: const Color(0xFF2196F3),
            value: _dailyTargetEnabled,
            onChanged: (val) => setState(() => _dailyTargetEnabled = val),
            onSubtitleTap: _pickTime,
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          _reminderToggle(
            title: 'Pengingat Streak',
            subtitle: 'Jangan hentikan\nkemajuan Anda',
            value: _streakReminderEnabled,
            onChanged: (val) => setState(() => _streakReminderEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _reminderToggle({
    required String title,
    required String subtitle,
    Color? subtitleColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onSubtitleTap,
  }) {
    final subtitleText = Text(
      subtitle,
      style: TextStyle(
          fontSize: 12,
          color: subtitleColor ?? Colors.grey[500],
          height: 1.4),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 3),
                if (onSubtitleTap != null)
                  InkWell(onTap: onSubtitleTap, child: subtitleText)
                else
                  subtitleText,
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyCard() {
    return Container(
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
        children: List.generate(_frequencies.length, (i) {
          final isLast = i == _frequencies.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _selectedFrequency = i),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_frequencies[i],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: _selectedFrequency == i
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: Colors.black87)),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedFrequency == i
                                ? const Color(0xFF2196F3)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: _selectedFrequency == i
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveReminderSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'SIMPAN PENGINGAT',
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
