import '../entities/user_entity-example.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResult> loginWithGoogle();

  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<String?> getStoredToken();

  Future<UserEntity?> getCurrentUser();

  Future<AuthResult> resetPassword(String email);

  Future<AuthResult> verifyEmail(String code);

  Future<AuthResult> refreshToken();

  Future<bool> isTokenValid();
}

class AuthResult {
  final bool isSuccess;
  final String? token;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;

  AuthResult({
    required this.isSuccess,
    this.token,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success({
    String? token,
    UserEntity? user,
  }) {
    return AuthResult(
      isSuccess: true,
      token: token,
      user: user,
    );
  }

  factory AuthResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}