import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/api_service.dart';
import '../widgets/request_card.dart';

class HistoryScreen extends StatelessWidget {
  final String patientId;
  const HistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PatientRequest>>(
      future: ApiService.fetchRequestHistory(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No execution logs tracked yet.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final logs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recent Support Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) => RequestCard(request: logs[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}