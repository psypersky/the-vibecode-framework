import 'package:mobx/mobx.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/user_repository-example.dart';
import '../../../domain/entities/user_entity-example.dart';
import 'base_store-example.dart';

part 'user_store-example.g.dart';

@singleton
class UserStore extends BaseStore {
  final UserRepository _userRepository;

  UserStore(this._userRepository);

  @observable
  UserEntity? profile;

  @observable
  List<UserEntity> searchResults = [];

  @observable
  bool isUpdatingProfile = false;

  @observable
  bool isUploadingAvatar = false;

  @computed
  bool get hasProfile => profile != null;

  @computed
  String get displayName => profile?.name ?? 'Unknown User';

  @computed
  String get avatarUrl => profile?.avatarUrl ?? '';

  @computed
  bool get isProfileComplete => 
      profile != null && 
      profile!.name.isNotEmpty && 
      profile!.email.isNotEmpty;

  @computed
  Map<String, dynamic> get profileStats => {
    'completeness': _calculateProfileCompleteness(),
    'lastUpdated': profile?.updatedAt?.toIso8601String(),
    'memberSince': profile?.createdAt?.toIso8601String(),
  };

  double _calculateProfileCompleteness() {
    if (profile == null) return 0.0;
    
    int completedFields = 0;
    const int totalFields = 5;
    
    if (profile!.name.isNotEmpty) completedFields++;
    if (profile!.email.isNotEmpty) completedFields++;
    if (profile!.avatarUrl?.isNotEmpty == true) completedFields++;
    if (profile!.bio?.isNotEmpty == true) completedFields++;
    if (profile!.location?.isNotEmpty == true) completedFields++;
    
    return completedFields / totalFields;
  }

  @action
  Future<void> loadUserProfile() async {
    await executeWithLoading(() async {
      profile = await _userRepository.getCurrentUserProfile();
    });
  }

  @action
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? phoneNumber,
  }) async {
    if (profile == null) return false;

    isUpdatingProfile = true;
    
    try {
      final updatedProfile = profile!.copyWith(
        name: name ?? profile!.name,
        bio: bio ?? profile!.bio,
        location: location ?? profile!.location,
        phoneNumber: phoneNumber ?? profile!.phoneNumber,
        updatedAt: DateTime.now(),
      );

      final result = await _userRepository.updateProfile(updatedProfile);
      
      if (result.isSuccess) {
        profile = result.user;
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      isUpdatingProfile = false;
    }
  }

  @action
  Future<bool> uploadAvatar(String imagePath) async {
    if (profile == null) return false;

    isUploadingAvatar = true;
    
    try {
      final result = await _userRepository.uploadAvatar(imagePath);
      
      if (result.isSuccess) {
        profile = profile!.copyWith(
          avatarUrl: result.avatarUrl,
          updatedAt: DateTime.now(),
        );
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to upload avatar');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      isUploadingAvatar = false;
    }
  }

  @action
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    await executeWithLoading(() async {
      searchResults = await _userRepository.searchUsers(query);
    });
  }

  @action
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await executeWithLoading(() async {
      final result = await _userRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (!result.isSuccess) {
        setError(result.errorMessage ?? 'Failed to change password');
      }
      
      return result.isSuccess;
    });
  }

  @action
  Future<bool> deleteAccount() async {
    return await executeWithLoading(() async {
      final result = await _userRepository.deleteAccount();
      
      if (result.isSuccess) {
        clearUser();
      } else {
        setError(result.errorMessage ?? 'Failed to delete account');
      }
      
      return result.isSuccess;
    });
  }

  @action
  void clearUser() {
    profile = null;
    searchResults.clear();
    clearError();
  }

  @action
  void clearSearchResults() {
    searchResults.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }
}