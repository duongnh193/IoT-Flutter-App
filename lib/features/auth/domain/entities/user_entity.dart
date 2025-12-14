/// Domain Entity for User
class UserEntity {
  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;
}

