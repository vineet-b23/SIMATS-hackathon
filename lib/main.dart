import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart'; // Ensure this matches your dashboard file path

void main() async {
  // 1. Ensure native platform bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Optional: Inject mock session data for testing if SharedPreferences is empty
  await _ensureMockSessionExists();

  // 3. Launch the core application
  runApp(const MediLinkApp());
}

class MediLinkApp extends StatelessWidget {
  const MediLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediLink Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      // Directs the app straight to your functional dashboard screen
      home: const DashboardScreen(),
    );
  }
}

/// Helper function to prevent an infinite loading screen on a fresh install/build.
/// It pre-fills SharedPreferences if no patient session data exists yet.
Future<void> _ensureMockSessionExists() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('patient_id')) {
    await prefs.setString('patient_id', 'PT-2026-X89');
    await prefs.setString('patient_name', 'Vineet');
    await prefs.setString('room_number', '304-B');
  }
}