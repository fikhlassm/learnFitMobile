import 'package:flutter/material.dart';
import '../services/user_daily_stats_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedPeriod = 1;
  // PERBAIKAN: Hapus 'Tahun' dari list periode
  final List<String> _periods = ['Hari', 'Minggu', 'Bulan'];

  List<dynamic> _allStats = [];
  List<dynamic> _filteredStats = [];
  bool _isLoading = true;
  bool _showAllActivities = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await UserDailyStatService.getUserDailyStats();
      
      if (mounted) {
        setState(() {
          _allStats = data ?? []; 
          _applyFilter(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load Stats Error: $e');
      if (mounted) {
        setState(() {
          _allStats = [];
          _filteredStats = [];
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    
    if (_allStats.isEmpty) {
      _filteredStats = [];
      return;
    }

    switch (_selectedPeriod) {
      case 0: // HARI INI
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        _filteredStats = _allStats.where((stat) {
          return (stat['date']?.toString() ?? '') == todayStr;
        }).toList();
        break;
        
      case 1: // MINGGU INI
        final sevenDaysAgo = now.subtract(const Duration(days: 6));
        _filteredStats = _allStats.where((stat) {
          final dateStr = stat['date']?.toString() ?? '';
          if (dateStr.isEmpty) return false;
          try {
            final statDate = DateTime.parse(dateStr);
            return statDate.isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) && 
                   statDate.isBefore(now.add(const Duration(days: 1)));
          } catch (_) { return false; }
        }).toList();
        break;
        
      case 2: // BULAN INI
        _filteredStats = _allStats.where((stat) {
          final dateStr = stat['date']?.toString() ?? '';
          if (dateStr.isEmpty) return false;
          try {
            final statDate = DateTime.parse(dateStr);
            return statDate.year == now.year && statDate.month == now.month;
          } catch (_) { return false; }
        }).toList();
        break;
        
      // PERBAIKAN: Case 3 (Tahun) dihapus karena tidak ada lagi di list _periods
        
      default:
        _filteredStats = _allStats;
    }
  }

  double get _totalHours {
    double total = 0;
    for (final stat in _filteredStats) { 
      total += ((stat['duration_seconds'] ?? stat['total_seconds'] ?? 0) as num) / 3600;
    }
    return total;
  }

  // ponytail: full _allStats scan per period switch — fine for a single user with O(months) of data; switch to SQL aggregation if it grows
  double get _previousPeriodHours {
    if (_allStats.isEmpty) return 0;
    final now = DateTime.now();

    double sumRange(DateTime from, DateTime to) {
      double total = 0;
      for (final stat in _allStats) {
        final dateStr = stat['date']?.toString() ?? '';
        if (dateStr.isEmpty) continue;
        try {
          final d = DateTime.parse(dateStr);
          if (!d.isBefore(from) && d.isBefore(to)) {
            total += ((stat['duration_seconds'] ?? stat['total_seconds'] ?? 0) as num).toDouble();
          }
        } catch (_) {}
      }
      return total / 3600;
    }

    switch (_selectedPeriod) {
      case 0: // Hari: kemarin
        final yesterday = now.subtract(const Duration(days: 1));
        final yStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
        double total = 0;
        for (final stat in _allStats) {
          if (stat['date']?.toString() == yStr) {
            total += ((stat['duration_seconds'] ?? stat['total_seconds'] ?? 0) as num).toDouble();
          }
        }
        return total / 3600;
      case 1: // Minggu: 7 hari sebelum minggu ini
        return sumRange(now.subtract(const Duration(days: 13)), now.subtract(const Duration(days: 6)));
      case 2: // Bulan: bulan sebelumnya
        final prevMonth = now.month == 1 ? DateTime(now.year - 1, 12, 1) : DateTime(now.year, now.month - 1, 1);
        return sumRange(prevMonth, DateTime(prevMonth.year, prevMonth.month + 1, 1));
      default:
        return 0;
    }
  }

  String get _peningkatanText {
    final prev = _previousPeriodHours;
    if (prev <= 0) {
      if (_totalHours > 0) return 'Baru';
      return '0%';
    }
    final pct = ((_totalHours - prev) / prev * 100).round();
    return '${pct >= 0 ? '+' : ''}$pct%';
  }

  bool get _isPositivePeningkatan => _totalHours >= _previousPeriodHours;

  List<Map<String, dynamic>> get _bars {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();

    double sec(dynamic stat) =>
        ((stat['duration_seconds'] ?? stat['total_seconds'] ?? 0) as num).toDouble();

    if (_allStats.isEmpty) {
      switch (_selectedPeriod) {
        case 0:
          return [
            {'label': days[now.weekday - 1], 'value': 0.05, 'isActive': true}
          ];
        case 1:
          return List.generate(
              7, (i) => {'label': days[i], 'value': 0.05, 'isActive': i == now.weekday - 1});
        case 2:
          final lastDay = DateTime(now.year, now.month + 1, 0).day;
          return List.generate(
              6,
              (i) => {
                    'label': i == 5 ? '26-$lastDay' : '${i * 5 + 1}-${(i + 1) * 5}',
                    'value': 0.05,
                    'isActive': false,
                  });
        default:
          return [];
      }
    }

    switch (_selectedPeriod) {
      case 0: // HARI: 1 bar
        final total = _filteredStats.fold<double>(0, (s, st) => s + sec(st));
        return [
          {
            'label': days[now.weekday - 1],
            'value': (total / 14400).clamp(0.05, 1.0),
            'isActive': true,
          }
        ];

      case 1: // MINGGU: 7 bars aggregated by weekday
        final byDay = List<double>.filled(7, 0.0);
        for (final stat in _filteredStats) {
          final dateStr = stat['date']?.toString() ?? '';
          if (dateStr.isEmpty) continue;
          try {
            final d = DateTime.parse(dateStr);
            byDay[d.weekday - 1] += sec(stat);
          } catch (_) {}
        }
        return List.generate(7, (i) => {
              'label': days[i],
              'value': (byDay[i] / 14400).clamp(0.05, 1.0),
              'isActive': i == now.weekday - 1,
            });

      case 2: // BULAN: 6 buckets of ~5 days
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        final bucketTotals = List<double>.filled(6, 0.0);
        for (final stat in _filteredStats) {
          final dateStr = stat['date']?.toString() ?? '';
          if (dateStr.isEmpty) continue;
          try {
            final d = DateTime.parse(dateStr);
            if (d.year != now.year || d.month != now.month) continue;
            final bucket = ((d.day - 1) ~/ 5).clamp(0, 5);
            bucketTotals[bucket] += sec(stat);
          } catch (_) {}
        }
        final todayBucket = ((now.day - 1) ~/ 5).clamp(0, 5);
        return List.generate(6, (i) => {
              'label': i == 5 ? '26-$lastDay' : '${i * 5 + 1}-${(i + 1) * 5}',
              'value': (bucketTotals[i] / 14400).clamp(0.05, 1.0),
              'isActive': i == todayBucket,
            });

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
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
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(_periods.length, (i) { // Otomatis jadi 3 tab
          final isSelected = _selectedPeriod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = i;
                  _applyFilter(); 
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 5)] : null,
                ),
                child: Text(_periods[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF2196F3) : Colors.grey[500])),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.maybePop(context), child: const Icon(Icons.chevron_left, color: Color(0xFF2196F3), size: 28)),
          const Expanded(child: Text('Statistik Belajar', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87))),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTotalHoursCard() {
    final isPositive = _isPositivePeningkatan;
    final pillColor = isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final accentColor = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final pillIcon =
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jam Belajar ${_periods[_selectedPeriod]} Ini',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${_totalHours.toStringAsFixed(1)} jam',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration:
                  BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(pillIcon, color: accentColor, size: 14),
                const SizedBox(width: 3),
                Text(_peningkatanText,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor))
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final bars = _bars;
    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bars.map((data) {
          return _buildBar(
              data['label'] as String, data['value'] as double, data['isActive'] as bool);
        }).toList(),
      ),
    );
  }

  Widget _buildBar(String day, double value, bool isActive) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 32,
              height: 120 * value,
              decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2196F3) : const Color(0xFFDDE8F5),
                  borderRadius: BorderRadius.circular(6))),
        ),
      ),
      const SizedBox(height: 8),
      Text(day,
          style: TextStyle(
              fontSize: 11.5,
              color: isActive ? const Color(0xFF2196F3) : Colors.grey[400],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }

  Widget _buildSummaryRow() {
    final avgHours = _filteredStats.isNotEmpty ? _totalHours / _filteredStats.length : 0;
    final isPositive = _isPositivePeningkatan;
    final accColor = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Row(
      children: [
        _summaryCard(Icons.access_time_rounded, const Color(0xFF2196F3), 'Total Waktu',
            '${_totalHours.toStringAsFixed(1)}j'),
        const SizedBox(width: 12),
        _summaryCard(Icons.bar_chart_rounded, const Color(0xFF2196F3), 'Rata-rata',
            '${avgHours.toStringAsFixed(1)}j /hari'),
        const SizedBox(width: 12),
        _summaryCard(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            accColor, 'Peningkatan', _peningkatanText,
            valueColor: accColor),
      ],
    );
  }

  Widget _summaryCard(IconData icon, Color iconColor, String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey[500])), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? Colors.black87))]),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final list = _showAllActivities ? _activitiesFrom(_filteredStats) : _activitiesFrom(_filteredStats.take(3).toList());
    final canExpand = _filteredStats.length > 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Aktivitas Terkini',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ),
            if (canExpand)
              GestureDetector(
                onTap: () => setState(() => _showAllActivities = !_showAllActivities),
                child: Text(
                  _showAllActivities ? 'Tutup' : 'Lihat Semua',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Center(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Belum ada aktivitas di periode ini',
                      style: TextStyle(color: Colors.grey[400]))))
        else
          ...list.map((activity) => _activityItem(activity)),
      ],
    );
  }

  List<Map<String, dynamic>> _activitiesFrom(Iterable<dynamic> stats) {
    return stats.map((stat) {
      final seconds = (stat['duration_seconds'] ?? stat['total_seconds'] ?? 0) as num;
      final duration = (seconds / 60).round();
      return {
        'title': stat['topic'] ?? 'Study Session',
        'type': stat['study_technique_name'] ??
            stat['method_name'] ??
            stat['study_method'] ??
            'Pomodoro',
        'duration': '$duration m',
        'status': 'SELESAI',
        'icon': Icons.access_time_outlined,
        'color': const Color(0xFF2196F3),
      };
    }).toList();
  }

  Widget _activityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: (activity['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activity['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 2), Text(activity['type'], style: TextStyle(fontSize: 11.5, color: Colors.grey[500]))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(activity['duration'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 2), Text(activity['status'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)))]),
        ],
      ),
    );
  }
}