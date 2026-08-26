import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CustomThemeModel {
  Color primaryColor;
  Color surfaceColor;
  Color onSurfaceColor;
  Color backgroundColor;
  String? fontFamily;
  String? fontPath;

  CustomThemeModel({
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.backgroundColor,
    this.fontFamily,
    this.fontPath,
  });

  // Default custom theme settings
  factory CustomThemeModel.defaultTheme() {
    return CustomThemeModel(
      primaryColor: Colors.deepPurple,
      surfaceColor: const Color(0xFF1E1E1E),
      onSurfaceColor: Colors.white,
      backgroundColor: Colors.black,
      fontFamily: null,
      fontPath: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor.toARGB32(),
      'surfaceColor': surfaceColor.toARGB32(),
      'onSurfaceColor': onSurfaceColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'fontFamily': fontFamily,
      'fontPath': fontPath,
    };
  }

  factory CustomThemeModel.fromJson(Map<String, dynamic> json) {
    return CustomThemeModel(
      primaryColor: Color(json['primaryColor'] as int),
      surfaceColor: Color(json['surfaceColor'] as int),
      onSurfaceColor: Color(json['onSurfaceColor'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      fontFamily: json['fontFamily'] as String?,
      fontPath: json['fontPath'] as String?,
    );
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_theme_data', jsonEncode(toJson()));
  }

  static Future<CustomThemeModel> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('custom_theme_data');
    if (jsonStr != null) {
      try {
        return CustomThemeModel.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        return CustomThemeModel.defaultTheme();
      }
    }
    return CustomThemeModel.defaultTheme();
  }
}
