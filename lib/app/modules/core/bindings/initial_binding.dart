import 'package:get/get.dart';
import 'storage_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    StorageBinding().dependencies(); // ✅ Register GetStorage
  }
}
