import 'package:get/get.dart';

import 'package:cp_cbt/app/modules/student/controllers/available_tests_controller.dart';
import 'package:cp_cbt/app/modules/student/controllers/past_tests_controller.dart';
import 'package:cp_cbt/app/modules/student/controllers/student_test_controller.dart';
import 'package:cp_cbt/app/modules/student/controllers/take_test_controller.dart';
import 'package:cp_cbt/app/modules/student/controllers/test_details_controller.dart';
import 'package:cp_cbt/app/modules/student/controllers/upcoming_schedules_controller.dart';

import '../controllers/student_controller.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestDetailsController>(
      () => TestDetailsController(),
    );
    Get.lazyPut<PastTestsController>(
      () => PastTestsController(),
    );
    Get.lazyPut<UpcomingSchedulesController>(
      () => UpcomingSchedulesController(),
    );
    Get.lazyPut<TakeTestController>(
      () => TakeTestController(),
    );
    Get.lazyPut<StudentTestController>(() => StudentTestController());
    Get.lazyPut<AvailableTestsController>(() => AvailableTestsController());
    Get.lazyPut<StudentController>(() => StudentController());
  }
}
