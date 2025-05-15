import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Theme
  String get theme => _prefs.getString(_themeKey) ?? 'system';
  Future<void> setTheme(String value) => _prefs.setString(_themeKey, value);

  // Language
  String get language => _prefs.getString(_languageKey) ?? 'en';
  Future<void> setLanguage(String value) => _prefs.setString(_languageKey, value);

  // Notifications
  bool get notifications => _prefs.getBool(_notificationsKey) ?? true;
  Future<void> setNotifications(bool value) => _prefs.setBool(_notificationsKey, value);
} 