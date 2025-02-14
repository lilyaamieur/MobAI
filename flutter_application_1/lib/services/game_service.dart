import 'package:supabase_flutter/supabase_flutter.dart';

class GameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createSession(String userId) async {
    final response = await _supabase.from('sessions').insert({
      'session_type': 'online',
      'created_by': userId,
    });

    return response.data[0]['id'].toString();
  }

  Future<Map<String, dynamic>> submitDrawing(String sessionId, String userId, String drawingData) async {
    await _supabase.from('guesses').insert({
      'session_id': sessionId,
      'user_id': userId,
      'guess_text': 'Computer', // Dummy guess
      'is_correct': true,
      'confidence': 1.0, // Dummy confidence score
    });

    return {
      'ai_guess': 'Computer', // Dummy AI guess
      'score': 100, // Dummy score
    };
  }
}