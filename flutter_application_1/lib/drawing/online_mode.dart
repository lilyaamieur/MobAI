import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OnlineMode extends StatefulWidget {
  @override
  _OnlineModeState createState() => _OnlineModeState();
}

class _OnlineModeState extends State<OnlineMode> {
  final DrawingController _controller = DrawingController();
  final SupabaseClient supabase = Supabase.instance.client;
  String gameId = "";
  String userId = "";
  String prompt = "Draw a House";
  bool isGameStarted = false;
  Timer? _timer;
  int timeLeft = 60; // Timer for 1 minute
  bool hasSubmitted = false;
  String? player1Drawing;
  String? player2Drawing;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    findOrCreateGame();
  }

  Future<void> findOrCreateGame() async {
    var response = await supabase
        .from("games")
        .select()
        .eq("status", "waiting")
        .limit(1);

    if (response.isNotEmpty) {
      gameId = response[0]["id"];
      await supabase.from("games").update({
        "player2_id": userId,
        "status": "in_progress"
      }).eq("id", gameId);
    } else {
      gameId = const Uuid().v4();
      await supabase.from("games").insert({
        "id": gameId,
        "prompt": prompt,
        "player1_id": userId,
        "status": "waiting"
      });
    }

    listenToGameUpdates();
  }

  void listenToGameUpdates() {
    supabase
        .from("games")
        .stream(primaryKey: ["id"])
        .eq("id", gameId)
        .listen((data) {
      if (data.isNotEmpty) {
        setState(() {
          prompt = data[0]["prompt"];
        });

        // Start timer when both players are in
        if (data[0]["player2_id"] != null && !isGameStarted) {
          startTimer();
        }

        // Get drawings once both are submitted
        if (data[0]["player1_drawing"] != null &&
            data[0]["player2_drawing"] != null) {
          setState(() {
            player1Drawing = data[0]["player1_drawing"];
            player2Drawing = data[0]["player2_drawing"];
          });
        }
      }
    });
  }

  void startTimer() {
    setState(() {
      isGameStarted = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _timer?.cancel();
        if (!hasSubmitted) {
          submitDrawing(); // Auto-submit when time runs out
        }
      }
    });
  }

  Future<void> submitDrawing() async {
    if (hasSubmitted) return;
    setState(() => hasSubmitted = true);

    ByteData? drawingData = await _controller.getImageData();
    Uint8List uint8List = drawingData!.buffer.asUint8List();
    String base64Image = base64Encode(uint8List);

    var player1Id =
        await supabase.from("games").select("player1_id").eq("id", gameId);

    if (userId == player1Id[0]["player1_id"]) {
      await supabase.from("games").update({
        "player1_drawing": base64Image,
      }).eq("id", gameId);
    } else {
      await supabase.from("games").update({
        "player2_drawing": base64Image,
      }).eq("id", gameId);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Online Mode: $prompt")),
      body: Column(
        children: [
          if (!isGameStarted) ...[
            Text("Waiting for another player..."),
          ] else ...[
            Text("Time Left: $timeLeft seconds",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: DrawingBoard(
                controller: _controller,
                background: Container(color: Colors.white),
                showDefaultActions: true,
                showDefaultTools: true,
              ),
            ),
            ElevatedButton(
              onPressed: submitDrawing,
              child: Text(hasSubmitted ? "Submitted!" : "Submit Drawing"),
            ),
          ],
          if (player1Drawing != null && player2Drawing != null) ...[
            SizedBox(height: 20),
            Text("Game Over!"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Player 1"),
                    Image.memory(base64Decode(player1Drawing!),
                        width: 100, height: 100),
                    Text("Score: 75"),
                  ],
                ),
                Column(
                  children: [
                    Text("Player 2"),
                    Image.memory(base64Decode(player2Drawing!),
                        width: 100, height: 100),
                    Text("Score: 80"),
                  ],
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
