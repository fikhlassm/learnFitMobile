import 'dart:async';
import 'package:flutter/material.dart';
import '../Services/session_log_service.dart';
import 'notebook_page.dart';

class PomodoroSessionPage extends StatefulWidget {
  final String topicTitle;

  const PomodoroSessionPage({
    super.key,
    this.topicTitle = 'Fungsi Eksponensial',
  });

  @override
  State<PomodoroSessionPage> createState() =>
      _PomodoroSessionPageState();
}

class _PomodoroSessionPageState
    extends State<PomodoroSessionPage>
    with TickerProviderStateMixin {

  static const int _totalSessions = 4;

  static const int _workDuration =
      25 * 60;

  int _currentSession = 1;

  int _remainingSeconds =
      _workDuration;

  bool _isRunning = false;

  Timer? _timer;

  final TextEditingController
      _notesController =
          TextEditingController();

  late AnimationController
      _circleAnimController;

  @override
  void initState() {
    super.initState();

    _circleAnimController =
        AnimationController(
      vsync: this,

      duration: const Duration(
        seconds: _workDuration,
      ),
    );
  }

  @override
  void dispose() {

    _timer?.cancel();

    _notesController.dispose();

    _circleAnimController.dispose();

    super.dispose();
  }

  void _startStop() {

    if (_isRunning) {

      _timer?.cancel();

      _circleAnimController.stop();

    } else {

      _circleAnimController.forward(
        from:
            1 -
            (_remainingSeconds /
                _workDuration),
      );

      _timer = Timer.periodic(
        const Duration(seconds: 1),

        (t) {

          setState(() {

            if (_remainingSeconds >
                0) {

              _remainingSeconds--;

            } else {

              t.cancel();

              _isRunning = false;

              if (_currentSession <
                  _totalSessions) {

                _currentSession++;

                _remainingSeconds =
                    _workDuration;

                _circleAnimController
                    .reset();
              }
            }
          });
        },
      );
    }

    setState(() {
      _isRunning = !_isRunning;
    });
  }

  String get _timeString {

    final m =
        (_remainingSeconds ~/ 60)
            .toString()
            .padLeft(2, '0');

    final s =
        (_remainingSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$m:$s';
  }

  int get _completedDuration {

    return _workDuration -
        _remainingSeconds;
  }

  Future<void>
      _selesaikanSesi() async {

    _timer?.cancel();

    try {

      await SessionLogService
          .createSessionLog(

        studySessionId: 1,

        durationSeconds:
            _completedDuration,
      );

    } catch (e) {

      print(e);

    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const NotebookPage(),
      ),

      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(
                height: 16),

            _buildAppBar(),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  16,
                  20,
                  16,
                  100,
                ),

                children: [

                  _buildTimerCard(),

                  const SizedBox(
                      height: 16),

                  _buildNotesSection(),
                ],
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),

      bottomNavigationBar:
          _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {

    return Container(
      color: Colors.white,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      child: Row(
        children: [

          InkWell(
            onTap: () =>
                Navigator.pop(context),

            borderRadius:
                BorderRadius.circular(
                    8),

            child: const Icon(
              Icons.chevron_left,

              color:
                  Color(0xFF2196F3),

              size: 28,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              widget.topicTitle,

              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color:
                    Colors.black87,
              ),

              textAlign:
                  TextAlign.center,
            ),
          ),

          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.menu,
              color: Colors.black87,
              size: 22,
            ),

            padding:
                EdgeInsets.zero,

            constraints:
                const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 24,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),

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

          SizedBox(
            width: 180,
            height: 180,

            child: Stack(
              alignment:
                  Alignment.center,

              children: [

                SizedBox(
                  width: 180,
                  height: 180,

                  child:
                      CircularProgressIndicator(
                    value: 1.0,

                    strokeWidth: 8,

                    backgroundColor:
                        Colors
                            .transparent,

                    valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                      Color(
                          0xFFE8E8E8),
                    ),
                  ),
                ),

                SizedBox(
                  width: 180,
                  height: 180,

                  child:
                      CircularProgressIndicator(
                    value:
                        _remainingSeconds /
                            _workDuration,

                    strokeWidth: 8,

                    backgroundColor:
                        Colors
                            .transparent,

                    valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                      Color(
                          0xFF4CAF50),
                    ),

                    strokeCap:
                        StrokeCap.round,
                  ),
                ),

                Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Text(
                      _timeString,

                      style:
                          const TextStyle(
                        fontSize: 42,
                        fontWeight:
                            FontWeight
                                .w700,
                        color: Colors
                            .black87,
                        letterSpacing:
                            1,
                      ),
                    ),

                    Text(
                      'Sesi $_currentSession dari $_totalSessions',

                      style: TextStyle(
                        fontSize: 13,
                        color: Colors
                            .grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: 180,
            height: 46,

            child:
                ElevatedButton.icon(
              onPressed:
                  _startStop,

              icon: Icon(
                _isRunning
                    ? Icons.pause
                    : Icons.play_arrow,

                color: Colors.white,

                size: 20,
              ),

              label: Text(
                _isRunning
                    ? 'Pause Sesi'
                    : 'Mulai Sesi',

                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    const Color(
                        0xFF4CAF50),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(30),
                ),

                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                16),

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
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  'CATATAN',

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colors.black54,
                    letterSpacing:
                        1.2,
                  ),
                ),

                Text(
                  'Otomatis tersimpan',

                  style: TextStyle(
                    fontSize: 11.5,
                    color:
                        Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFF0F0F0),
          ),

          Padding(
            padding:
                const EdgeInsets.all(
                    16),

            child: TextField(
              controller:
                  _notesController,

              maxLines: 6,

              style:
                  const TextStyle(
                fontSize: 14,
                color:
                    Colors.black87,
                height: 1.6,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    'Tulis apa yang kamu pelajari atau rumus-rumus penting...',

                hintStyle: TextStyle(
                  color:
                      Colors.grey[400],

                  fontSize: 14,

                  height: 1.6,
                ),

                border:
                    InputBorder.none,

                isDense: true,

                contentPadding:
                    EdgeInsets.zero,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              16,
              0,
              16,
              16,
            ),

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children:
                      List.generate(
                    _totalSessions,
                    (i) {

                      return Container(
                        width:
                            i <
                                    _currentSession
                                ? 24
                                : 20,

                        height: 8,

                        margin:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 3,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              i <
                                      _currentSession
                                  ? const Color(
                                      0xFF4CAF50)
                                  : Colors.grey[
                                      300],

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      4),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  'POMODORO CYCLES',

                  style: TextStyle(
                    fontSize: 10,
                    color:
                        Colors.grey[400],
                    letterSpacing:
                        1.2,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {

    return Container(
      color:
          const Color(0xFFF5F6FA),

      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),

      child: SizedBox(
        width: double.infinity,
        height: 52,

        child: ElevatedButton(
          onPressed:
              _selesaikanSesi,

          style:
              ElevatedButton
                  .styleFrom(
            backgroundColor:
                const Color(
                    0xFFDDE3EE),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                      30),
            ),

            elevation: 0,
          ),

          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [

              Icon(
                Icons
                    .check_circle_outline_rounded,

                color:
                    Color(0xFF5B7BB8),

                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'Selesaikan Sesi',

                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF5B7BB8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withOpacity(0.06),

            blurRadius: 12,

            offset:
                const Offset(0, -2),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,

            children: [

              _navItem(
                Icons.home_outlined,
                'Home',
                false,
              ),

              _navItem(
                Icons.article_outlined,
                'Notebook',
                true,
              ),

              _navItem(
                Icons.track_changes_outlined,
                'Goals',
                false,
              ),

              _navItem(
                Icons.person_outline,
                'Profile',
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
  ) {

    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Icon(
          icon,

          size: 24,

          color: isActive
              ? const Color(
                  0xFF2196F3)
              : Colors.grey[400],
        ),

        const SizedBox(height: 3),

        Text(
          label,

          style: TextStyle(
            fontSize: 11,

            fontWeight: isActive
                ? FontWeight.w600
                : FontWeight.w400,

            color: isActive
                ? const Color(
                    0xFF2196F3)
                : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}