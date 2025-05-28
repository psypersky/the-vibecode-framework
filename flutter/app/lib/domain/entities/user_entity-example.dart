import 'package:json_annotation/json_annotation.dart';

part 'user_entity-example.g.dart';

@JsonSerializable()
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? phoneNumber;
  final String? role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.phoneNumber,
    this.role,
    required this.isEmailVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? phoneNumber,
    String? role,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          bio == other.bio &&
          location == other.location &&
          phoneNumber == other.phoneNumber &&
          role == other.role &&
          isEmailVerified == other.isEmailVerified &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      (avatarUrl?.hashCode ?? 0) ^
      (bio?.hashCode ?? 0) ^
      (location?.hashCode ?? 0) ^
      (phoneNumber?.hashCode ?? 0) ^
      (role?.hashCode ?? 0) ^
      isEmailVerified.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'UserEntity{id: $id, name: $name, email: $email, role: $role, isEmailVerified: $isEmailVerified, isActive: $isActive}';
  }

  // Utility getters
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  bool get hasAvatar => avatarUrl?.isNotEmpty == true;
  bool get hasCompleteProfile => 
      name.isNotEmpty && 
      email.isNotEmpty && 
      (bio?.isNotEmpty == true) && 
      (location?.isNotEmpty == true);
  
  String get initials {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first.substring(0, 1).toUpperCase();
    } else {
      return email.substring(0, 1).toUpperCase();
    }
  }
}