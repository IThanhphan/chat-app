import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<bool> isDarkMode = ValueNotifier(false);

Future<void> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkMode.value = prefs.getBool('darkMode') ?? false;
}

Future<void> saveThemePreference(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('darkMode', value);
}
