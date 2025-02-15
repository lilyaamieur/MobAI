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
  late String prompt = "";
  bool isGameStarted = false;
  Timer? _gameTimer;
  Timer? _pollingTimer;
  Timer? _checkSubmissionTimer;
  int timeLeft = 60;
  bool hasSubmitted = false;
  String? player1Drawing;
  String? player2Drawing;
  String? player1Id;
  String? player2Id;
  String? guessedCategory;
  double guessedAccuracy = 0.0;
  double? player1Accuracy = 0.0;
  double? player2Accuracy = 0.0;
  int? guessTime;
  int? player1GuessTime;
  int? player2GuessTime;
  bool isWinner = false;
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    fetchPromptAndMatch();
    findOrCreateGame();
    _controller.addListener(_onStroke);
  }

  Future<void> fetchPromptAndMatch() async {
    final response = await http
        .get(Uri.parse("http://127.0.0.1:5005/get_word?user_id=$userId"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        prompt = data['label'];
      });
    }
  }

  Future<void> findOrCreateGame() async {
    var response = await supabase
        .from("games")
        .select()
        .eq("status", "waiting")
        .limit(1)
        .maybeSingle();

    //int level_1 = supabase.auth.currentUser!.userMetadata!["level"];

    if (response != null) {
      gameId = response["id"];
      final response_1 = await supabase.from("games").select("player1_id").eq("id", gameId).single();
      //final response_2 = await supabase.from("auth.users").select("level").eq("id", response_1["player1_id"]).single();
      final user = supabase.auth.currentUser;
      final double level_1 = (user?.userMetadata?['level'] as num?)?.toDouble() ?? 1.0;
      final response_2 = await supabase
      .from('auth.users')
      .select('metadata')
      .eq('id', response_1['player1_id'])
      .single();

      final double level_2 = (response_2['metadata']['level'] as num?)?.toDouble() ?? 1.0;

      if (level_1 <= level_2 + 0.3 && level_1 >= level_2 - 0.3) {
      final response_3 = await supabase
          .from("games")
          .select("prompt")
          .eq("id", gameId)
          .single();
          prompt = response_3["prompt"];
          print("prompt: $prompt");
          await supabase.from("games").update(
          {"player2_id": userId, "status": "in_progress"}).eq("id", gameId);
      }
      else {
        gameId = const Uuid().v4();
        await supabase.from("games").insert({
          "id": gameId,
          "prompt": prompt,
          "player1_id": userId,
          "status": "waiting"
        });

       }
    } else {
      //fetchPromptAndMatch();
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
      var response =
          await supabase.from("games").select().eq("id", gameId).single();

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
            print(gameData);
            if (!mounted) return;

            setState(() {
              prompt = gameData["prompt"];
              player1Drawing = gameData["player1_drawing"];
              player2Drawing = gameData["player2_drawing"];
              player1GuessTime = gameData["player1_guessed_time"];
              player2GuessTime = gameData["player2_guessed_time"];
              player1Accuracy = gameData["player1_accuracy"];
              player2Accuracy = gameData["player2_accuracy"];
            });

            if (player1Drawing != null && player2Drawing != null) {
              determineWinner();
            }
          }
        });

    startSubmissionChecker();
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

  void startSubmissionChecker() {
    _checkSubmissionTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var response =
          await supabase.from("games").select().eq("id", gameId).single();

      if (!mounted) return;

      setState(() {
        player1Drawing = response["player1_drawing"];
        player2Drawing = response["player2_drawing"];
      });

      if (player1Drawing != null && player2Drawing != null) {
        timer.cancel();
        determineWinner();
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

        if (guessedWord.toLowerCase() == prompt.toLowerCase() &&
            guessedAccuracy > 0.75) {
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
      player1Accuracy = guessedAccuracy;
      player1GuessTime = guessTime;

      if (guessedCategory!.toLowerCase() == prompt.toLowerCase()) {
        await supabase.from("games").update({
          "player1_drawing": base64Image,
          "player1_guessed_time": guessTime,
          "player1_accuracy": guessedAccuracy,
          "answer_1": "success",
        }).eq("id", gameId);
      } else {
        await supabase.from("games").update({
          "player1_drawing": base64Image,
          "player1_guessed_time": guessTime,
          "player1_accuracy": 0,
          "answer_1": "fail"
        }).eq("id", gameId);
      }

      final res = await supabase
          .from("games")
          .select("player2_accuracy, player2_guessed_time")
          .eq("id", gameId);

      player2Accuracy = res[0]["player2_accuracy"];
      player2GuessTime = res[0]["player2_guessed_time"];
    } else {
      player2Accuracy = guessedAccuracy;
      player2GuessTime = guessTime;

      if (guessedCategory!.toLowerCase() == prompt.toLowerCase()) {
        await supabase.from("games").update({
          "player2_drawing": base64Image,
          "player2_guessed_time": guessTime,
          "player2_accuracy": guessedAccuracy,
          "answer_2": "success",
        }).eq("id", gameId);
      } else {
        await supabase.from("games").update({
          "player2_drawing": base64Image,
          "player2_guessed_time": guessTime,
          "player2_accuracy": 0,
          "answer_2": "fail"
        }).eq("id", gameId);
      }

      final res = await supabase
          .from("games")
          .select("player1_accuracy, player1_guessed_time")
          .eq("id", gameId);

      //player1Accuracy = (res[0]["player1_accuracy"]).toDouble();
      //player1GuessTime = res[0]["player1_guessed_time"].toDouble();
    }

    try {
      await updateUserLevel(
          guessedCategory!.toLowerCase() == prompt.toLowerCase(),
          guessTime!,
          guessedAccuracy);
    } catch (e) {
      print("Error updating user level : $e");
    }

    // final response = await supabase.auth.currentUser!.userMetadata!;
    // int newLevel = response["level"];
    // print("new level: $newLevel");

    stopwatch.stop();
    _gameTimer?.cancel();
  }

  void determineWinner() {
    if (player1GuessTime != null && player2GuessTime != null) {
      setState(() {
        if (userId == player1Id) {
          isWinner = player1GuessTime! < player2GuessTime!;
        } else {
          isWinner = player2GuessTime! < player1GuessTime!;
        }
        print(player1GuessTime.toString() + player2GuessTime.toString());
        print("is winner : " + isWinner.toString());
      });
      isWinner = false;
    } else {
      isWinner = true;
    }

    print(player1GuessTime);
    print(player2GuessTime);
  }

  Future<void> updateUserLevel(
      bool success, int timeTaken, double accuracy) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:5005/update_proficiency"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "success": success,
        "time_taken": timeTaken,
        "confidence": accuracy
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double newLevel = data['new_proficiency'];
      await supabase.auth.updateUser(UserAttributes(
      data: {"level": newLevel},
    ));

      print(response);
    } else {
      print("Error updating user level");
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _pollingTimer?.cancel();
    _checkSubmissionTimer?.cancel();
    _controller.removeListener(_onStroke);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Online Mode: Draw $prompt")),
      body: Column(
        children: [
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
          Text("AI Prediction: ${guessedCategory ?? "Waiting..."}",
              style: TextStyle(fontSize: 18)),
          Text("Accuracy: ${(guessedAccuracy * 100).toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 18)),
          ElevatedButton(
            onPressed: submitDrawing,
            child: Text(hasSubmitted ? "Submitted!" : "Submit Drawing"),
          ),
          if (player1Drawing != null && player2Drawing != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Player 1"),
                    Image.memory(base64Decode(player1Drawing!),
                        width: 100, height: 100),
                    //Text("Accuracy: ${(player1Accuracy! * 100).toStringAsFixed(2)}%",
                    //style: TextStyle(fontSize: 18)),
                  ],
                ),
                Column(
                  children: [
                    Text("Player 2"),
                    Image.memory(base64Decode(player2Drawing!),
                        width: 100, height: 100),
                    // Text("Accuracy: ${(player2Accuracy! * 100).toStringAsFixed(2)}%",
                    //style: TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
            Text(isWinner ? "You Won!" : "You Lost!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Time to Guess: ${guessTime}s"),
          ],
        ],
      ),
    );
  }
}
