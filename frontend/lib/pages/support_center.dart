import 'package:flutter/material.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactUs(context),
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
              'Support Center',
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

  Widget _buildContactUs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
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
              _contactItem(
                icon: Icons.email_outlined,
                label: 'Email Support',
                onTap: () => _showEmailSheet(context),
              ),
              Divider(height: 1, color: Colors.grey.shade100, indent: 54),
              _contactItem(
                icon: Icons.quiz_outlined,
                label: 'FAQ',
                onTap: () => _showFAQSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactItem({
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
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _showEmailSheet(BuildContext context) {
    final messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email Support',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Kami akan membalas dalam 24 jam.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey[500])),
            const SizedBox(height: 20),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tulis pesanmu...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Kirim',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQSheet(BuildContext context) {
    final faqs = [
      {
        'q': 'Metode belajar apa saja yang tersedia?',
        'a': 'LearnFit mendukung Pomodoro, Feynman, Active Recall, dan Blurting.',
      },
      {
        'q': 'Bagaimana cara mengatur pengingat belajar?',
        'a': 'Buka Study Reminders, atur toggle, waktu, dan frekuensi, lalu tekan Simpan Pengingat.',
      },
      {
        'q': 'Apa fungsi Study Reminders?',
        'a': 'Study Reminders menyimpan preferensi pengingat di perangkat dan dapat menjadwalkan notifikasi berdasarkan waktu serta frekuensi yang dipilih.',
      },
      {
        'q': 'Bagaimana cara saya menggunakan evaluasi AI?',
        'a': 'Upload file materi terlebih dahulu jika ada. Setelah itu, ketik catatanmu di notebook. Pada sesi Feynman, tekan Cek Pemahaman. Pada sesi Blurting, tekan Cek Hafalan.',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FAQ',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...faqs.map((faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(faq['q']!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(faq['a']!,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey[500],
                                height: 1.5)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}