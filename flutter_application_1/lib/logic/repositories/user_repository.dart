// ignore_for_file: unnecessary_null_comparison

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/data/models/user.dart';

class UserRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  // ✅ Fetch User by ID
  Future<UserModel?> getUserById(int userId) async {
    final response =
        await supabase.from('User').select().eq('id', userId).single();

    if (response != null) {
      return UserModel.fromJson(response);
    }
    return null;
  }

  // ✅ Update User Info
  Future<void> updateUser(UserModel user) async {
    await supabase.from('User').update(user.toJson()).eq('id', user.id);
  }

  // ✅ Create a New User
  Future<void> createUser(UserModel user) async {
    await supabase.from('User').insert(user.toJson());
  }

  // ✅ Delete a User
  Future<void> deleteUser(int userId) async {
    await supabase.from('User').delete().eq('id', userId);
  }
}
