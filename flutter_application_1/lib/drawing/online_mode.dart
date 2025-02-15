import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
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
  int timeLeft = 60;
  bool hasSubmitted = false;

  // Player Data
  String? player1Id;
  String? player2Id;
  String? player1Drawing;
  String? player2Drawing;
  String? player1GuessWord;
  String? player2GuessWord;
  double player1Accuracy = 0.0;
  double player2Accuracy = 0.0;
  int? player1GuessTime;
  int? player2GuessTime;
  int? guessTime;
  String? guessedCategory;
  double guessedAccuracy = 0.0;
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    findOrCreateGame();
    _controller.addListener(_onStroke);
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

    pollForPlayer2();
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
        timer.cancel();
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
          player1GuessWord = gameData["player1_guess_word"];
          player2GuessWord = gameData["player2_guess_word"];
          player1Accuracy = gameData["player1_accuracy"] ?? 0.0;
          player2Accuracy = gameData["player2_accuracy"] ?? 0.0;
          player1GuessTime = gameData["player1_guess_time"];
          player2GuessTime = gameData["player2_guess_time"];
        });

        if (player1Drawing != null && player2Drawing != null) {
          setState(() {
            isGameStarted = false;
          });
        }
      }
    });
  }

  void startTimer() {
    setState(() {
      isGameStarted = true;
    });

    stopwatch.start();

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

  Future<void> _onStroke() async {
    if (hasSubmitted) return;

    List<Map<String, dynamic>> jsonData = _controller.getJsonList();
    String jsonPayload = JsonEncoder.withIndent('  ').convert(jsonData);

    var response = await http.post(
      Uri.parse("http://127.0.0.1:5001/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonPayload,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List predictions = data["predictions"];

      if (predictions.isNotEmpty) {
        String guessedWord = predictions[0]["category"];
        double accuracy = predictions[0]["probability"];

        setState(() {
          guessedCategory = guessedWord;
          guessedAccuracy = accuracy;
          guessTime = stopwatch.elapsedMilliseconds ~/ 1000;
        });

        if (guessedWord.toLowerCase() == prompt.toLowerCase()) {
          submitDrawing();
        }
      }
    }
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
        "player1_guess_word": guessedCategory,
        "player1_accuracy": guessedAccuracy * 100,
        "player1_guess_time": guessTime,
      }).eq("id", gameId);
    } else {
      await supabase.from("games").update({
        "player2_drawing": base64Image,
        "player2_guess_word": guessedCategory,
        "player2_accuracy": guessedAccuracy * 100,
        "player2_guess_time": guessTime,
      }).eq("id", gameId);
    }

    stopwatch.stop();
    _gameTimer?.cancel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pollingTimer?.cancel();
    _controller.removeListener(_onStroke);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Online Mode: Draw $prompt")),
      body: Column(
        children: [
          if (!hasSubmitted)
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
          if (player1Drawing != null && player2Drawing != null) ...[
            Text("Game Over!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Player 1: $player1GuessWord"),
                    Text("Accuracy: ${player1Accuracy.toStringAsFixed(2)}%"),
                    Text("Time: ${player1GuessTime}s"),
                    Image.memory(base64Decode(player1Drawing!), width: 100, height: 100),
                  ],
                ),
                Column(
                  children: [
                    Text("Player 2: $player2GuessWord"),
                    Text("Accuracy: ${player2Accuracy.toStringAsFixed(2)}%"),
                    Text("Time: ${player2GuessTime}s"),
                    Image.memory(base64Decode(player2Drawing!), width: 100, height: 100),
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
