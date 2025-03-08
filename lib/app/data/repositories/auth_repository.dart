import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // Sign Up User
  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role, // 'teacher' or 'student'
      },
    );

    // Store role in the users table
    if (response.user != null) {
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'name': name,
        'role': role,
        'email': email,
      });
    }

    return response;
  }

  // Login User & Fetch Role
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final data = await getUserData(response.user!.id);
      return {'user': response.user, 'role': data?['role']};
    }

    return null;
  }

  // Get User Data (Name, Role, etc.)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final data =
          await _supabase
              .from('users')
              .select('name, role')
              .eq('id', userId)
              .single();

      return data;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
