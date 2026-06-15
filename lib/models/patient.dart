class Patient {
  final String id;
  final String name;
  final String roomNumber;
  final String status;

  Patient({
    required this.id,
    required this.name,
    required this.roomNumber,
    this.status = 'Stable',
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': id,
      'patient_name': name,
      'room_number': roomNumber,
      'status': status,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['patient_id'] ?? json['id'] ?? '',
      name: json['patient_name'] ?? json['name'] ?? '',
      roomNumber: json['room_number'] ?? json['room_number'] ?? '',
      status: json['status'] ?? 'Stable',
    );
  }
}