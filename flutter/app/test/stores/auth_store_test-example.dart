import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/presentation/stores/auth_store-example.dart';
import '../../lib/domain/repositories/auth_repository-example.dart';
import '../../lib/domain/entities/user_entity-example.dart';

import 'auth_store_test-example.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthStore', () {
    late AuthStore authStore;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authStore = AuthStore(mockAuthRepository);
    });

    tearDown(() {
      authStore.dispose();
    });

    group('initialization', () {
      test('should initialize with correct default values', () {
        expect(authStore.isAuthenticated, false);
        expect(authStore.isInitialized, false);
        expect(authStore.token, null);
        expect(authStore.currentUser, null);
        expect(authStore.rememberMe, false);
        expect(authStore.isLoading, false);
        expect(authStore.hasError, false);
      });

      test('should load stored token and user on initialize', () async {
        // Arrange
        const token = 'test_token';
        final user = UserEntity(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthRepository.getStoredToken())
            .thenAnswer((_) async => token);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => user);

        // Act
        await authStore.initialize();

        // Assert
        expect(authStore.isInitialized, true);
        expect(authStore.isAuthenticated, true);
        expect(authStore.token, token);
        expect(authStore.currentUser, user);
        expect(authStore.isLoading, false);
        expect(authStore.hasError, false);
      });

      test('should logout if stored token is invalid', () async {
        // Arrange
        const token = 'invalid_token';

        when(mockAuthRepository.getStoredToken())
            .thenAnswer((_) async => token);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => {});

        // Act
        await authStore.initialize();

        // Assert
        expect(authStore.isInitialized, true);
        expect(authStore.isAuthenticated, false);
        expect(authStore.token, null);
        expect(authStore.currentUser, null);
        verify(mockAuthRepository.logout()).called(1);
      });
    });

    group('login', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'auth_token';
        final user = UserEntity(
          id: '1',
          name: 'Test User',
          email: email,
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthRepository.login(
          email: email,
          password: password,
          rememberMe: false,
        )).thenAnswer((_) async => AuthResult.success(
          token: token,
          user: user,
        ));

        // Act
        final result = await authStore.login(
          email: email,
          password: password,
        );

        // Assert
        expect(result, true);
        expect(authStore.isAuthenticated, true);
        expect(authStore.token, token);
        expect(authStore.currentUser, user);
        expect(authStore.isLoading, false);
        expect(authStore.hasError, false);
      });

      test('should handle login failure with error message', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        const errorMessage = 'Invalid credentials';

        when(mockAuthRepository.login(
          email: email,
          password: password,
          rememberMe: false,
        )).thenAnswer((_) async => AuthResult.failure(
          errorMessage: errorMessage,
        ));

        // Act
        final result = await authStore.login(
          email: email,
          password: password,
        );

        // Assert
        expect(result, false);
        expect(authStore.isAuthenticated, false);
        expect(authStore.token, null);
        expect(authStore.currentUser, null);
        expect(authStore.isLoading, false);
        expect(authStore.hasError, true);
        expect(authStore.errorMessage, errorMessage);
      });

      test('should set loading state during login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuthRepository.login(
          email: email,
          password: password,
          rememberMe: false,
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return AuthResult.success();
        });

        // Act & Assert
        expect(authStore.isLoading, false);
        
        final loginFuture = authStore.login(
          email: email,
          password: password,
        );
        
        expect(authStore.isLoading, true);
        
        await loginFuture;
        
        expect(authStore.isLoading, false);
      });
    });

    group('logout', () {
      test('should logout and clear user data', () async {
        // Arrange - Set up authenticated state
        authStore.token = 'test_token';
        authStore.isAuthenticated = true;
        authStore.currentUser = UserEntity(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthRepository.logout()).thenAnswer((_) async => {});

        // Act
        await authStore.logout();

        // Assert
        expect(authStore.isAuthenticated, false);
        expect(authStore.token, null);
        expect(authStore.currentUser, null);
        expect(authStore.rememberMe, false);
        verify(mockAuthRepository.logout()).called(1);
      });
    });

    group('computed properties', () {
      test('hasValidToken should return true when token exists', () {
        // Arrange
        authStore.token = 'valid_token';

        // Assert
        expect(authStore.hasValidToken, true);
      });

      test('hasValidToken should return false when token is null or empty', () {
        // Test null token
        authStore.token = null;
        expect(authStore.hasValidToken, false);

        // Test empty token
        authStore.token = '';
        expect(authStore.hasValidToken, false);
      });

      test('userDisplayName should return user name when available', () {
        // Arrange
        authStore.currentUser = UserEntity(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(authStore.userDisplayName, 'John Doe');
      });

      test('userDisplayName should return Guest when no user', () {
        // Arrange
        authStore.currentUser = null;

        // Assert
        expect(authStore.userDisplayName, 'Guest');
      });

      test('canAccessAdminFeatures should return true for admin users', () {
        // Arrange
        authStore.currentUser = UserEntity(
          id: '1',
          name: 'Admin User',
          email: 'admin@example.com',
          role: 'admin',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(authStore.canAccessAdminFeatures, true);
      });

      test('canAccessAdminFeatures should return false for non-admin users', () {
        // Arrange
        authStore.currentUser = UserEntity(
          id: '1',
          name: 'Regular User',
          email: 'user@example.com',
          role: 'user',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(authStore.canAccessAdminFeatures, false);
      });
    });

    group('error handling', () {
      test('should clear error when setting loading state', () {
        // Arrange
        authStore.setError('Test error');
        expect(authStore.hasError, true);

        // Act
        authStore.setLoading(true);

        // Assert
        expect(authStore.hasError, false);
        expect(authStore.errorMessage, null);
      });

      test('should set error and stop loading on error', () {
        // Arrange
        const errorMessage = 'Test error';
        authStore.setLoading(true);

        // Act
        authStore.setError(errorMessage);

        // Assert
        expect(authStore.hasError, true);
        expect(authStore.errorMessage, errorMessage);
        expect(authStore.isLoading, false);
      });
    });
  });
}