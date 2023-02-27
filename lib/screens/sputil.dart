import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class SpUtils {
  static SpUtils? _singleton;
  static SharedPreferences? _prefs;
  static final Lock _lock = Lock();

  static Future<SpUtils?> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          var singleton = SpUtils._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtils._();

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    if (_prefs == null) return null;
    var status = _prefs?.getString(key);
    if (status == null) return "";
    return status;
  }

  static List<String>? getStringList(String key) {
    if (_prefs == null) return null;
    var status = _prefs?.getStringList(key);
    if (status == null) return [];
    return status;
  }

  static Future<bool>? putString(String key, String value) {
    if (_prefs == null) return null;
    return _prefs?.setString(key, value);
  }

  static Future<bool>? putStringList(String key, List<String> value) {
    if (_prefs == null) return null;
    return _prefs?.setStringList(key, value);
  }
}
