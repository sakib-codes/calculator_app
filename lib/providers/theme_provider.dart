import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_theme_model.dart';

enum AppTheme {
  system,
  cyberpunk,
  retro,
  nothing,
  nothingLight,
  custom,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.system;
  CustomThemeModel _customTheme = CustomThemeModel.defaultTheme();

  ThemeProvider() {
    _loadTheme();
  }

  AppTheme get currentTheme => _currentTheme;
  CustomThemeModel get customTheme => _customTheme;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme_index');
    if (themeIndex != null && themeIndex >= 0 && themeIndex < AppTheme.values.length) {
      _currentTheme = AppTheme.values[themeIndex];
    }
    _customTheme = await CustomThemeModel.loadFromPrefs();
    
    if (_customTheme.fontPath != null && _customTheme.fontFamily != null) {
      await _loadCustomFont(_customTheme.fontPath!, _customTheme.fontFamily!);
    }
    notifyListeners();
  }

  Future<void> _loadCustomFont(String path, String familyName) async {
    try {
      final fontFile = File(path);
      if (await fontFile.exists()) {
        final fontData = await fontFile.readAsBytes();
        final fontLoader = FontLoader(familyName);
        fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
        await fontLoader.load();
      }
    } catch (e) {
      debugPrint("Failed to load custom font: \$e");
    }
  }

  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_index', theme.index);
  }

  void updateCustomTheme(CustomThemeModel newModel) async {
    _customTheme = newModel;
    await _customTheme.saveToPrefs();
    if (_customTheme.fontPath != null && _customTheme.fontFamily != null) {
      await _loadCustomFont(_customTheme.fontPath!, _customTheme.fontFamily!);
    }
    if (_currentTheme == AppTheme.custom) {
      notifyListeners();
    }
  }

  ThemeMode get themeMode {
    if (_currentTheme == AppTheme.system) {
      return ThemeMode.system;
    }
    if (_currentTheme == AppTheme.nothingLight) {
      return ThemeMode.light;
    }
    return ThemeMode.dark;
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.cyberpunk:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0014),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF007F), // Neon Pink
            surface: Color(0xFF1E0028),
            onSurface: Color(0xFF00F0FF), // Cyan
            tertiary: Color(0xFF4B0082),
          ),
          textTheme: GoogleFonts.shareTechMonoTextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: const Color(0xFF00F0FF),
            displayColor: const Color(0xFFFF007F),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF00F0FF)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        );
      case AppTheme.retro:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF33FF00),
            surface: Color(0xFF111111),
            onSurface: Color(0xFF33FF00),
            tertiary: Color(0xFF004400),
          ),
          textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: const Color(0xFF33FF00),
            displayColor: const Color(0xFF33FF00),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF33FF00)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        );
      case AppTheme.nothing:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE22D2C), // Nothing Red
            surface: Color(0xFF141414), // Dark grey
            onSurface: Colors.white,
            tertiary: Color(0xFF333333),
            outlineVariant: Colors.white24,
          ),
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'LED Dot-Matrix',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        );
      case AppTheme.nothingLight:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF3F3F3),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE22D2C), // Nothing Red
            surface: Colors.white,
            onSurface: Colors.black,
            tertiary: Color(0xFFE0E0E0), // Light grey
            outlineVariant: Colors.black12,
          ),
          textTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'LED Dot-Matrix',
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        );
      case AppTheme.custom:
        final brightness = ThemeData.estimateBrightnessForColor(_customTheme.backgroundColor);
        return ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: _customTheme.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _customTheme.primaryColor,
            brightness: brightness,
            surface: _customTheme.surfaceColor,
            onSurface: _customTheme.onSurfaceColor,
          ).copyWith(
            primary: _customTheme.primaryColor,
          ),
          textTheme: (brightness == Brightness.dark 
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme).apply(
                fontFamily: _customTheme.fontFamily,
                bodyColor: _customTheme.onSurfaceColor,
                displayColor: _customTheme.onSurfaceColor,
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: _customTheme.onSurfaceColor),
            systemOverlayStyle: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          ),
        );
      case AppTheme.system:
        // Handled in app.dart's theme and darkTheme fallback
        return ThemeData.light();
    }
  }
}
