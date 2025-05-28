import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:injectable/injectable.dart';

part 'navigation_store-example.g.dart';

@singleton
class NavigationStore = _NavigationStoreBase with _$NavigationStore;

abstract class _NavigationStoreBase with Store {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @observable
  int currentTabIndex = 0;

  @observable
  String currentRoute = '/';

  @observable
  List<String> navigationHistory = [];

  @observable
  bool canGoBack = false;

  @observable
  Map<String, dynamic> routeArguments = {};

  @computed
  NavigatorState? get navigator => navigatorKey.currentState;

  @computed
  BuildContext? get context => navigatorKey.currentContext;

  @computed
  bool get isOnMainTab => currentTabIndex == 0;

  @computed
  bool get hasNavigationHistory => navigationHistory.isNotEmpty;

  @action
  void setCurrentTab(int index) {
    currentTabIndex = index;
  }

  @action
  void setCurrentRoute(String route, {Map<String, dynamic>? arguments}) {
    currentRoute = route;
    routeArguments = arguments ?? {};
    _addToHistory(route);
    _updateCanGoBack();
  }

  void _addToHistory(String route) {
    if (navigationHistory.isEmpty || navigationHistory.last != route) {
      navigationHistory.add(route);
      // Keep history size manageable
      if (navigationHistory.length > 20) {
        navigationHistory.removeAt(0);
      }
    }
  }

  void _updateCanGoBack() {
    canGoBack = navigator?.canPop() ?? false;
  }

  @action
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) async {
    if (navigator == null) return null;

    setCurrentRoute(routeName, arguments: arguments as Map<String, dynamic>?);

    if (replace) {
      return await navigator!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } else {
      return await navigator!.pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  @action
  Future<T?> navigateToAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    if (navigator == null) return null;

    setCurrentRoute(routeName, arguments: arguments as Map<String, dynamic>?);
    navigationHistory.clear();

    return await navigator!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  @action
  void goBack<T extends Object?>([T? result]) {
    if (navigator?.canPop() == true) {
      navigator!.pop(result);
      if (navigationHistory.isNotEmpty) {
        navigationHistory.removeLast();
      }
      _updateCanGoBack();
    }
  }

  @action
  void goBackTo(String routeName) {
    if (navigator == null) return;

    navigator!.popUntil(ModalRoute.withName(routeName));
    
    // Update history
    final index = navigationHistory.lastIndexOf(routeName);
    if (index != -1) {
      navigationHistory = navigationHistory.sublist(0, index + 1);
    }
    _updateCanGoBack();
  }

  // Specific navigation methods for common routes
  @action
  Future<void> navigateToLogin() async {
    await navigateToAndClearStack('/login');
  }

  @action
  Future<void> navigateToHome() async {
    await navigateToAndClearStack('/home');
    currentTabIndex = 0;
  }

  @action
  Future<void> navigateToProfile() async {
    await navigateTo('/profile');
  }

  @action
  Future<void> navigateToSettings() async {
    await navigateTo('/settings');
  }

  @action
  Future<void> navigateToNotifications() async {
    await navigateTo('/notifications');
  }

  @action
  Future<T?> showDialog<T>(Widget dialog) async {
    if (context == null) return null;
    
    return await showDialog<T>(
      context: context!,
      builder: (context) => dialog,
    );
  }

  @action
  void showSnackBar(String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
      ),
    );
  }

  @action
  Future<T?> showBottomSheet<T>(Widget bottomSheet) async {
    if (context == null) return null;

    return await showModalBottomSheet<T>(
      context: context!,
      builder: (context) => bottomSheet,
    );
  }

  @action
  void clearHistory() {
    navigationHistory.clear();
  }

  void dispose() {
    // Clean up if needed
  }
}