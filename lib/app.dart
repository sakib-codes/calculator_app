import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calculator_app/screens/calculator.dart';
import 'package:calculator_app/providers/calculator_provider.dart';
import 'package:calculator_app/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CalculatorProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isSystem = themeProvider.currentTheme == AppTheme.system;
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Calculator',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('en', 'GB'),
            ],
            themeMode: themeProvider.themeMode,
            theme: isSystem ? ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF3F4F6),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF29A8FF),
                surface: Color(0xFFFFFFFF),
                onSurface: Color(0xFF1E293B),
                tertiary: Color(0xFFE2E8F0),
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF1E293B)),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                titleTextStyle: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ) : themeProvider.themeData,
            darkTheme: isSystem ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF17171C),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF29A8FF),
                surface: Color(0xFF2E2F38),
                onSurface: Color(0xFFFFFFFF),
                tertiary: Color(0xFF4E505F),
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ) : themeProvider.themeData,
            home: const Calculator(),
          );
        },
      ),
    );
  }
}
