# Flutter MobX Architecture Guide - Example

## Overview

This architecture demonstrates professional Flutter development using MobX for state management, following the latest best practices for enterprise-grade applications.

## Architecture Principles

### 1. Separation of Concerns
- **Presentation Layer**: Widgets and UI components
- **Business Logic Layer**: MobX stores and business rules
- **Data Layer**: Repositories and data sources
- **Domain Layer**: Models and entities

### 2. Dependency Injection
- Use `get_it` for service location and dependency injection
- Register dependencies at app startup
- Inject dependencies into stores and services

### 3. Reactive Programming
- MobX observables for reactive state management
- Actions for state mutations
- Computed values for derived state
- Reactions for side effects

## Directory Structure

```
lib/
├── core/
│   ├── di/                    # Dependency injection setup
│   ├── constants/             # App constants
│   ├── themes/               # App themes
│   └── utils/                # Utility functions
├── data/
│   ├── datasources/          # API and local data sources
│   ├── repositories/         # Repository implementations
│   └── models/               # Data models with JSON serialization
├── domain/
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/            # Business use cases
├── presentation/
│   ├── stores/              # MobX stores
│   ├── pages/               # Page widgets
│   ├── widgets/             # Reusable widgets
│   └── theme/               # Theme-related widgets
└── main.dart                # App entry point
```

## MobX Store Patterns

### Store Hierarchy
1. **Root Store**: Contains all child stores
2. **Feature Stores**: Specific to app features (auth, user, products)
3. **UI Stores**: Manage UI state (navigation, dialogs, loading)

### Store Best Practices
- Use abstract base classes for common store functionality
- Implement proper error handling with observable error states
- Use computed values for derived data
- Keep stores focused on single responsibilities
- Use reactions for side effects (navigation, notifications)

## File Naming Conventions

### Stores
- `{feature}_store.dart` - Store implementation
- `{feature}_store.g.dart` - Generated code (auto-generated)

### Models
- `{entity}_model.dart` - Data models
- `{entity}_entity.dart` - Domain entities

### Repositories
- `{feature}_repository.dart` - Repository interface
- `{feature}_repository_impl.dart` - Repository implementation

### Pages/Widgets
- `{feature}_page.dart` - Page widgets
- `{feature}_widget.dart` - Reusable widgets

## Code Generation

This architecture uses code generation for:
- MobX store boilerplate (`build_runner`)
- JSON serialization (`json_annotation`)
- Dependency injection (`injectable`)

### Required Dependencies

```yaml
dependencies:
  mobx: ^2.3.3+2
  flutter_mobx: ^2.2.1+1
  get_it: ^7.6.4
  injectable: ^2.3.2
  json_annotation: ^4.8.1
  
dev_dependencies:
  mobx_codegen: ^2.6.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
```

### Build Commands

```bash
# Generate MobX and JSON code
flutter packages pub run build_runner build

# Watch for changes and auto-generate
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

## Testing Strategy

### Store Testing
- Test observable state changes
- Test action execution
- Test computed value calculations
- Mock dependencies using `mockito`

### Widget Testing
- Test widget behavior with store state changes
- Use `Provider.value()` to inject mock stores
- Test user interactions trigger correct actions

### Integration Testing
- Test complete user flows
- Test real API interactions
- Test navigation flows

## Performance Considerations

### MobX Optimizations
- Use `@computed` for expensive calculations
- Implement `@action` for all state mutations
- Use `runInAction` for async operations
- Minimize observer widget rebuilds

### Widget Optimizations
- Use `Observer` widget judiciously
- Implement proper `build` method optimizations
- Use `const` constructors where possible
- Implement proper `dispose` methods

## Error Handling

### Store Error Patterns
- Observable error state in stores
- Error recovery mechanisms
- User-friendly error messages
- Proper logging and monitoring

### Global Error Handling
- Global error boundary
- Crash reporting integration
- Network error handling
- Validation error handling

## Navigation

### MobX Navigation Pattern
- Use navigator store for programmatic navigation
- Implement deep linking support
- Handle navigation state in stores
- Use reactions for navigation side effects

## Best Practices Summary

1. **Store Design**
   - Keep stores focused and cohesive
   - Use composition over inheritance
   - Implement proper lifecycle management
   - Handle loading and error states

2. **Widget Integration**
   - Use Observer widgets efficiently
   - Implement proper error boundaries
   - Handle loading states gracefully
   - Optimize rebuilds

3. **Code Organization**
   - Follow consistent naming conventions
   - Group related functionality
   - Use barrel exports for clean imports
   - Implement proper documentation

4. **Testing**
   - Write comprehensive store tests
   - Test widget-store integration
   - Implement integration tests
   - Use proper mocking strategies

This architecture provides a solid foundation for scalable Flutter applications with MobX state management.