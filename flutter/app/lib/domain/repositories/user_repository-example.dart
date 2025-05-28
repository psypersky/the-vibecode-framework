import '../entities/user_entity-example.dart';

abstract class UserRepository {
  Future<UserEntity?> getCurrentUserProfile();

  Future<UserResult> updateProfile(UserEntity user);

  Future<AvatarUploadResult> uploadAvatar(String imagePath);

  Future<List<UserEntity>> searchUsers(String query);

  Future<UserResult> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserResult> deleteAccount();

  Future<UserEntity?> getUserById(String userId);

  Future<List<UserEntity>> getFollowing();

  Future<List<UserEntity>> getFollowers();

  Future<UserResult> followUser(String userId);

  Future<UserResult> unfollowUser(String userId);
}

class UserResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;

  UserResult({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory UserResult.success({UserEntity? user}) {
    return UserResult(
      isSuccess: true,
      user: user,
    );
  }

  factory UserResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return UserResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

class AvatarUploadResult {
  final bool isSuccess;
  final String? avatarUrl;
  final String? errorMessage;

  AvatarUploadResult({
    required this.isSuccess,
    this.avatarUrl,
    this.errorMessage,
  });

  factory AvatarUploadResult.success({required String avatarUrl}) {
    return AvatarUploadResult(
      isSuccess: true,
      avatarUrl: avatarUrl,
    );
  }

  factory AvatarUploadResult.failure({required String errorMessage}) {
    return AvatarUploadResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}