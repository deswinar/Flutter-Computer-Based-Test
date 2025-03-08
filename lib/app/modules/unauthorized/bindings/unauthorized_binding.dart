import 'package:get/get.dart';

import '../controllers/unauthorized_controller.dart';

class UnauthorizedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnauthorizedController>(
      () => UnauthorizedController(),
    );
  }
}
