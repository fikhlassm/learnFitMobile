import 'package:flutter/material.dart';

class StudyRemindersPage extends StatefulWidget {
  const StudyRemindersPage({super.key});

  @override
  State<StudyRemindersPage> createState() => _StudyRemindersPageState();
}

class _StudyRemindersPageState extends State<StudyRemindersPage> {
  bool _dailyTargetEnabled = true;
  bool _streakReminderEnabled = true;
  bool _smartNotifEnabled = false;
  int _selectedFrequency = 0; // 0=Setiap hari, 1=Hari kerja
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  final List<String> _frequencies = ['Setiap hari', 'Hari kerja'];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
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
            color: Colors.black.withOpacity(0.04),
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
          Divider(height: 1, color: Colors.grey.shade100),
          _reminderToggle(
            title: 'Notifikasi Pintar',
            subtitle: 'Dorongan\nberbasis AI',
            value: _smartNotifEnabled,
            onChanged: (val) => setState(() => _smartNotifEnabled = val),
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
            activeColor: const Color(0xFF2196F3),
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
            color: Colors.black.withOpacity(0.04),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengingat berhasil disimpan!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
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