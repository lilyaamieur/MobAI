import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> _getUserId() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      // Sign in anonymously
      final response = await _supabase.auth.signInAnonymously();
      return response.user!.id;
    }

    return user.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final userId = snapshot.data!;
          return HomeScreen(userId: userId);
        }
      },
    );
  }
}