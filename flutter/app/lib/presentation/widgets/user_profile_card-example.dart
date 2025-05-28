import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../stores/user_store-example.dart';
import '../stores/auth_store-example.dart';
import '../stores/navigation_store-example.dart';

class UserProfileCardExample extends StatelessWidget {
  final bool showEditButton;
  final bool compact;

  const UserProfileCardExample({
    super.key,
    this.showEditButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final userStore = GetIt.instance<UserStore>();
    final authStore = GetIt.instance<AuthStore>();
    final navigationStore = GetIt.instance<NavigationStore>();

    return Observer(
      builder: (context) {
        if (userStore.isLoading) {
          return _buildLoadingCard(context);
        }

        if (userStore.hasError) {
          return _buildErrorCard(context, userStore, navigationStore);
        }

        if (!userStore.hasProfile) {
          return _buildEmptyCard(context);
        }

        return _buildProfileCard(
          context,
          userStore,
          authStore,
          navigationStore,
        );
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: compact ? 20 : 30,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    UserStore userStore,
    NavigationStore navigationStore,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (userStore.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                userStore.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => userStore.loadUserProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'No profile data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your profile to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    UserStore userStore,
    AuthStore authStore,
    NavigationStore navigationStore,
  ) {
    final profile = userStore.profile!;
    final stats = userStore.profileStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with avatar and basic info
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: compact ? 20 : 30,
                      backgroundImage: profile.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl?.isEmpty != false
                          ? Icon(
                              Icons.person,
                              size: compact ? 24 : 36,
                            )
                          : null,
                    ),
                    if (userStore.isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(compact ? 20 : 30),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userStore.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (!compact && profile.role?.isNotEmpty == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: authStore.canAccessAdminFeatures
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.role!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: authStore.canAccessAdminFeatures
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showEditButton)
                  IconButton(
                    onPressed: userStore.isUpdatingProfile
                        ? null
                        : () => navigationStore.navigateToProfile(),
                    icon: userStore.isUpdatingProfile
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_outlined),
                  ),
              ],
            ),

            if (!compact) ...[
              const SizedBox(height: 16),

              // Profile completeness indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Completeness',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${(stats['completeness'] * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: stats['completeness'],
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            userStore.isProfileComplete
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Additional profile info
              if (profile.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  profile.bio!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (profile.location?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],

              // Member since
              if (stats['memberSince'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Member since ${DateTime.parse(stats['memberSince']).year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}