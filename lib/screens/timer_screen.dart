import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Duration _selected = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  Timer? _ticker;
  bool _running = false;

  final List<Duration> _presets = const [
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 20),
    Duration(minutes: 30),
  ];

  void _pickCustom() async {
    Duration temp = _selected;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        int h = temp.inHours;
        int m = temp.inMinutes.remainder(60);
        int s = temp.inSeconds.remainder(60);
        return StatefulBuilder(builder: (context, setModalState) {
          Widget wheel(String label, int value, int max,
              ValueChanged<int> onChanged) {
            return Column(
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                SizedBox(
                  height: 140,
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    diameterRatio: 1.4,
                    physics: const FixedExtentScrollPhysics(),
                    controller:
                        FixedExtentScrollController(initialItem: value),
                    onSelectedItemChanged: onChanged,
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: max,
                      builder: (context, index) => Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vaqtni tanlang',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    wheel('soat', h, 24,
                        (v) => setModalState(() => h = v)),
                    wheel('daqiqa', m, 60,
                        (v) => setModalState(() => m = v)),
                    wheel('soniya', s, 60,
                        (v) => setModalState(() => s = v)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final d = Duration(hours: h, minutes: m, seconds: s);
                      Navigator.pop(context);
                      if (d.inSeconds > 0) {
                        setState(() {
                          _selected = d;
                          _remaining = d;
                        });
                      }
                    },
                    child: const Text('Tayyor',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _selectPreset(Duration d) {
    if (_running) return;
    setState(() {
      _selected = d;
      _remaining = d;
    });
  }

  void _start() {
    if (_remaining.inSeconds <= 0) return;
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        _showDoneDialog();
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remaining = _selected;
    });
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Vaqt tugadi!",
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text("Taymer yakunlandi.",
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('OK', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _selected.inSeconds == 0
        ? 0.0
        : _remaining.inSeconds / _selected.inSeconds;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: _running ? null : _pickCustom,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _RingPainter(progress: progress),
                    ),
                    Text(
                      _format(_remaining),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _presets.map((d) {
                final isSelected = d == _selected;
                return GestureDetector(
                  onTap: () => _selectPreset(d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.orange : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${d.inMinutes} daq',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RoundButton(
                  label: 'Tozalash',
                  background: AppColors.surface,
                  textColor: AppColors.textPrimary,
                  onTap: _reset,
                ),
                _RoundButton(
                  label: _running ? "To'xtatish" : 'Boshlash',
                  background: _running ? AppColors.red : AppColors.orange,
                  textColor: Colors.white,
                  onTap: _running ? _pause : _start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RoundButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  const _RoundButton({
    required this.label,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
