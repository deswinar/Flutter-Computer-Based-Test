import 'package:get/get.dart';
import '../../../data/repositories/test_details_repository.dart';

class TestDetailsController extends GetxController {
  final TestDetailsRepository _repository = TestDetailsRepository();

  var testTitle = ''.obs;
  var testDescription = ''.obs;
  var testDuration = 0.obs;
  var questions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchTestDetails(String studentTestId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final details = await _repository.getTestDetails(studentTestId);

      // Extract test metadata
      testTitle.value = details['test']['title'];
      testDescription.value = details['test']['description'];
      testDuration.value = details['test']['duration'];

      // Extract and update questions
      questions.assignAll(details['questions']);
    } catch (e) {
      errorMessage.value = 'Error fetching test details: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
