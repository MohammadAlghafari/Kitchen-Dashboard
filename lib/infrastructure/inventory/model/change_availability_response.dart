import 'dart:convert';

class ChangeAvailabilityResponse {
  bool status;
  String details;
  ChangeAvailabilityResponse({
    required this.status,
    required this.details,
  });

  ChangeAvailabilityResponse copyWith({
    bool? status,
    String? details,
  }) {
    return ChangeAvailabilityResponse(
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'status': status});
    result.addAll({'details': details});
  
    return result;
  }

  factory ChangeAvailabilityResponse.fromMap(Map<String, dynamic> map) {
    return ChangeAvailabilityResponse(
      status: map['status'] ?? false,
      details: map['details'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChangeAvailabilityResponse.fromJson(String source) => ChangeAvailabilityResponse.fromMap(json.decode(source));

  @override
  String toString() => 'ChangeAvailabilityResponse(status: $status, details: $details)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ChangeAvailabilityResponse &&
      other.status == status &&
      other.details == details;
  }

  @override
  int get hashCode => status.hashCode ^ details.hashCode;
}
