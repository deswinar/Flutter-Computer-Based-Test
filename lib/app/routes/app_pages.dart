import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/getting_started/bindings/getting_started_binding.dart';
import '../modules/getting_started/views/getting_started_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/student/bindings/student_binding.dart';
import '../modules/student/views/available_tests_view.dart';
import '../modules/student/views/past_tests_view.dart';
import '../modules/student/views/student_dashboard_view.dart';
import '../modules/student/views/take_test_view.dart';
import '../modules/student/views/test_details_view.dart';
import '../modules/student/views/upcoming_schedules_view.dart';
import '../modules/teacher/bindings/teacher_binding.dart';
import '../modules/teacher/views/manage_questions_view.dart';
import '../modules/teacher/views/manage_schedules_view.dart';
import '../modules/teacher/views/manage_tests_view.dart';
import '../modules/teacher/views/teacher_dashboard_view.dart';
import '../modules/unauthorized/views/unauthorized_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(name: _Paths.UNAUTHORIZED, page: () => UnauthorizedView()),
    GetPage(
      name: _Paths.GETTING_STARTED,
      page: () => GettingStartedView(),
      binding: GettingStartedBinding(),
    ),

    // Grouped Teacher Routes
    GetPage(
      name: _Paths.TEACHER_DASHBOARD,
      page: () => TeacherDashboardView(),
      binding: TeacherBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("teacher")],
    ),
    GetPage(
      name: _Paths.MANAGE_TESTS,
      page: () => ManageTestsView(),
      binding: TeacherBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("teacher")],
    ),
    GetPage(
      name: _Paths.MANAGE_SCHEDULES,
      page: () => ManageSchedulesView(),
      binding: TeacherBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("teacher")],
    ),
    GetPage(
      name: _Paths.MANAGE_QUESTIONS,
      page: () => ManageQuestionsView(),
      binding: TeacherBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("teacher")],
    ),
    GetPage(
      name: _Paths.STUDENT_DASHBOARD,
      page: () => StudentDashboardView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.AVAILABLE_TESTS,
      page: () => AvailableTestsView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.TAKE_TEST,
      page: () => TakeTestView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.UPCOMING_SCHEDULES,
      page: () => UpcomingSchedulesView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.PAST_TESTS,
      page: () => PastTestsView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.TEST_DETAILS,
      page: () => TestDetailsView(),
      binding: StudentBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware("student")],
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
