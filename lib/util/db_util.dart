import 'package:shared_preferences/shared_preferences.dart';

class DbUtil {
  static Future<void> saveString(String key, String text) async {
    // SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, text);
  }

  static Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String text = prefs.getString(key);
    return text;
  }
}
