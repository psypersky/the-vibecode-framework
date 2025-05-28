import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection-example.dart';
import 'presentation/stores/root_store-example.dart';
import 'presentation/stores/theme_store-example.dart';
import 'presentation/stores/navigation_store-example.dart';
import 'presentation/pages/login_page-example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize root store
  final rootStore = RootStore();
  GetIt.instance.registerSingleton<RootStore>(rootStore);

  // Initialize the app
  await rootStore.initialize();

  runApp(MyAppExample(rootStore: rootStore));
}

class MyAppExample extends StatelessWidget {
  final RootStore rootStore;

  const MyAppExample({
    super.key,
    required this.rootStore,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        // Show loading screen while app is initializing
        if (!rootStore.isAppReady) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing App...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'Flutter MobX Example',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration from ThemeStore
          theme: rootStore.themeStore.lightTheme,
          darkTheme: rootStore.themeStore.darkTheme,
          themeMode: rootStore.themeStore.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
          
          // Navigation configuration
          navigatorKey: rootStore.navigationStore.navigatorKey,
          
          // Route configuration
          initialRoute: rootStore.authStore.isAuthenticated ? '/home' : '/login',
          routes: {
            '/login': (context) => const LoginPageExample(),
            '/home': (context) => const HomePageExample(),
            '/profile': (context) => const ProfilePageExample(),
            '/settings': (context) => const SettingsPageExample(),
          },
          
          // Global navigation observer for store updates
          navigatorObservers: [
            AppNavigatorObserver(rootStore.navigationStore),
          ],
          
          // Global theme updates based on system theme
          builder: (context, child) {
            // Update theme store when system theme changes
            final brightness = MediaQuery.of(context).platformBrightness;
            rootStore.themeStore.updateSystemTheme(brightness == Brightness.dark);
            
            return child!;
          },
        );
      },
    );
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  final NavigationStore _navigationStore;

  AppNavigatorObserver(this._navigationStore);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _navigationStore.setCurrentRoute(
        route.settings.name!,
        arguments: route.settings.arguments as Map<String, dynamic>?,
      );
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      _navigationStore.setCurrentRoute(
        newRoute!.settings.name!,
        arguments: newRoute.settings.arguments as Map<String, dynamic>?,
      );
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      _navigationStore.setCurrentRoute(
        previousRoute!.settings.name!,
        arguments: previousRoute.settings.arguments as Map<String, dynamic>?,
      );
    }
  }
}

// Example home page
class HomePageExample extends StatelessWidget {
  const HomePageExample({super.key});

  @override
  Widget build(BuildContext context) {
    final rootStore = GetIt.instance<RootStore>();

    return Observer(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: Icon(
                rootStore.themeStore.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => rootStore.themeStore.toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => rootStore.navigationStore.navigateToSettings(),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${rootStore.authStore.userDisplayName}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => rootStore.navigationStore.navigateToProfile(),
                child: const Text('View Profile'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => rootStore.authStore.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages
class ProfilePageExample extends StatelessWidget {
  const ProfilePageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
    );
  }
}

class SettingsPageExample extends StatelessWidget {
  const SettingsPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}