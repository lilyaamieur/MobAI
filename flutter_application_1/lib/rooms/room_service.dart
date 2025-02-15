import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';

class RoomService {
  final SupabaseClient supabase = Supabase.instance.client;
  List<String> prompts = ["Sun", "House", "Tree", "Car", "Cat"];

  Future<String> createRoom(String userId) async {
    final randomPrompt = prompts[Random().nextInt(prompts.length)];
    final response = await supabase.from('rooms').insert({
      'current_drawer': userId,
      'prompt': randomPrompt
    }).select().single();
    return response['id'];
  }

  Future<void> joinRoom(String roomId, String userId) async {
    await supabase.from('room_players').insert({'room_id': roomId, 'user_id': userId, 'score': 0});
  }

  Stream<Map<String, dynamic>> listenForRoomUpdates(String roomId) {
    return supabase.from('rooms').stream(primaryKey: ['id']).eq('id', roomId).map((event) => event.first);
  }
}
