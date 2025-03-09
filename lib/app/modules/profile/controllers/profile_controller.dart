import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../models/user_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();
  final AuthRepository _authRepository = AuthRepository();

  var user =
      UserModel(
        id: '',
        email: '',
        name: '',
        role: '',
        createdAt: DateTime.now(),
      ).obs;

  var isLoading = false.obs;

  void loadUserProfile() async {
    isLoading.value = true;
    String? userId = _authRepository.currentUserId;
    if (userId == null) throw Exception("User not authenticated");
    final fetchedUser = await _repository.fetchUserProfile(userId);
    if (fetchedUser != null) {
      user.value = fetchedUser;
    }
    isLoading.value = false;
  }

  Future<void> updateUserName(String newName) async {
    isLoading.value = true;
    final success = await _repository.updateUserName(user.value.id, newName);
    if (success) {
      user.update((val) {
        val?.name = newName;
      });
      Get.snackbar('Success', 'Name updated successfully');
    } else {
      Get.snackbar('Error', 'Failed to update name');
    }
    isLoading.value = false;
  }
}
