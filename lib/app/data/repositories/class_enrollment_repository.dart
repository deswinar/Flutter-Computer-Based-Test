import 'package:supabase_flutter/supabase_flutter.dart';

class ClassEnrollmentRepository {
  final SupabaseClient supabase;

  ClassEnrollmentRepository(this.supabase);

  /// Enroll a student in a class
  Future<bool> enrollStudent(String studentId, String classId) async {
    final response = await supabase.from('class_enrollments').insert({
      'student_id': studentId,
      'class_id': classId,
      'enrolled_at': DateTime.now().toUtc().toIso8601String(),
    });

    return response.isNotEmpty;
  }

  /// Get all classes a student is enrolled in
  Future<List<Map<String, dynamic>>> getStudentClasses(String studentId) async {
    final response = await supabase
        .from('class_enrollments')
        .select('*, classes(name, teacher_id)')
        .eq('student_id', studentId);

    return response;
  }
}
