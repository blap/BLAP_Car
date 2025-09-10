import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  bool _darkModeEnabled = false;
  
  bool get darkModeEnabled => _darkModeEnabled;
  
  ThemeService() {
    _loadDarkModeSetting();
  }
  
  Future<void> _loadDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleDarkMode(bool value) async {
    _darkModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', value);
    notifyListeners();
  }
  
  ThemeData get themeData {
    return _darkModeEnabled
        ? ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          )
        : ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          );
  }
}