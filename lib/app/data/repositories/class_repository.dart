import 'package:supabase_flutter/supabase_flutter.dart';

class ClassRepository {
  final SupabaseClient supabase;

  ClassRepository(this.supabase);

  /// Create a new class
  Future<bool> createClass({
    required String name,
    required String teacherId,
  }) async {
    final response = await supabase.from('classes').insert({
      'name': name,
      'teacher_id': teacherId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    return response.isNotEmpty;
  }

  /// Get all classes
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final response = await supabase
        .from('classes')
        .select('*')
        .order('created_at', ascending: false);

    return response;
  }

  /// Get a specific class by ID
  Future<Map<String, dynamic>?> getClassById(String classId) async {
    final response =
        await supabase
            .from('classes')
            .select('*')
            .eq('id', classId)
            .maybeSingle();

    return response;
  }

  /// Get all classes assigned to a specific teacher
  Future<List<Map<String, dynamic>>> getClassesByTeacher(
    String teacherId,
  ) async {
    final response = await supabase
        .from('classes')
        .select('*')
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);

    return response;
  }
}
