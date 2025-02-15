import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'room_service.dart';

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
  TextEditingController _guessController = TextEditingController();
  bool isMyTurn = false;
  int timeLeft = 90;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenForTurnUpdates();
    _startTurnTimer();
  }

  void _startTurnTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _timer?.cancel();
        _roomService.assignNextDrawer(widget.roomId);
      }
    });
  }

  void _listenForTurnUpdates() {
    supabase.from('rooms').stream(primaryKey: ['id']).eq('id', widget.roomId).listen((data) {
      if (data.isNotEmpty) {
        setState(() {
          isMyTurn = data[0]['current_drawer'] == widget.userId;
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
      await _roomService.submitGuess(widget.roomId, widget.userId, guess);
      _guessController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Room: ${widget.roomId}")),
      body: Column(
        children: [
          Text("Time Left: $timeLeft seconds", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: DrawingBoard(
              controller: _controller,
              background: Container(color: Colors.white),
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
