import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),

            // ── Top Bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LearnFit',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
    
              ],
            ),

            const SizedBox(height: 20),

            // ── Card 1: Forest ──
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/intro2_forest.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ForestPlaceholder(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Dapatkan Rekomendasi\nMetode Belajar',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Sesuaikan cara belajarmu dengan gaya unik yang paling efektif untukmu. Temukan teknik Pomodoro, Feynman, atau Mind Mapping yang pas.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            // ── Card 2: Graph ──
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/intro2_graph.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _GraphPlaceholder(),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Pantau Efektivitas Belajarmu',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Lihat grafik kemajuanmu setiap hari. Pantau seberapa lama kamu fokus dan materi apa saja yang sudah kamu kuasai.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // ── Tombol Mulai ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
                 },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Bergabunglah dengan 50.000+ kawannya',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── Placeholders ──

class _ForestPlaceholder extends StatelessWidget {
  const _ForestPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF80DEEA), Color(0xFF1B5E20)],
        ),
      ),
      child: CustomPaint(
        painter: _ForestPainter(),
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white70, size: 28),
                SizedBox(width: 8),
                Icon(Icons.person, color: Colors.white, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF1B5E20),
      const Color(0xFF2E7D32),
      const Color(0xFF388E3C),
    ];
    final positions = [0.05, 0.18, 0.3, 0.55, 0.68, 0.8, 0.92];
    final heights = [0.7, 0.85, 0.75, 0.8, 0.9, 0.72, 0.78];

    for (int i = 0; i < positions.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      final x = size.width * positions[i];
      final topY = size.height * (1 - heights[i]);
      final path = Path()
        ..moveTo(x, topY)
        ..lineTo(x - 18, size.height * 0.85)
        ..lineTo(x + 18, size.height * 0.85)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GraphPlaceholder extends StatelessWidget {
  const _GraphPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: const Color(0xFF1A1A2E),
      child: CustomPaint(
        painter: _GraphPainter(),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white60, size: 48),
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.6,
        size.width * 0.85,
        size.height * 0.2,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFB300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}