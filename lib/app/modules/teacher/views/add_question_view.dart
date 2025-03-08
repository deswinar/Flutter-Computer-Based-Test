import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/question_controller.dart';

class AddQuestionView extends StatefulWidget {
  const AddQuestionView({super.key});

  @override
  State<AddQuestionView> createState() => _AddQuestionViewState();
}

class _AddQuestionViewState extends State<AddQuestionView> {
  final QuestionController controller = Get.find<QuestionController>();

  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  int correctAnswer = 0;
  final List<String> optionLabels = ["A", "B", "C", "D"];

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (questionController.text.isEmpty ||
        optionControllers.any((c) => c.text.isEmpty)) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.addQuestion(
      questionController.text,
      optionControllers.map((c) => c.text).toList(),
      correctAnswer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Question")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Input
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: "Question Text",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options Input
            const Text(
              "Options",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Column(
              children: List.generate(4, (index) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: "Option ${optionLabels[index]}",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Select Correct Answer
            const Text(
              "Select the correct answer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(4, (index) {
                return RadioListTile<int>(
                  title: Text("Option ${optionLabels[index]}"),
                  value: index,
                  groupValue: correctAnswer,
                  onChanged: (value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                  activeColor: Colors.green,
                );
              }),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.check),
                label: const Text("Add Question"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
