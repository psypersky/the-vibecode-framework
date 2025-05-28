import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/user_entity-example.dart';

@singleton
class AuthApiService {
  final http.Client _httpClient;
  final String _baseUrl;

  AuthApiService(this._httpClient) : _baseUrl = 'https://api.example.com';

  Future<ApiAuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Network error: ${e.toString()}',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  Future<ApiAuthResponse> loginWithGoogle() async {
    try {
      // In a real implementation, this would handle Google OAuth flow
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Google login error: ${e.toString()}',
        errorCode: 'GOOGLE_ERROR',
      );
    }
  }

  Future<ApiAuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Registration error: ${e.toString()}',
        errorCode: 'REGISTRATION_ERROR',
      );
    }
  }

  Future<void> logout(String token) async {
    try {
      await _httpClient.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      // Log error but don't throw - logout should always succeed locally
    }
  }

  Future<ApiAuthResponse> resetPassword(String email) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Password reset error: ${e.toString()}',
        errorCode: 'RESET_ERROR',
      );
    }
  }

  Future<ApiAuthResponse> verifyEmail(String token, String code) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'code': code,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Email verification error: ${e.toString()}',
        errorCode: 'VERIFICATION_ERROR',
      );
    }
  }

  Future<ApiAuthResponse> refreshToken(String token) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return ApiAuthResponse.failure(
        errorMessage: 'Token refresh error: ${e.toString()}',
        errorCode: 'REFRESH_ERROR',
      );
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<ApiUserResponse> getUserProfile(String token) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserEntity.fromJson(data['user']);
        return ApiUserResponse.success(user: user);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiUserResponse.failure(
          errorMessage: errorData['message'] ?? 'Failed to get user profile',
          errorCode: errorData['code'],
        );
      }
    } catch (e) {
      return ApiUserResponse.failure(
        errorMessage: 'Profile fetch error: ${e.toString()}',
        errorCode: 'PROFILE_ERROR',
      );
    }
  }

  ApiAuthResponse _handleAuthResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ApiAuthResponse.success(
        token: data['token'],
        user: data['user'] != null ? UserEntity.fromJson(data['user']) : null,
      );
    } else {
      final errorData = jsonDecode(response.body);
      return ApiAuthResponse.failure(
        errorMessage: errorData['message'] ?? 'Request failed',
        errorCode: errorData['code'],
      );
    }
  }

  ApiAuthResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return ApiAuthResponse.success();
    } else {
      final errorData = jsonDecode(response.body);
      return ApiAuthResponse.failure(
        errorMessage: errorData['message'] ?? 'Request failed',
        errorCode: errorData['code'],
      );
    }
  }
}

class ApiAuthResponse {
  final bool isSuccess;
  final String? token;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;

  ApiAuthResponse({
    required this.isSuccess,
    this.token,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory ApiAuthResponse.success({
    String? token,
    UserEntity? user,
  }) {
    return ApiAuthResponse(
      isSuccess: true,
      token: token,
      user: user,
    );
  }

  factory ApiAuthResponse.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return ApiAuthResponse(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

class ApiUserResponse {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;

  ApiUserResponse({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory ApiUserResponse.success({UserEntity? user}) {
    return ApiUserResponse(
      isSuccess: true,
      user: user,
    );
  }

  factory ApiUserResponse.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return ApiUserResponse(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}