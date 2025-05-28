# Flutter MobX Architecture Example

This is a comprehensive, professional example of Flutter application architecture using MobX for state management, optimized for Claude Code understanding and assistance.

## 🎯 Architecture Overview

This example demonstrates enterprise-grade Flutter development with:

- **Clean Architecture**: Separation of data, domain, and presentation layers
- **MobX State Management**: Reactive programming with observables, actions, and computed values
- **Dependency Injection**: Using `get_it` and `injectable` for scalable dependency management
- **Repository Pattern**: Abstracted data access with interfaces and implementations
- **Code Generation**: Automated code generation for MobX, JSON serialization, and DI
- **Comprehensive Testing**: Unit tests for stores and widget tests for UI components

## 📁 Project Structure

```
lib/
├── core/
│   ├── di/                           # Dependency injection setup
│   │   ├── injection-example.dart    # Main DI configuration
│   │   └── injection-example.config.dart  # Generated DI code
│   ├── constants/
│   │   └── app_themes-example.dart   # Theme configurations
│   └── utils/                        # Utility functions
├── data/
│   ├── datasources/                  # External data sources
│   │   ├── auth_api_service-example.dart     # API service
│   │   └── auth_local_service-example.dart   # Local storage
│   └── repositories/                 # Repository implementations
│       └── auth_repository_impl-example.dart
├── domain/
│   ├── entities/                     # Business entities
│   │   └── user_entity-example.dart  # User domain model
│   └── repositories/                 # Repository interfaces
│       ├── auth_repository-example.dart
│       ├── user_repository-example.dart
│       └── preferences_repository-example.dart
├── presentation/
│   ├── stores/                       # MobX stores
│   │   ├── root_store-example.dart   # Root store container
│   │   ├── auth_store-example.dart   # Authentication state
│   │   ├── user_store-example.dart   # User profile state
│   │   ├── navigation_store-example.dart  # Navigation state
│   │   └── theme_store-example.dart  # Theme state
│   ├── pages/                        # Page widgets
│   │   └── login_page-example.dart   # Login page
│   └── widgets/                      # Reusable widgets
│       ├── loading_overlay-example.dart
│       ├── error_banner-example.dart
│       └── user_profile_card-example.dart
└── main-example.dart                 # App entry point

test/
├── stores/                           # Store unit tests
│   └── auth_store_test-example.dart
└── widgets/                          # Widget tests
    └── user_profile_card_test-example.dart
```

## 🚀 Getting Started

### 1. Dependencies

Copy the dependencies from `pubspec-example.yaml` to your `pubspec.yaml`:

```yaml
dependencies:
  mobx: ^2.3.3+2
  flutter_mobx: ^2.2.1+1
  get_it: ^7.6.4
  injectable: ^2.3.2
  shared_preferences: ^2.2.2
  http: ^1.1.0
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.7
  mobx_codegen: ^2.6.1
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  mockito: ^5.4.2
```

### 2. Code Generation

Run code generation to create necessary files:

```bash
# Install dependencies
flutter pub get

# Generate code (one-time)
flutter packages pub run build_runner build

# Generate code (watch mode for development)
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### 3. Main App Setup

Update your `main.dart` based on `main-example.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize root store
  final rootStore = RootStore();
  GetIt.instance.registerSingleton<RootStore>(rootStore);

  // Initialize the app
  await rootStore.initialize();

  runApp(MyApp(rootStore: rootStore));
}
```

## 🏗️ Architecture Patterns

### Store Hierarchy

1. **RootStore**: Manages all feature stores and global reactions
2. **Feature Stores**: Handle specific domain logic (auth, user, etc.)
3. **UI Stores**: Manage UI-specific state (navigation, theme)

### Store Best Practices

```dart
// Always extend BaseStore for common functionality
class AuthStore extends BaseStore {
  
  // Use observables for reactive state
  @observable
  bool isAuthenticated = false;
  
  // Use computed values for derived state
  @computed
  String get userDisplayName => currentUser?.name ?? 'Guest';
  
  // Use actions for state mutations
  @action
  Future<bool> login(String email, String password) async {
    return await executeWithLoading(() async {
      // Business logic here
    });
  }
}
```

### Widget Integration

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = GetIt.instance<AuthStore>();
    
    return Observer(
      builder: (context) {
        if (store.isLoading) {
          return CircularProgressIndicator();
        }
        
        return YourWidgetContent();
      },
    );
  }
}
```

## 🧪 Testing

### Store Testing

```dart
group('AuthStore', () {
  late AuthStore authStore;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authStore = AuthStore(mockRepository);
  });

  test('should login successfully', () async {
    // Arrange
    when(mockRepository.login(...)).thenAnswer((_) async => 
        AuthResult.success(token: 'token'));

    // Act
    final result = await authStore.login('email', 'password');

    // Assert
    expect(result, true);
    expect(authStore.isAuthenticated, true);
  });
});
```

### Widget Testing

```dart
testWidgets('should display user profile', (tester) async {
  // Arrange
  when(mockUserStore.hasProfile).thenReturn(true);
  when(mockUserStore.profile).thenReturn(testUser);

  // Act
  await tester.pumpWidget(createTestWidget());

  // Assert
  expect(find.text('John Doe'), findsOneWidget);
});
```

## 📱 Features Demonstrated

### Authentication Flow
- Login with email/password
- Google Sign-In integration
- Token management and persistence
- Auto-logout on token expiry

### User Management
- Profile loading and editing
- Avatar upload with progress
- Profile completeness tracking
- User search functionality

### Theme Management
- Light/dark theme switching
- System theme detection
- Custom accent colors
- Font size adjustment

### Navigation
- Programmatic navigation
- Route argument passing
- Navigation history tracking
- Deep linking support

## 🎨 UI Components

### Loading States
- Overlay loading indicators
- Inline loading spinners
- Skeleton placeholders

### Error Handling
- Error banners with retry actions
- Global error boundaries
- User-friendly error messages

### Responsive Design
- Compact and full layouts
- Adaptive UI components
- Theme-aware styling

## 🔧 Development Commands

```bash
# Run code generation
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .
```

## 📋 Claude Code Optimization

This architecture is specifically optimized for Claude Code assistance:

### File Naming Convention
- All example files end with `-example` for easy identification
- Clear, descriptive names indicating purpose
- Consistent naming patterns across layers

### Code Organization
- Single responsibility principle
- Clear separation of concerns
- Consistent import ordering
- Comprehensive documentation

### Testing Strategy
- Comprehensive test coverage
- Clear test structure and naming
- Mock implementations for external dependencies
- Both unit and widget tests

## 🚀 Production Considerations

### Performance
- Use `@computed` for expensive calculations
- Implement proper `dispose` methods
- Optimize Observer widget usage
- Implement proper error boundaries

### Security
- Never expose API keys in code
- Implement proper token refresh logic
- Use secure storage for sensitive data
- Validate all user inputs

### Scalability
- Modular store architecture
- Lazy loading of features
- Proper dependency injection
- Code generation for boilerplate

## 📖 Further Reading

- [MobX Documentation](https://mobx.netlify.app/)
- [Injectable Documentation](https://pub.dev/packages/injectable)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Clean Architecture in Flutter](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)

This architecture provides a solid foundation for building scalable, maintainable Flutter applications with excellent Claude Code integration for AI-assisted development.