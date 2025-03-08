import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GetStorage>(GetStorage(), permanent: true);
  }
}
