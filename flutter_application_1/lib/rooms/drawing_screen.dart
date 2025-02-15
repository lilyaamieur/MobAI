import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class DrawingScreen extends StatefulWidget {
  final String roomId;
  DrawingScreen({required this.roomId});

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DrawingController _controller = DrawingController();
  bool isMyTurn = false;
  int timeLeft = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkTurn();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _timer?.cancel();
        // Move to next player's turn
      }
    });
  }

  Future<void> _checkTurn() async {
    var response = await supabase
        .from("rooms")
        .select("current_drawer")
        .eq("id", widget.roomId)
        .single();
    setState(() {
      isMyTurn = response["current_drawer"] == supabase.auth.currentUser!.id;
    });
  }

  Future<void> _submitDrawing() async {
    ByteData? drawingData = await _controller.getImageData();
    String base64Image = base64Encode(drawingData!.buffer.asUint8List());

    await supabase.from("rooms").update({"drawing": base64Image}).eq("id", widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drawing Room: ${widget.roomId}")),
      body: Column(
        children: [
          Text("Time Left: $timeLeft seconds"),
          Expanded(
            child: DrawingBoard(
              controller: _controller,
              background: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width, 
              ),
            ),
          ),
          if (isMyTurn)
            ElevatedButton(
              onPressed: _submitDrawing,
              child: Text("Submit Drawing"),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(roomId: widget.roomId)),
              );
            },
            child: Text("Open Chat"),
          ),
        ],
      ),
    );
  }
}
