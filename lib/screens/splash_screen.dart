import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final String? patientId = prefs.getString('patient_id');

    if (!mounted) return;

    if (patientId != null && patientId.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.local_hospital, size: 80, color: Color(0xFF1976D2)),
            ),
            const SizedBox(height: 24),
            const Text(
              'MediLink',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Patient Assistance System',
              style: TextStyle(fontSize: 16, color: Colors.blue.shade100, fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}