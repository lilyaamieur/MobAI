import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createTables() async {
    await supabase.rpc('create_rooms_table');
    await supabase.rpc('create_room_players_table');
    await supabase.rpc('create_messages_table');
  }

  Future<void> resetGame(String roomId) async {
    await supabase.from('rooms').update({'status': 'waiting', 'round_timer': 90}).eq('id', roomId);
    await supabase.from('room_players').update({'score': 0, 'has_guessed': false}).eq('room_id', roomId);
    await supabase.from('messages').delete().eq('room_id', roomId);
  }
}
