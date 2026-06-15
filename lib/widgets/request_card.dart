import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final PatientRequest request;

  const RequestCard({super.key, required this.request});

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'accepted': return Colors.orange;
      case 'pending':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(
            request.type.toLowerCase() == 'sos' ? Icons.warning_amber_rounded : Icons.medical_services_outlined,
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          request.type.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Note: "${request.message}"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 6),
            Text(
              DateFormat('hh:mm a - dd MMM').format(request.timestamp),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            request.status,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}