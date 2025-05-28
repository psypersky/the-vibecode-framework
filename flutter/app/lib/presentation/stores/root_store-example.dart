import 'package:mobx/mobx.dart';
import 'package:get_it/get_it.dart';
import 'auth_store-example.dart';
import 'user_store-example.dart';
import 'navigation_store-example.dart';
import 'theme_store-example.dart';

part 'root_store-example.g.dart';

class RootStore = _RootStoreBase with _$RootStore;

abstract class _RootStoreBase with Store {
  late final AuthStore authStore;
  late final UserStore userStore;
  late final NavigationStore navigationStore;
  late final ThemeStore themeStore;

  _RootStoreBase() {
    authStore = GetIt.instance<AuthStore>();
    userStore = GetIt.instance<UserStore>();
    navigationStore = GetIt.instance<NavigationStore>();
    themeStore = GetIt.instance<ThemeStore>();
    
    _setupReactions();
  }

  List<ReactionDisposer>? _disposers;

  void _setupReactions() {
    _disposers = [
      // Navigate to login when user logs out
      reaction(
        (_) => authStore.isAuthenticated,
        (bool isAuthenticated) {
          if (!isAuthenticated) {
            navigationStore.navigateToLogin();
            userStore.clearUser();
          }
        },
      ),
      
      // Load user data when authenticated
      reaction(
        (_) => authStore.isAuthenticated,
        (bool isAuthenticated) {
          if (isAuthenticated && authStore.token != null) {
            userStore.loadUserProfile();
          }
        },
      ),
    ];
  }

  @computed
  bool get isAppReady => authStore.isInitialized && themeStore.isInitialized;

  @action
  Future<void> initialize() async {
    await Future.wait([
      authStore.initialize(),
      themeStore.initialize(),
    ]);
  }

  void dispose() {
    _disposers?.forEach((dispose) => dispose());
    authStore.dispose();
    userStore.dispose();
    navigationStore.dispose();
    themeStore.dispose();
  }
}