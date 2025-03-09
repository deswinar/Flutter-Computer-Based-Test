import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/profile/models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> fetchUserProfile(String userId) async {
    final response =
        await _supabase.from('users').select().eq('id', userId).single();

    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  Future<bool> updateUserName(String userId, String newName) async {
    final response =
        await _supabase
            .from('users')
            .update({'name': newName})
            .eq('id', userId)
            .select();

    return response.isNotEmpty;
  }
}
