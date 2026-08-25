import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  system,
  cyberpunk,
  retro,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.system;

  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  ThemeMode get themeMode {
    if (_currentTheme == AppTheme.system) {
      return ThemeMode.system;
    }
    return ThemeMode.dark; // Custom themes are dark mode only
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
      case AppTheme.system:
        // Handled in app.dart's theme and darkTheme fallback
        return ThemeData.light();
    }
  }
}
