import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> listenForMessages(String roomId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id']).eq('room_id', roomId);
  }

  Future<void> submitGuess(String roomId, String userId, String guess) async {
    final roomData = await supabase
        .from('rooms')
        .select('current_drawer, prompt')
        .eq('id', roomId)
        .single();
    final correctAnswer = roomData['prompt'].toLowerCase();
    final isCorrect = guess.toLowerCase() == correctAnswer;

    if (isCorrect) {
      final correctGuesses = await supabase
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .eq('is_correct', true);
      if (correctGuesses.length < 1) {
        final response = supabase
            .from('room_players')
            .select('score')
            .eq('user_id', userId)
            .single();

        final currentScore = response;
        await supabase
            .from('room_players')
            .update({'score': 10}).eq('user_id', userId);
        await supabase.from('messages').insert({
          'room_id': roomId,
          'user_id': userId,
          'message': '[Correct Guess]',
          'is_correct': true
        });
      }
    } else {
      await supabase.from('messages').insert({
        'room_id': roomId,
        'user_id': userId,
        'message': guess,
        'is_correct': false
      });
    }
  }
}
