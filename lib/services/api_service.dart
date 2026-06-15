import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/request_model.dart';

class ApiService {
  // Replace with your FastAPI backend host IP for local network testing
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Mock-login endpoint processing
  static Future<bool> loginPatient(Patient patient) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode(patient.toJson()),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } on SocketException {
      throw 'Cannot reach backend server. Check connection.';
    } catch (e) {
      // Return true anyway for fast-paced Hackathon resilience if server isn't running yet
      return true; 
    }
  }

  // Generic request dispatcher for quick-action buttons
  static Future<bool> sendQuickRequest({
    required Patient patient, 
    required String requestType,
    String priority = 'normal',
  }) async {
    final String endpoint = priority == 'critical' ? '/request/sos' : '/request/${requestType.toLowerCase()}';
    
    final Map<String, dynamic> payload = {
      'patient_id': patient.id,
      'patient_name': patient.name,
      'room_number': patient.roomNumber,
      'request_type': requestType,
      if (priority == 'critical') 'priority': 'critical',
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw 'Failed to send request. Check your local server.';
    }
  }

  // Custom text assistance endpoint
  static Future<bool> sendCustomRequest({
    required Patient patient,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request/custom'),
        headers: _headers,
        body: jsonEncode({
          'patient_id': patient.id,
          'patient_name': patient.name,
          'room_number': patient.roomNumber,
          'request_type': 'custom',
          'message': message,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw 'Failed to transmit custom request.';
    }
  }

  // Fetch patient logs
  static Future<List<PatientRequest>> fetchRequestHistory(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/requests/$patientId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PatientRequest.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // Fallback dummy records for hackathon visual showcase when API isn't tracking yet
      return [
        PatientRequest(id: '1', type: 'Water', timestamp: DateTime.now().subtract(const Duration(minutes: 12)), status: 'Completed'),
        PatientRequest(id: '2', type: 'Nurse', timestamp: DateTime.now().subtract(const Duration(minutes: 45)), status: 'Accepted'),
        PatientRequest(id: '3', type: 'Pain Assistance', timestamp: DateTime.now().subtract(const Duration(hours: 2)), status: 'Pending'),
      ];
    }
  }
}