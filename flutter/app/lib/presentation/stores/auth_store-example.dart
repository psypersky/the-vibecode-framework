import 'package:mobx/mobx.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/auth_repository-example.dart';
import '../../../domain/entities/user_entity-example.dart';
import 'base_store-example.dart';

part 'auth_store-example.g.dart';

@singleton
class AuthStore extends BaseStore {
  final AuthRepository _authRepository;

  AuthStore(this._authRepository);

  @observable
  bool isAuthenticated = false;

  @observable
  bool isInitialized = false;

  @observable
  String? token;

  @observable
  UserEntity? currentUser;

  @observable
  bool rememberMe = false;

  @computed
  bool get hasValidToken => token != null && token!.isNotEmpty;

  @computed
  String get userDisplayName => currentUser?.name ?? 'Guest';

  @computed
  bool get canAccessAdminFeatures => currentUser?.role == 'admin';

  @action
  Future<void> initialize() async {
    await executeWithLoading(() async {
      token = await _authRepository.getStoredToken();
      if (token != null) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          currentUser = user;
          isAuthenticated = true;
        } else {
          await logout();
        }
      }
      isInitialized = true;
    });
  }

  @action
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    this.rememberMe = rememberMe;
    
    return await executeWithLoading(() async {
      final result = await _authRepository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      if (result.isSuccess) {
        token = result.token;
        currentUser = result.user;
        isAuthenticated = true;
        return true;
      } else {
        setError(result.errorMessage ?? 'Login failed');
        return false;
      }
    });
  }

  @action
  Future<bool> loginWithGoogle() async {
    return await executeWithLoading(() async {
      final result = await _authRepository.loginWithGoogle();
      
      if (result.isSuccess) {
        token = result.token;
        currentUser = result.user;
        isAuthenticated = true;
        return true;
      } else {
        setError(result.errorMessage ?? 'Google login failed');
        return false;
      }
    });
  }

  @action
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await executeWithLoading(() async {
      final result = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      
      if (result.isSuccess) {
        token = result.token;
        currentUser = result.user;
        isAuthenticated = true;
        return true;
      } else {
        setError(result.errorMessage ?? 'Registration failed');
        return false;
      }
    });
  }

  @action
  Future<void> logout() async {
    await executeWithLoading(() async {
      await _authRepository.logout();
      token = null;
      currentUser = null;
      isAuthenticated = false;
      rememberMe = false;
    });
  }

  @action
  Future<bool> resetPassword(String email) async {
    return await executeWithLoading(() async {
      final result = await _authRepository.resetPassword(email);
      if (!result.isSuccess) {
        setError(result.errorMessage ?? 'Password reset failed');
      }
      return result.isSuccess;
    });
  }

  @action
  Future<bool> verifyEmail(String code) async {
    return await executeWithLoading(() async {
      final result = await _authRepository.verifyEmail(code);
      if (result.isSuccess && result.user != null) {
        currentUser = result.user;
        return true;
      } else {
        setError(result.errorMessage ?? 'Email verification failed');
        return false;
      }
    });
  }

  @action
  void updateUser(UserEntity user) {
    currentUser = user;
  }

  @override
  void dispose() {
    super.dispose();
  }
}