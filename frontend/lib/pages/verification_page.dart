import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'welcome_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 119; // 01:59
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 119;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _resendCode() {
    if (!_canResend) return;
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startTimer();
    setState(() {});
  }

  String get _timerText {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isComplete =>
      _controllers.every((c) => c.text.isNotEmpty);

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF2196F3),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'LearnFit',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Email Icon ──
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F0FE),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF2196F3),
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ──
            const Text(
              'Verifikasi Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // ── Subtitle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Kami telah mengirimkan kode OTP ke email\nkamu. Silakan masukkan di bawah ini.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // ── OTP Fields ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => _onKeyEvent(event, index),
                    child: SizedBox(
                      width: 46,
                      height: 54,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) => _onChanged(val, index),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2196F3),
                              width: 1.5,
                            ),
                          ),
                          hintText: '—',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // ── Resend & Timer ──
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tidak menerima kode? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend ? _resendCode : null,
                      child: Text(
                        'Kirim ulang kode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _canResend
                              ? const Color(0xFF2196F3)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_canResend) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _timerText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const Spacer(),

            // ── Tombol Verifikasi ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isComplete
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WelcomePage()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    disabledBackgroundColor:
                        const Color(0xFF2196F3).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}