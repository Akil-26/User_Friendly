import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _firstTimeKey = 'first_time_shown';

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstTimeKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, true);
  }
}