import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:http/http.dart' as http;

class OfflineMode extends StatefulWidget {
  @override
  _OfflineModeState createState() => _OfflineModeState();
}

class _OfflineModeState extends State<OfflineMode> {
  final DrawingController _controller = DrawingController();
  int timeLeft = 60;
  Timer? _timer;
  bool hasSubmitted = false;
  String? drawingImage;
  String? predictedCategory;
  double predictionProbability = 0.0;
  String? finalScore;
  String prompt = "apple"; // Example prompt

  @override
  void initState() {
    super.initState();
    startTimer();
    _controller.addListener(_onStroke); // Detect strokes
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _timer?.cancel();
        if (!hasSubmitted) {
          submitDrawing(); // Auto-submit when time is up
        }
      }
    });
  }

  Future<void> _onStroke() async {
    if (hasSubmitted) return; // Don't process if already submitted

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
          predictedCategory = guessedWord;
          predictionProbability = accuracy;
        });

        // Auto-submit if the AI guesses correctly
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

    setState(() {
      drawingImage = base64Image;

      // Use the last AI guess if time expired or user submitted manually
      String finalGuess = predictedCategory ?? "Unknown";
      double finalAccuracy = predictionProbability * 100;
      finalScore = "${finalAccuracy.toInt()} - $finalGuess";
    });

    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onStroke);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offline Mode: Draw $prompt")),
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
          Text("AI Prediction: ${predictedCategory ?? "Waiting..."}",
              style: TextStyle(fontSize: 18)),
          Text("Accuracy: ${(predictionProbability * 100).toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 18)),
          ElevatedButton(
            onPressed: submitDrawing,
            child: Text(hasSubmitted ? "Submitted!" : "Submit Drawing"),
          ),
          if (hasSubmitted) ...[
            SizedBox(height: 20),
            Text("Game Over!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (drawingImage != null)
              Image.memory(base64Decode(drawingImage!), width: 100, height: 100),
            Text("Final Score: $finalScore", style: TextStyle(fontSize: 20)),
          ],
        ],
      ),
    );
  }
}
