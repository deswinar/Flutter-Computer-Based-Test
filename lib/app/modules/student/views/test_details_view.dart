import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_details_controller.dart';

class TestDetailsView extends StatefulWidget {
  const TestDetailsView({super.key});

  @override
  _TestDetailsViewState createState() => _TestDetailsViewState();
}

class _TestDetailsViewState extends State<TestDetailsView> {
  final TestDetailsController _controller = Get.put(TestDetailsController());

  @override
  void initState() {
    super.initState();

    // Fetch studentTestId from GetX arguments
    final studentTestId = Get.arguments?['student_test_id'] ?? '';

    if (studentTestId.isNotEmpty) {
      _controller.fetchTestDetails(studentTestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Details')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(child: Text(_controller.errorMessage.value));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test metadata section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.testTitle.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _controller.testDescription.value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Duration: ${_controller.testDuration.value} minutes",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Questions list
            Expanded(
              child: ListView.builder(
                itemCount: _controller.questions.length,
                itemBuilder: (context, index) {
                  final question = _controller.questions[index];
                  final questionText = question['questions']['question_text'];
                  final options = List<String>.from(
                    question['questions']['options'],
                  );
                  final correctAnswer = question['questions']['correct_answer'];
                  final selectedAnswer = question['selected_answer'];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: $questionText',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...options.asMap().entries.map((entry) {
                            final optionIndex = entry.key;
                            final optionText = entry.value;
                            final isCorrect = optionIndex == correctAnswer;
                            final isSelected = optionIndex == selectedAnswer;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? (isCorrect
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.red.withOpacity(0.3))
                                        : null,
                                border: Border.all(
                                  color: isCorrect ? Colors.green : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListTile(
                                title: Text(optionText),
                                leading: Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                ),
                                trailing:
                                    isSelected
                                        ? Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          color:
                                              isCorrect
                                                  ? Colors.blue
                                                  : Colors.red,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
