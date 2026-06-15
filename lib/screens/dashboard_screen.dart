import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../widgets/dashboard_tile.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Patient? _currentPatient;
  final _customRequestController = TextEditingController();
  bool _isActionLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPatientSession();
  }

  Future<void> _loadPatientSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPatient = Patient(
        id: prefs.getString('patient_id') ?? 'UNKNOWN',
        name: prefs.getString('patient_name') ?? 'Patient Logged Out',
        roomNumber: prefs.getString('room_number') ?? 'N/A',
      );
    });
  }

  Future<void> _triggerQuickRequest(String type, {bool isEmergency = false}) async {
    if (_currentPatient == null) return;
    setState(() => _isActionLoading = true);

    try {

      if (isEmergency) {
  await FirebaseFirestore.instance
      .collection('sos_alerts')
      .doc('test1')
      .set({
    'message': '${_currentPatient!.name} needs help',
    'status': 'active',
    'patientId': _currentPatient!.id,
    'room': _currentPatient!.roomNumber,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
      bool success = await ApiService.sendQuickRequest(
        patient: _currentPatient!,
        requestType: type,
        priority: isEmergency ? 'critical' : 'normal',
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEmergency ? 'Emergency alert sent successfully.' : '$type request submitted.'),
            backgroundColor: isEmergency ? Colors.red : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  Future<void> _submitCustomRequest() async {
    final message = _customRequestController.text.trim();
    if (message.isEmpty || _currentPatient == null) return;

    setState(() => _isActionLoading = true);
    try {
      bool success = await ApiService.sendCustomRequest(patient: _currentPatient!, message: message);
      if (!mounted) return;
      if (success) {
        _customRequestController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom payload sent successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  void _showSosConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Confirm SOS Alert'),
            ],
          ),
          content: const Text('Are you sure this is an emergency? This activates peripheral alert hardware triggers and broadcasts immediate responses.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                _triggerQuickRequest('SOS', isEmergency: true);
              },
              child: const Text('CONFIRM SOS'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPatient == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      _buildMainDashboard(),
      HistoryScreen(patientId: _currentPatient!.id),
      ProfileScreen(patient: _currentPatient!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediLink Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 2,
        actions: [
          if (_isActionLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Patient Status Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed typo here
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentPatient!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Patient ID: ${_currentPatient!.id}', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Room: ${_currentPatient!.roomNumber}',
                          style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed typo here
                    children: [
                      const Text('Current Status Tracker:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: const Text('Stable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // EMERGENCY RED BUTTON
          GestureDetector(
            onTap: _showSosConfirmation,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gpp_bad, size: 40, color: Colors.white),
                  SizedBox(width: 16),
                  Text('EMERGENCY SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1)), // Fixed typo here
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Quick Action Assistance requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),

          // Action Grid Layout
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              DashboardTile(icon: Icons.local_drink, title: 'Need Water', color: Colors.blue, onTap: () => _triggerQuickRequest('Water')),
              DashboardTile(icon: Icons.restaurant, title: 'Need Food', color: Colors.orange, onTap: () => _triggerQuickRequest('Food')),
              DashboardTile(icon: Icons.medical_services, title: 'Need Nurse', color: Colors.teal, onTap: () => _triggerQuickRequest('Nurse')),
              DashboardTile(icon: Icons.front_hand, title: 'Assistance', color: Colors.purple, onTap: () => _triggerQuickRequest('Assistance')),
            ],
          ),
          const SizedBox(height: 12),
          DashboardTile(
            icon: Icons.sick, 
            title: 'Feeling Acute Pain', 
            color: Colors.redAccent, 
            onTap: () => _triggerQuickRequest('Pain Management')
          ),

          const SizedBox(height: 24),
          const Text('Custom Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),

          // Custom Input Card Text Form Box
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customRequestController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., I need an extra blanket...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1976D2)),
                    onPressed: _submitCustomRequest,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}