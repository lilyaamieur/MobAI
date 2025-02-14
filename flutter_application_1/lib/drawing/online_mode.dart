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
  Timer? _gameTimer;
  Timer? _pollingTimer;
  Timer? _checkSubmissionTimer;
  int timeLeft = 60; // 1-minute timer
  bool hasSubmitted = false;
  String? player1Drawing;
  String? player2Drawing;
  String? player1Id;
  String? player2Id;

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
        .limit(1)
        .maybeSingle();

    if (response != null) {
      gameId = response["id"];
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

    pollForPlayer2(); // Start polling until the second player joins
  }

  void pollForPlayer2() {
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var response = await supabase.from("games").select().eq("id", gameId).single();

      if (!mounted) return;

      setState(() {
        player1Id = response["player1_id"];
        player2Id = response["player2_id"];
      });

      if (player1Id != null && player2Id != null) {
        timer.cancel(); // Stop polling when the second player joins
        listenToGameUpdates();
        startTimer();
      }
    });
  }

  void listenToGameUpdates() {
    supabase
        .from("games")
        .stream(primaryKey: ["id"])
        .eq("id", gameId)
        .listen((data) {
      if (data.isNotEmpty) {
        var gameData = data[0];

        if (!mounted) return;

        setState(() {
          prompt = gameData["prompt"];
          player1Drawing = gameData["player1_drawing"];
          player2Drawing = gameData["player2_drawing"];
        });

        // Stop the submission check once both drawings are submitted
        if (player1Drawing != null && player2Drawing != null) {
          _checkSubmissionTimer?.cancel();
        }
      }
    });

    startSubmissionChecker(); // Start checking if both drawings are submitted
  }

  void startTimer() {
    setState(() {
      isGameStarted = true;
    });

    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _gameTimer?.cancel();
        if (!hasSubmitted) {
          submitDrawing();
        }
      }
    });
  }

  void startSubmissionChecker() {
    _checkSubmissionTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var response = await supabase.from("games").select().eq("id", gameId).single();

      if (!mounted) return;

      setState(() {
        player1Drawing = response["player1_drawing"];
        player2Drawing = response["player2_drawing"];
      });

      if (player1Drawing != null && player2Drawing != null) {
        timer.cancel(); // Stop checking once both drawings are submitted
      }
    });
  }

  Future<void> submitDrawing() async {
    if (hasSubmitted) return;
    setState(() => hasSubmitted = true);

    ByteData? drawingData = await _controller.getImageData();
    Uint8List uint8List = drawingData!.buffer.asUint8List();
    String base64Image = base64Encode(uint8List);

    if (userId == player1Id) {
      await supabase.from("games").update({
        "player1_drawing": base64Image,
      }).eq("id", gameId);
    } else {
      await supabase.from("games").update({
        "player2_drawing": base64Image,
      }).eq("id", gameId);
    }

    _gameTimer?.cancel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pollingTimer?.cancel();
    _checkSubmissionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Online Mode: $prompt")),
      body: Column(
        children: [
          if (player2Id == null) ...[
            Text("Waiting for another player..."),
          ] else ...[
            Text("Time Left: $timeLeft seconds",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: DrawingBoard(
                controller: _controller,
                background: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,  
                ),
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
