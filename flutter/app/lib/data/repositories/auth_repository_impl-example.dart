import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository-example.dart';
import '../../domain/entities/user_entity-example.dart';
import '../datasources/auth_api_service-example.dart';
import '../datasources/auth_local_service-example.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalService _localService;

  AuthRepositoryImpl(this._apiService, this._localService);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.isSuccess && response.token != null) {
        // Store token locally
        await _localService.storeToken(response.token!);
        
        if (rememberMe) {
          await _localService.setRememberMe(true);
        }

        // Get user profile
        final user = await _getUserProfile(response.token!);

        return AuthResult.success(
          token: response.token,
          user: user,
        );
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Login failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Network error: ${e.toString()}',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> loginWithGoogle() async {
    try {
      final response = await _apiService.loginWithGoogle();

      if (response.isSuccess && response.token != null) {
        await _localService.storeToken(response.token!);
        
        final user = await _getUserProfile(response.token!);

        return AuthResult.success(
          token: response.token,
          user: user,
        );
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Google login failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Google login error: ${e.toString()}',
        errorCode: 'GOOGLE_LOGIN_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
      );

      if (response.isSuccess && response.token != null) {
        await _localService.storeToken(response.token!);
        
        final user = await _getUserProfile(response.token!);

        return AuthResult.success(
          token: response.token,
          user: user,
        );
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Registration failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Registration error: ${e.toString()}',
        errorCode: 'REGISTRATION_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _localService.getToken();
      if (token != null) {
        await _apiService.logout(token);
      }
    } catch (e) {
      // Log error but don't throw - we want to clear local data anyway
    } finally {
      await _localService.clearToken();
      await _localService.setRememberMe(false);
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await _localService.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _localService.getToken();
      if (token == null) return null;

      return await _getUserProfile(token);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      final response = await _apiService.resetPassword(email);

      if (response.isSuccess) {
        return AuthResult.success();
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Password reset failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Password reset error: ${e.toString()}',
        errorCode: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> verifyEmail(String code) async {
    try {
      final token = await _localService.getToken();
      if (token == null) {
        return AuthResult.failure(
          errorMessage: 'No authentication token found',
          errorCode: 'NO_TOKEN',
        );
      }

      final response = await _apiService.verifyEmail(token, code);

      if (response.isSuccess) {
        final user = await _getUserProfile(token);
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Email verification failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Email verification error: ${e.toString()}',
        errorCode: 'EMAIL_VERIFICATION_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      final token = await _localService.getToken();
      if (token == null) {
        return AuthResult.failure(
          errorMessage: 'No token to refresh',
          errorCode: 'NO_TOKEN',
        );
      }

      final response = await _apiService.refreshToken(token);

      if (response.isSuccess && response.token != null) {
        await _localService.storeToken(response.token!);
        
        return AuthResult.success(token: response.token);
      } else {
        return AuthResult.failure(
          errorMessage: response.errorMessage ?? 'Token refresh failed',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Token refresh error: ${e.toString()}',
        errorCode: 'TOKEN_REFRESH_ERROR',
      );
    }
  }

  @override
  Future<bool> isTokenValid() async {
    try {
      final token = await _localService.getToken();
      if (token == null) return false;

      return await _apiService.validateToken(token);
    } catch (e) {
      return false;
    }
  }

  Future<UserEntity?> _getUserProfile(String token) async {
    try {
      final response = await _apiService.getUserProfile(token);
      return response.user;
    } catch (e) {
      return null;
    }
  }
}