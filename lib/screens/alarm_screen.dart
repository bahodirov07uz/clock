import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/alarm_storage.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'edit_alarm_screen.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<AlarmModel> _alarms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AlarmStorage.load();
    list.sort((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin.compareTo(bMin);
    });
    setState(() {
      _alarms = list;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await AlarmStorage.save(_alarms);
  }

  Future<void> _openEditor({AlarmModel? existing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAlarmScreen(existing: existing),
      ),
    );

    if (result == 'DELETE' && existing != null) {
      await NotificationService.instance.cancelAlarm(existing.id);
      setState(() => _alarms.removeWhere((a) => a.id == existing.id));
      await _persist();
      return;
    }

    if (result is AlarmModel) {
      setState(() {
        final idx = _alarms.indexWhere((a) => a.id == result.id);
        if (idx >= 0) {
          _alarms[idx] = result;
        } else {
          _alarms.add(result);
        }
        _alarms.sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
      await NotificationService.instance.scheduleAlarm(result);
      await _persist();
    }
  }

  Future<void> _toggle(AlarmModel alarm, bool value) async {
    setState(() => alarm.enabled = value);
    await NotificationService.instance.scheduleAlarm(alarm);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Uyg'otqich"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.orange),
            onPressed: () => _openEditor(),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange))
          : _alarms.isEmpty
              ? _EmptyState(onAdd: () => _openEditor())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return _AlarmTile(
                      alarm: alarm,
                      onTap: () => _openEditor(existing: alarm),
                      onToggle: (v) => _toggle(alarm, v),
                    );
                  },
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alarm, color: AppColors.textSecondary, size: 56),
          const SizedBox(height: 12),
          const Text(
            "Uyg'otqichlar yo'q",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Qo\'shish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const _AlarmTile({
    required this.alarm,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dimmed = !alarm.enabled;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.timeLabel,
                  style: TextStyle(
                    color: dimmed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alarm.label.isEmpty ? alarm.repeatLabel : alarm.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Switch(value: alarm.enabled, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}
