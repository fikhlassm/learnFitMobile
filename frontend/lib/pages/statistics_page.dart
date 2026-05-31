import 'package:flutter/material.dart';
import '../Services/user_daily_stats_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() =>
      _StatisticsPageState();
}

class _StatisticsPageState
    extends State<StatisticsPage> {

  int _selectedPeriod = 1;

  final List<String> _periods = [
    'Hari',
    'Minggu',
    'Bulan',
    'Tahun',
  ];

  List<dynamic> _stats = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {

    try {

      final data =
          await UserDailyStatService
              .getUserDailyStats();

      setState(() {

        _stats = data;

        _isLoading = false;

      });

    } catch (e) {

      print(e);

      setState(() {
        _isLoading = false;
      });

    }
  }

  double get _totalHours {

    double total = 0;

    for (final stat in _stats) {

      total +=
          (stat['duration_seconds'] ?? 0)
              / 3600;
    }

    return total;
  }

  List<Map<String, dynamic>>
      get _weekData {

    final days = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];

    return List.generate(7, (i) {

      final value =
          i < _stats.length
              ? ((_stats[i]
                          ['duration_seconds'] ??
                      0) /
                  14400)
              : 0.1;

      return {
        'day': days[i],
        'value':
            value.clamp(0.05, 1.0),
      };
    });
  }

  List<Map<String, dynamic>>
      get _recentActivities {

    return _stats.take(3).map((stat) {

      final duration =
          ((stat['duration_seconds'] ??
                      0) /
                  60)
              .round();

      return {
        'title':
            stat['topic'] ??
                'Study Session',

        'type':
            stat['study_method'] ??
                'Study',

        'duration':
            '$duration m',

        'status': 'SELESAI',

        'icon':
            Icons.access_time_outlined,

        'color':
            const Color(0xFF2196F3),
      };

    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      body: SafeArea(
        child: Column(
          children: [

            _buildAppBar(context),

            Expanded(
              child:
                  SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    20,
                    20,
                    20,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      _buildPeriodTabs(),

                      const SizedBox(
                          height: 20),

                      _buildTotalHoursCard(),

                      const SizedBox(
                          height: 16),

                      _buildBarChart(),

                      const SizedBox(
                          height: 20),

                      _buildSummaryRow(),

                      const SizedBox(
                          height: 24),

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

  Widget _buildAppBar(
      BuildContext context) {

    return Container(
      color: Colors.white,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),

      child: Row(
        children: [

          GestureDetector(
            onTap: () =>
                Navigator.maybePop(
                    context),

            child: const Icon(
              Icons.chevron_left,

              color:
                  Color(0xFF2196F3),

              size: 28,
            ),
          ),

          const Expanded(
            child: Text(
              'Statistik Belajar',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color:
                    Colors.black87,
              ),
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

        borderRadius:
            BorderRadius.circular(
                10),
      ),

      padding:
          const EdgeInsets.all(3),

      child: Row(
        children: List.generate(
          _periods.length,

          (i) {

            final isSelected =
                _selectedPeriod == i;

            return Expanded(
              child: GestureDetector(
                onTap: () {

                  setState(() {
                    _selectedPeriod = i;
                  });

                },

                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 9,
                  ),

                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors
                            .transparent,

                    borderRadius:
                        BorderRadius
                            .circular(
                                8),

                    boxShadow:
                        isSelected
                            ? [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                          0.07),

                                  blurRadius:
                                      5,
                                )
                              ]
                            : null,
                  ),

                  child: Text(
                    _periods[i],

                    textAlign:
                        TextAlign
                            .center,

                    style:
                        TextStyle(
                      fontSize: 13,

                      fontWeight:
                          isSelected
                              ? FontWeight
                                  .w600
                              : FontWeight
                                  .w400,

                      color: isSelected
                          ? const Color(
                              0xFF2196F3)
                          : Colors.grey[
                              500],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalHoursCard() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          'Jam Belajar Minggu Ini',

          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),

        const SizedBox(height: 4),

        Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .center,

          children: [

            Text(
              '${_totalHours.toStringAsFixed(1)} jam',

              style: const TextStyle(
                fontSize: 32,
                fontWeight:
                    FontWeight.w800,
                color:
                    Colors.black87,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 8,
                vertical: 4,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                        0xFFE8F5E9),

                borderRadius:
                    BorderRadius
                        .circular(20),
              ),

              child: const Row(
                children: [

                  Icon(
                    Icons
                        .trending_up_rounded,

                    color:
                        Color(0xFF4CAF50),

                    size: 14,
                  ),

                  SizedBox(width: 3),

                  Text(
                    '+12%',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w600,
                      color: Color(
                          0xFF4CAF50),
                    ),
                  ),
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

      padding:
          const EdgeInsets.fromLTRB(
        0,
        10,
        0,
        0,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: _weekData.map((
          data,
        ) {

          final isToday =
              data['day'] == 'Min';

          return _buildBar(
            data['day'],
            data['value'],
            isToday,
          );

        }).toList(),
      ),
    );
  }

  Widget _buildBar(
    String day,
    double value,
    bool isActive,
  ) {

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.end,

      children: [

        Expanded(
          child: Align(
            alignment:
                Alignment
                    .bottomCenter,

            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 400,
              ),

              width: 32,

              height: 120 * value,

              decoration:
                  BoxDecoration(
                color: isActive
                    ? const Color(
                        0xFF2196F3)
                    : const Color(
                        0xFFDDE8F5),

                borderRadius:
                    BorderRadius
                        .circular(6),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          day,

          style: TextStyle(
            fontSize: 11.5,

            color: isActive
                ? const Color(
                    0xFF2196F3)
                : Colors.grey[400],

            fontWeight: isActive
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {

    return Row(
      children: [

        _summaryCard(
          Icons.access_time_rounded,
          const Color(0xFF2196F3),
          'Total Waktu',
          '${_totalHours.toStringAsFixed(1)}j',
        ),

        const SizedBox(width: 12),

        _summaryCard(
          Icons.bar_chart_rounded,
          const Color(0xFF2196F3),
          'Rata-rata',
          '${(_totalHours / 7).toStringAsFixed(1)}j /hari',
        ),

        const SizedBox(width: 12),

        _summaryCard(
          Icons.trending_up_rounded,
          const Color(0xFF4CAF50),
          'Peningkatan',
          '+12%',

          valueColor:
              const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _summaryCard(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    Color? valueColor,
  }) {

    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
                  12),

          boxShadow: [

            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),

              blurRadius: 8,

              offset:
                  const Offset(0, 2),
            ),
          ],
        ),

        child: Column(
          children: [

            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),

            const SizedBox(height: 6),

            Text(
              label,

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,

              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    valueColor ??
                        Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          'Aktivitas Terkini',

          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w700,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 12),

        ..._recentActivities.map(
          (activity) =>
              _activityItem(activity),
        ),
      ],
    );
  }

  Widget _activityItem(
      Map<String, dynamic>
          activity) {

    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 10),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                12),

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 8,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: (activity['color']
                          as Color)
                      .withOpacity(0.12),

              borderRadius:
                  BorderRadius
                      .circular(12),
            ),

            child: Icon(
              activity['icon']
                  as IconData,

              color:
                  activity['color']
                      as Color,

              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  activity['title'],

                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight
                            .w600,
                    color:
                        Colors.black87,
                  ),
                ),

                const SizedBox(
                    height: 2),

                Text(
                  activity['type'],

                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors
                        .grey[500],
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,

            children: [

              Text(
                activity['duration'],

                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Colors.black87,
                ),
              ),

              const SizedBox(
                  height: 2),

              Text(
                activity['status'],

                style:
                    const TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}