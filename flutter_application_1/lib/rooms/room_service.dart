import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RoomService {
  final SupabaseClient supabase = Supabase.instance.client;
  Timer? _roomTimer;
  Timer? _turnTimer;

  Future<String> createRoom() async {
    final response = await supabase.from('rooms').insert({}).select().single();
    _startRoomTimer(response['id']);
    return response['id'];
  }

  void _startRoomTimer(String roomId) {
    _roomTimer = Timer(Duration(seconds: 90), () async {
      final players = await supabase.from('room_players').select().eq('room_id', roomId);
      if (players.length >= 2) {
        await supabase.from('rooms').update({'status': 'in_progress'}).eq('id', roomId);
        assignNextDrawer(roomId);
      }
    });
  }

  Future<void> joinRoom(String roomId, String userId) async {
    await supabase.from('room_players').insert({'room_id': roomId, 'user_id': userId, 'score': 0});
    final players = await supabase.from('room_players').select().eq('room_id', roomId);
    if (players.length == 5) {
      _roomTimer?.cancel();
      await supabase.from('rooms').update({'status': 'in_progress'}).eq('id', roomId);
      assignNextDrawer(roomId);
    }
  }

  void assignNextDrawer(String roomId) async {
    final players = await supabase.from('room_players').select().eq('room_id', roomId);
    if (players.isNotEmpty) {
      final nextDrawer = players[0]['user_id'];
      await supabase.from('rooms').update({'current_drawer': nextDrawer}).eq('id', roomId);
      _startTurnTimer(roomId);
    }
  }

  void _startTurnTimer(String roomId) {
    _turnTimer?.cancel();
    _turnTimer = Timer(Duration(seconds: 90), () async {
      assignNextDrawer(roomId);
    });
  }

  Future<void> submitGuess(String roomId, String userId, String guess) async {
    final roomData = await supabase.from('rooms').select('current_drawer, prompt').eq('id', roomId).single();
    if (roomData['prompt'].toLowerCase() == guess.toLowerCase()) {
      final res = await supabase.from('room_players').select('score').eq('user_id', userId).single();

      await supabase.from('room_players').update({
        'score':  res['score'] + 10
      }).eq('user_id', userId);
      _turnTimer?.cancel();
      assignNextDrawer(roomId);
    } else {
      await supabase.from('messages').insert({'room_id': roomId, 'user_id': userId, 'message': guess});
    }
  }
}
