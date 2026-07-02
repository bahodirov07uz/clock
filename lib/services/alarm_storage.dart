import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

/// Uyg'otqichlar ro'yxatini qurilmada saqlab turish uchun xizmat.
class AlarmStorage {
  static const _key = 'alarms_list';

  static Future<List<AlarmModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return AlarmModel.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AlarmModel.encodeList(alarms));
  }
}
