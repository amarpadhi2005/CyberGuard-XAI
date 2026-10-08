import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.securityScore = 85,
    super.shieldActive = true,
    required super.createdAt,
    required super.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? 'Cyber Agent',
      photoUrl: data['photo_url'] as String?,
      securityScore: (data['security_score'] as num?)?.toInt() ?? 85,
      shieldActive: data['shield_active'] as bool? ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['last_login_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'security_score': securityScore,
      'shield_active': shieldActive,
      'created_at': Timestamp.fromDate(createdAt),
      'last_login_at': Timestamp.fromDate(lastLoginAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      securityScore: entity.securityScore,
      shieldActive: entity.shieldActive,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }
}
