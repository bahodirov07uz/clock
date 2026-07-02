import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorldCity {
  final String name;
  final int utcOffsetHours; // Tashkentga nisbatan emas, UTC ga nisbatan
  const WorldCity(this.name, this.utcOffsetHours);
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  final List<WorldCity> _cities = const [
    WorldCity('Toshkent', 5),
    WorldCity('Moskva', 3),
    WorldCity('Istanbul', 3),
    WorldCity('London', 0),
    WorldCity('Nyu-York', -4),
    WorldCity('Dubay', 4),
  ];

  static const List<String> _weekdayNames = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  static const List<String> _monthNames = [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hh = _two(_now.hour);
    final mm = _two(_now.minute);
    final ss = _two(_now.second);
    final weekday = _weekdayNames[_now.weekday - 1];
    final dateStr = '${_now.day} ${_monthNames[_now.month - 1]}, $weekday';

    final localOffset = _now.timeZoneOffset.inHours;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              dateStr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$hh:$mm',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 76,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 1,
                        ),
                      ),
                      TextSpan(
                        text: ':$ss',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.public, color: AppColors.orange, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dunyo soatlari',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._cities.map((city) => _CityTile(
                  city: city,
                  now: _now.toUtc(),
                  localOffset: localOffset,
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final WorldCity city;
  final DateTime now; // UTC vaqt
  final int localOffset;

  const _CityTile({
    required this.city,
    required this.now,
    required this.localOffset,
  });

  @override
  Widget build(BuildContext context) {
    final cityTime = now.add(Duration(hours: city.utcOffsetHours));
    final hh = cityTime.hour.toString().padLeft(2, '0');
    final mm = cityTime.minute.toString().padLeft(2, '0');
    final diff = city.utcOffsetHours - localOffset;
    String diffLabel;
    if (diff == 0) {
      diffLabel = 'Bugun, sizning vaqtingiz';
    } else if (diff > 0) {
      diffLabel = 'Sizdan $diff soat oldinda';
    } else {
      diffLabel = 'Sizdan ${-diff} soat orqada';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                diffLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '$hh:$mm',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
