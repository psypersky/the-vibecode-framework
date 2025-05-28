import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/presentation/widgets/user_profile_card-example.dart';
import '../../lib/presentation/stores/user_store-example.dart';
import '../../lib/presentation/stores/auth_store-example.dart';
import '../../lib/presentation/stores/navigation_store-example.dart';
import '../../lib/domain/entities/user_entity-example.dart';

import 'user_profile_card_test-example.mocks.dart';

@GenerateMocks([UserStore, AuthStore, NavigationStore])
void main() {
  group('UserProfileCardExample', () {
    late MockUserStore mockUserStore;
    late MockAuthStore mockAuthStore;
    late MockNavigationStore mockNavigationStore;

    setUp(() {
      mockUserStore = MockUserStore();
      mockAuthStore = MockAuthStore();
      mockNavigationStore = MockNavigationStore();

      // Register mocks with GetIt
      GetIt.instance.registerSingleton<UserStore>(mockUserStore);
      GetIt.instance.registerSingleton<AuthStore>(mockAuthStore);
      GetIt.instance.registerSingleton<NavigationStore>(mockNavigationStore);
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    Widget createTestWidget({
      bool showEditButton = true,
      bool compact = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: UserProfileCardExample(
            showEditButton: showEditButton,
            compact: compact,
          ),
        ),
      );
    }

    group('loading state', () {
      testWidgets('should show loading indicator when store is loading', (tester) async {
        // Arrange
        when(mockUserStore.isLoading).thenReturn(true);
        when(mockUserStore.hasError).thenReturn(false);
        when(mockUserStore.hasProfile).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Failed to load profile'), findsNothing);
      });
    });

    group('error state', () {
      testWidgets('should show error message when store has error', (tester) async {
        // Arrange
        const errorMessage = 'Network error occurred';
        when(mockUserStore.isLoading).thenReturn(false);
        when(mockUserStore.hasError).thenReturn(true);
        when(mockUserStore.errorMessage).thenReturn(errorMessage);
        when(mockUserStore.hasProfile).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Failed to load profile'), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should call loadUserProfile when retry button is tapped', (tester) async {
        // Arrange
        when(mockUserStore.isLoading).thenReturn(false);
        when(mockUserStore.hasError).thenReturn(true);
        when(mockUserStore.errorMessage).thenReturn('Error');
        when(mockUserStore.hasProfile).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Retry'));

        // Assert
        verify(mockUserStore.loadUserProfile()).called(1);
      });
    });

    group('empty state', () {
      testWidgets('should show empty state when no profile data', (tester) async {
        // Arrange
        when(mockUserStore.isLoading).thenReturn(false);
        when(mockUserStore.hasError).thenReturn(false);
        when(mockUserStore.hasProfile).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('No profile data'), findsOneWidget);
        expect(find.text('Complete your profile to get started'), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });
    });

    group('profile loaded state', () {
      late UserEntity testUser;

      setUp(() {
        testUser = UserEntity(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          bio: 'Software Developer',
          location: 'New York, NY',
          role: 'user',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime(2020, 1, 1),
          updatedAt: DateTime.now(),
        );

        when(mockUserStore.isLoading).thenReturn(false);
        when(mockUserStore.hasError).thenReturn(false);
        when(mockUserStore.hasProfile).thenReturn(true);
        when(mockUserStore.profile).thenReturn(testUser);
        when(mockUserStore.displayName).thenReturn(testUser.name);
        when(mockUserStore.isUpdatingProfile).thenReturn(false);
        when(mockUserStore.isUploadingAvatar).thenReturn(false);
        when(mockUserStore.profileStats).thenReturn({
          'completeness': 0.8,
          'memberSince': '2020-01-01T00:00:00.000Z',
        });

        when(mockAuthStore.canAccessAdminFeatures).thenReturn(false);
      });

      testWidgets('should display user profile information', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
        expect(find.text('Software Developer'), findsOneWidget);
        expect(find.text('New York, NY'), findsOneWidget);
      });

      testWidgets('should show profile completeness indicator', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Profile Completeness'), findsOneWidget);
        expect(find.text('80%'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should show member since information', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Member since 2020'), findsOneWidget);
      });

      testWidgets('should show edit button when showEditButton is true', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(showEditButton: true));

        // Assert
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });

      testWidgets('should hide edit button when showEditButton is false', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(showEditButton: false));

        // Assert
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      });

      testWidgets('should navigate to profile when edit button is tapped', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(showEditButton: true));
        await tester.tap(find.byIcon(Icons.edit_outlined));

        // Assert
        verify(mockNavigationStore.navigateToProfile()).called(1);
      });

      testWidgets('should show admin role badge for admin users', (tester) async {
        // Arrange
        final adminUser = testUser.copyWith(role: 'admin');
        when(mockUserStore.profile).thenReturn(adminUser);
        when(mockAuthStore.canAccessAdminFeatures).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('ADMIN'), findsOneWidget);
      });

      testWidgets('should show compact layout when compact is true', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(compact: true));

        // Assert
        // In compact mode, certain elements should not be visible
        expect(find.text('Profile Completeness'), findsNothing);
        expect(find.text('Software Developer'), findsNothing);
        expect(find.text('Member since 2020'), findsNothing);
      });
    });

    group('loading states for specific actions', () {
      late UserEntity testUser;

      setUp(() {
        testUser = UserEntity(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          isEmailVerified: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockUserStore.isLoading).thenReturn(false);
        when(mockUserStore.hasError).thenReturn(false);
        when(mockUserStore.hasProfile).thenReturn(true);
        when(mockUserStore.profile).thenReturn(testUser);
        when(mockUserStore.displayName).thenReturn(testUser.name);
        when(mockUserStore.profileStats).thenReturn({'completeness': 1.0});
        when(mockAuthStore.canAccessAdminFeatures).thenReturn(false);
      });

      testWidgets('should show loading indicator when updating profile', (tester) async {
        // Arrange
        when(mockUserStore.isUpdatingProfile).thenReturn(true);
        when(mockUserStore.isUploadingAvatar).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show loading overlay when uploading avatar', (tester) async {
        // Arrange
        when(mockUserStore.isUpdatingProfile).thenReturn(false);
        when(mockUserStore.isUploadingAvatar).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        // Should find avatar upload loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}