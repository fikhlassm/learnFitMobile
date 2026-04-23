import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedPeriod = 1; // 0=Hari, 1=Minggu, 2=Bulan, 3=Tahun

  final List<String> _periods = ['Hari', 'Minggu', 'Bulan', 'Tahun'];

  final List<Map<String, dynamic>> _weekData = [
    {'day': 'Sen', 'value': 0.45},
    {'day': 'Sel', 'value': 0.55},
    {'day': 'Rab', 'value': 0.3},
    {'day': 'Kam', 'value': 0.4},
    {'day': 'Jum', 'value': 0.2},
    {'day': 'Sab', 'value': 0.15},
    {'day': 'Min', 'value': 0.95},
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'Fungsi Eksponensial',
      'type': 'Pomodoro',
      'duration': '2j 0m',
      'status': 'SELESAI',
      'icon': Icons.calculate_outlined,
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Struktur Sel',
      'type': 'Active Recall',
      'duration': '45m',
      'status': 'SELESAI',
      'icon': Icons.science_outlined,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Gerak Melingkar',
      'type': 'Feynman',
      'duration': '1j 15m',
      'status': 'SELESAI',
      'icon': Icons.speed_outlined,
      'color': Color(0xFFFF7043),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodTabs(),
                    const SizedBox(height: 20),
                    _buildTotalHoursCard(),
                    const SizedBox(height: 16),
                    _buildBarChart(),
                    const SizedBox(height: 20),
                    _buildSummaryRow(),
                    const SizedBox(height: 24),
                    _buildRecentActivities(),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.chevron_left, color: Color(0xFF2196F3), size: 28),
          ),
          const Expanded(
            child: Text(
              'Statistik Belajar',
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

  Widget _buildPeriodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(_periods.length, (i) {
          final isSelected = _selectedPeriod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 5,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _periods[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF2196F3) : Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTotalHoursCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jam Belajar Minggu Ini',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '24.5 jam',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up_rounded,
                      color: Color(0xFF4CAF50), size: 14),
                  SizedBox(width: 3),
                  Text('+12%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _weekData.map((data) {
          final isToday = data['day'] == 'Min';
          return _buildBar(data['day'], data['value'], isToday);
        }).toList(),
      ),
    );
  }

  Widget _buildBar(String day, double value, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 32,
              height: 120 * value,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2196F3)
                    : const Color(0xFFDDE8F5),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day,
            style: TextStyle(
                fontSize: 11.5,
                color: isActive ? const Color(0xFF2196F3) : Colors.grey[400],
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400)),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryCard(Icons.access_time_rounded, const Color(0xFF2196F3),
            'Total Waktu', '24j 30m'),
        const SizedBox(width: 12),
        _summaryCard(Icons.bar_chart_rounded, const Color(0xFF2196F3),
            'Rata-rata', '3.5j /hari'),
        const SizedBox(width: 12),
        _summaryCard(Icons.trending_up_rounded, const Color(0xFF4CAF50),
            'Peningkatan', '+12%', valueColor: const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _summaryCard(IconData icon, Color iconColor, String label, String value,
      {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terkini',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),
        ..._recentActivities.map((activity) => _activityItem(activity)),
      ],
    );
  }

  Widget _activityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity['icon'] as IconData,
                color: activity['color'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(activity['type'],
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(activity['duration'],
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const SizedBox(height: 2),
              Text(activity['status'],
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50))),
            ],
          ),
        ],
      ),
    );
  }
}