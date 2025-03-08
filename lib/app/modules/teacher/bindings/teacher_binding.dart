import 'package:get/get.dart';

import '../controllers/question_controller.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/test_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionController>(() => QuestionController());
    Get.lazyPut<TestController>(() => TestController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<TeacherController>(() => TeacherController());
  }
}
