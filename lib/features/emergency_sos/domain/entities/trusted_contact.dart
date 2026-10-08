class TrustedContact {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String email;
  final bool isNotifyEnabled;
  final bool isAutoBeacon;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email = '',
    this.isNotifyEnabled = true,
    this.isAutoBeacon = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phone_number': phoneNumber,
      'email': email,
      'is_notify_enabled': isNotifyEnabled,
      'is_auto_beacon': isAutoBeacon,
    };
  }

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Emergency Contact',
      relationship: json['relationship'] as String? ?? 'Trusted Contact',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isNotifyEnabled: json['is_notify_enabled'] as bool? ?? true,
      isAutoBeacon: json['is_auto_beacon'] as bool? ?? true,
    );
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
    bool? isNotifyEnabled,
    bool? isAutoBeacon,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isNotifyEnabled: isNotifyEnabled ?? this.isNotifyEnabled,
      isAutoBeacon: isAutoBeacon ?? this.isAutoBeacon,
    );
  }
}
