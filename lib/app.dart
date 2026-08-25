import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculator_app/screens/calculator.dart';
import 'package:calculator_app/providers/calculator_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calculator',
        themeMode: ThemeMode.system,
        theme: ThemeData(
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
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        darkTheme: ThemeData(
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
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const Calculator(),
      ),
    );
  }
}
