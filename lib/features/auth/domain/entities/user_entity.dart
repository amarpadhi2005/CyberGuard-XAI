class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int securityScore;
  final bool shieldActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.securityScore = 85,
    this.shieldActive = true,
    required this.createdAt,
    required this.lastLoginAt,
  });
}
