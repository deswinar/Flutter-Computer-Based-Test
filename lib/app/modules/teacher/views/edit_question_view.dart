import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/question_controller.dart';

class EditQuestionView extends StatefulWidget {
  final int questionIndex;

  const EditQuestionView({super.key, required this.questionIndex});

  @override
  State<EditQuestionView> createState() => _EditQuestionViewState();
}

class _EditQuestionViewState extends State<EditQuestionView> {
  final QuestionController controller = Get.find<QuestionController>();

  late TextEditingController questionController;
  late List<TextEditingController> optionControllers;
  int correctAnswer = 0;
  final List<String> optionLabels = ["A", "B", "C", "D"];

  @override
  void initState() {
    super.initState();

    // Get existing question data
    var questionData = controller.questions[widget.questionIndex];

    // Initialize controllers with existing data
    questionController = TextEditingController(
      text: questionData['question_text'],
    );
    List<String> options = List<String>.from(
      questionData['options'],
    ); // Convert JSONB array to List<String>

    optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: index < options.length ? options[index] : "",
      ),
    );

    correctAnswer = questionData['correct_answer'] ?? 0;
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
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

    controller.updateQuestion(
      controller.questions[widget
          .questionIndex]['id'], // Pass actual question ID from Supabase
      questionController.text,
      optionControllers.map((c) => c.text).toList(),
      correctAnswer,
      1,
    );

    Get.back();
  }

  void _deleteQuestion() {
    Get.defaultDialog(
      title: "Delete Question?",
      middleText: "Are you sure you want to delete this question?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteQuestion(
          controller.questions[widget.questionIndex]['id'],
        );
        Get.back(); // Close dialog
        Get.back(); // Go back to previous screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Question"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteQuestion,
          ),
        ],
      ),

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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateQuestion,
                    icon: const Icon(Icons.save),
                    label: const Text("Update Question"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
