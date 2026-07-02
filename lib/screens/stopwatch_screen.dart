import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = [];

  void _start() {
    setState(() {
      _stopwatch.start();
      _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
        setState(() {});
      });
    });
  }

  void _pause() {
    setState(() {
      _stopwatch.stop();
      _ticker?.cancel();
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  void _lap() {
    setState(() {
      _laps.insert(0, _stopwatch.elapsed);
    });
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
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10);
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    final msStr = ms.toString().padLeft(2, '0');
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$mm:$ss.$msStr';
    }
    return '$mm:$ss.$msStr';
  }

  @override
  Widget build(BuildContext context) {
    final running = _stopwatch.isRunning;
    final started = _stopwatch.elapsed.inMilliseconds > 0 || running;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Container(
              width: 260,
              height: 260,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: running ? AppColors.orange : AppColors.surfaceLight,
                  width: 3,
                ),
              ),
              child: Text(
                _format(_stopwatch.elapsed),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundButton(
                label: started && !running ? 'Tozalash' : 'Bo\'lak',
                enabled: started,
                background: AppColors.surface,
                textColor: AppColors.textPrimary,
                onTap: started
                    ? (running ? _lap : _reset)
                    : null,
              ),
              _RoundButton(
                label: running ? "To'xtatish" : 'Boshlash',
                enabled: true,
                background: running ? AppColors.red : AppColors.orange,
                textColor: Colors.white,
                onTap: running ? _pause : _start,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _laps.isEmpty
                ? const Center(
                    child: Text(
                      "Bo'laklar shu yerda ko'rinadi",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      final lapNumber = _laps.length - index;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.divider,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Bo'lak $lapNumber",
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              _format(_laps[index]),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final Color background;
  final Color textColor;
  final VoidCallback? onTap;

  const _RoundButton({
    required this.label,
    required this.enabled,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? background : AppColors.surface,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? textColor : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
