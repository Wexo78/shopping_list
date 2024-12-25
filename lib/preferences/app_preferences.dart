import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  late SharedPreferences _prefs;

  AppPreferences._internal();

  static AppPreferences get instance => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get showWelcomeDialog => _prefs.getBool('showWelcome') ?? true;

  set showWelcomeDialog(bool value) => _prefs.setBool('showWelcome', value);
}
