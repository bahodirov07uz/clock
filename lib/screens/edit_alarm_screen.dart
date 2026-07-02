import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../theme/app_theme.dart';

class EditAlarmScreen extends StatefulWidget {
  final AlarmModel? existing;
  const EditAlarmScreen({super.key, this.existing});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late int _hour;
  late int _minute;
  late TextEditingController _labelController;
  late List<bool> _repeatDays;

  static const _dayNames = ['Du', 'Se', 'Chor', 'Pay', 'Jum', 'Sha', 'Yak'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _hour = e?.hour ?? TimeOfDay.now().hour;
    _minute = e?.minute ?? TimeOfDay.now().minute;
    _labelController = TextEditingController(text: e?.label ?? '');
    _repeatDays = List<bool>.from(e?.repeatDays ?? List.filled(7, false));
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.orange,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  void _save() {
    final result = AlarmModel(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
      hour: _hour,
      minute: _minute,
      label: _labelController.text.trim(),
      enabled: widget.existing?.enabled ?? true,
      repeatDays: _repeatDays,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final hh = _hour.toString().padLeft(2, '0');
    final mm = _minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existing == null
            ? "Yangi uyg'otqich"
            : "Uyg'otqichni tahrirlash"),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Saqlash',
              style: TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$hh:$mm',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Takrorlanishi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final selected = _repeatDays[i];
                return GestureDetector(
                  onTap: () => setState(() => _repeatDays[i] = !selected),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        selected ? AppColors.orange : AppColors.surface,
                    child: Text(
                      _dayNames[i],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nomi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _labelController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: "Uyg'otqich",
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (widget.existing != null) ...[
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => Navigator.pop(context, 'DELETE'),
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                label: const Text(
                  "Uyg'otqichni o'chirish",
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
