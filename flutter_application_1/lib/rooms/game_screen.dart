import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'room_service.dart';
import 'chat_service.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  const GameScreen({super.key, required this.roomId, required this.userId});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DrawingController _controller = DrawingController();
  final RoomService _roomService = RoomService();
  final ChatService _chatService = ChatService();
  TextEditingController _guessController = TextEditingController();
  bool isMyTurn = false;
  String prompt = "";

  @override
  void initState() {
    super.initState();
    _listenForRoomUpdates();
  }

  void _listenForRoomUpdates() {
    _roomService.listenForRoomUpdates(widget.roomId).listen((data) {
      if (mounted) {
        setState(() {
          isMyTurn = data['current_drawer'] == widget.userId;
          prompt = data['prompt'];
        });
      }
    });
  }

  Future<void> _submitDrawing() async {
    ByteData? drawingData = await _controller.getImageData();
    if (drawingData != null) {
      await supabase.from("rooms").update({"drawing": drawingData.buffer.asUint8List()}).eq("id", widget.roomId);
    }
  }

  Future<void> _submitGuess() async {
    final guess = _guessController.text.trim();
    if (guess.isNotEmpty) {
      await _chatService.submitGuess(widget.roomId, widget.userId, guess);
      _guessController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Room: ${widget.roomId}")),
      body: Column(
        children: [
          if (isMyTurn) Text("Draw: $prompt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: DrawingBoard(
              controller: _controller,
              background: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
              ),
              showDefaultActions: true,
              showDefaultTools: isMyTurn,
            ),
          ),
          if (isMyTurn)
            ElevatedButton(
              onPressed: _submitDrawing,
              child: Text("Submit Drawing"),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    decoration: InputDecoration(hintText: "Enter your guess..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _submitGuess,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
