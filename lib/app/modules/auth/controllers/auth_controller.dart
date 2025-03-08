import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final box = GetStorage();

  Rxn<User> user = Rxn<User>();
  RxString userRole = "".obs;

  var userData = Rxn<Map<String, dynamic>>(); // Observable to store user data
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedUser();
  }

  void loadCachedUser() {
    final cachedRole = box.read<String>('role');
    if (cachedRole != null) {
      userRole.value = cachedRole;
    }
  }

  /// Fetch user data and return it
  Future<Map<String, dynamic>?> fetchUserData() async {
    isLoading.value = true;
    try {
      String? userId = _authRepository.currentUserId; // Get current user ID
      if (userId == null) throw Exception("User not authenticated");

      final data = await _authRepository.getUserData(userId);
      userData.value = data; // Store it in the observable

      return data; // ✅ Return the user data
    } catch (e) {
      print("Error in fetchUserData: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final response = await _authRepository.signUp(
        email,
        password,
        name,
        role,
      );

      if (response.user != null) {
        user.value = response.user;
        userRole.value = role;

        // Cache role locally
        box.write('userRole', userRole.value);

        // Navigate based on role
        if (role == "teacher") {
          Get.offAllNamed(Routes.TEACHER_DASHBOARD);
        } else {
          Get.offAllNamed(Routes.STUDENT_DASHBOARD);
        }
      }
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authRepository.signIn(email, password);

      if (response != null) {
        user.value = response['user'];
        userRole.value = response['role'];

        // Cache role locally
        box.write('userRole', userRole.value);

        // Navigate based on role
        if (userRole.value == "teacher") {
          Get.offAllNamed(Routes.TEACHER_DASHBOARD);
        } else {
          Get.offAllNamed(Routes.STUDENT_DASHBOARD);
        }
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    box.remove('userRole');
    user.value = null;
    userRole.value = "";
    Get.offAllNamed("/login");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
