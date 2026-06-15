class PatientRequest {
  final String id;
  final String type;
  final DateTime timestamp;
  final String status; // Pending, Accepted, Completed
  final String message;

  PatientRequest({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.status,
    this.message = '',
  });

  factory PatientRequest.fromJson(Map<String, dynamic> json) {
    return PatientRequest(
      id: json['id']?.toString() ?? '',
      type: json['request_type'] ?? 'General',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      message: json['message'] ?? '',
    );
  }
}