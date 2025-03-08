import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/question_controller.dart';
import 'add_question_view.dart';
import 'edit_question_view.dart';

class ManageQuestionsView extends StatelessWidget {
  final QuestionController controller = Get.find<QuestionController>();

  ManageQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Get.back()),
        title: const Text("Manage Questions"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.testTitle.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(controller.testDescription.value),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.questions.isEmpty) {
                return const Center(child: Text("No questions available"));
              }

              return ReorderableListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--; // Adjust for index shift
                  controller.reorderQuestions(oldIndex, newIndex);
                },
                children: List.generate(controller.questions.length, (index) {
                  final question = controller.questions[index];

                  return Dismissible(
                    key: Key(question['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await Get.defaultDialog(
                        title: "Delete Question?",
                        middleText:
                            "Are you sure you want to delete this question?",
                        textConfirm: "Yes",
                        textCancel: "No",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.deleteQuestion(question['id']);
                          Get.back();
                        },
                      );
                    },
                    child: Card(
                      key: ValueKey(question['id']), // Required for reordering
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle), // Drag icon
                        title: Text(
                          "${index + 1}. ${question['question_text']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            (question['options'] as List).length,
                            (i) {
                              final List<String> optionLabels = [
                                "A",
                                "B",
                                "C",
                                "D",
                              ];
                              return Text(
                                "${optionLabels[i]}. ${(question['options'] as List)[i]}",
                                style: TextStyle(
                                  fontWeight:
                                      i == question['correct_answer']
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      i == question['correct_answer']
                                          ? Colors.green
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Get.to(
                              () => EditQuestionView(
                                questionIndex: question['question_number'] - 1,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddQuestionView()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
