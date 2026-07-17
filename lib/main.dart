import 'package:client_pilot/pages/landing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client Pilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D12),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4ADE80),       // green accent
          secondary: const Color(0xFF22D3EE),     // cyan accent
          surface: const Color(0xFF13161E),
          error: const Color(0xFFF87171),
          onPrimary: const Color(0xFF0B0D12),
          onSurface: const Color(0xFFF1F5F9),
        ),
        cardColor: const Color(0xFF13161E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0D12),
          foregroundColor: Color(0xFFF1F5F9),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF13161E),
          selectedItemColor: Color(0xFF4ADE80),
          unselectedItemColor: Color(0xFF64748B),
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF1F5F9)),
          bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF64748B)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF252836)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4ADE80)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4ADE80),
            foregroundColor: const Color(0xFF0B0D12),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4ADE80),
            side: const BorderSide(color: Color(0xFF4ADE80)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LandingPage(),
      // later add routes: { '/login': ..., '/signup': ... }
    );
  }
}