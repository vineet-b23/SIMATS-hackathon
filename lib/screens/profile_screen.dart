import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Patient patient;
  const ProfileScreen({super.key, required this.patient});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1976D2),
              child: Icon(Icons.airline_seat_flat, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            patient.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Room Hub Status: Active Allocation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          
          ListTile(
            leading: const Icon(Icons.badge, color: Color(0xFF1976D2)),
            title: const Text('Patient Record Reference ID'),
            subtitle: Text(patient.id, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bed, color: Color(0xFF1976D2)),
            title: const Text('Assigned Ward / Room Unit'),
            subtitle: Text(patient.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('LEAVE STATION / LOGOUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.red.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}