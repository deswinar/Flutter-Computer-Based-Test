import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  var userData = Rxn<Map<String, dynamic>>(); // Observable user data
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ✅ Get the user ID
      String userId = session.user.id;

      // ✅ Fetch user data (including role)
      final data = await _authRepository.getUserData(userId);

      if (data != null && data['role'] != null) {
        String role = data['role'];

        if (role == 'teacher') {
          Get.offNamed(
            Routes.TEACHER_DASHBOARD,
          ); // ✅ Navigate to teacher dashboard
        } else if (role == 'student') {
          Get.offNamed(
            Routes.STUDENT_DASHBOARD,
          ); // ✅ Navigate to student dashboard
        } else {
          Get.offNamed(
            Routes.GETTING_STARTED,
          ); // ✅ Default fallback if role is unknown
        }
      } else {
        Get.offNamed(Routes.GETTING_STARTED); // ✅ If no data, go to login
      }
    } else {
      Get.offNamed(
        Routes.GETTING_STARTED,
      ); // ✅ If not authenticated, go to login
    }
  }
}
