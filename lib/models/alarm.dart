import 'dart:convert';

/// Bitta uyg'otqichni ifodalovchi model
class AlarmModel {
  int id;
  int hour;
  int minute;
  String label;
  bool enabled;
  List<bool> repeatDays; // [Dush, Sesh, Chor, Pay, Jum, Shan, Yak]

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.enabled = true,
    List<bool>? repeatDays,
  }) : repeatDays = repeatDays ?? List.filled(7, false);

  bool get hasRepeat => repeatDays.any((d) => d);

  String get repeatLabel {
    if (!hasRepeat) return 'Faqat bir marta';
    const names = ['Du', 'Se', 'Chor', 'Pay', 'Jum', 'Sha', 'Yak'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i]) selected.add(names[i]);
    }
    if (selected.length == 7) return 'Har kuni';
    return selected.join(', ');
  }

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'enabled': enabled,
        'repeatDays': repeatDays,
      };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        id: json['id'],
        hour: json['hour'],
        minute: json['minute'],
        label: json['label'] ?? '',
        enabled: json['enabled'] ?? true,
        repeatDays: List<bool>.from(json['repeatDays'] ?? List.filled(7, false)),
      );

  static String encodeList(List<AlarmModel> alarms) =>
      jsonEncode(alarms.map((a) => a.toJson()).toList());

  static List<AlarmModel> decodeList(String data) {
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => AlarmModel.fromJson(e)).toList();
  }
}
