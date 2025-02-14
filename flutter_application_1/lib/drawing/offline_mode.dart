import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:image/image.dart' as img;
import 'package:tflite/tflite.dart';

class OfflineMode extends StatefulWidget {
  @override
  _OfflineModeState createState() => _OfflineModeState();
}

class _OfflineModeState extends State<OfflineMode> {
  final DrawingController _controller = DrawingController();
  String _prompt = "Draw a Cat"; // Example prompt
  String _prediction = "Waiting...";
  int _score = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _processDrawing() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    ByteData? imageData = await _controller.getImageData();
    if (imageData == null) return;

    var prediction = await Tflite.runModelOnBinary(
      binary: imageData.buffer.asUint8List(),
    );

    if (prediction!.isNotEmpty) {
      setState(() {
        _prediction = prediction.first["label"];
        _score = (prediction.first["confidence"] * 100).toInt();
      });
    }

    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offline Mode: $_prompt")),
      body: Column(
        children: [
          Expanded(
            child: DrawingBoard(
              controller: _controller,
              background: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
              ),
              showDefaultActions: true,
              showDefaultTools: true,
            ),
          ),
          Text("Prediction: $_prediction", style: TextStyle(fontSize: 18)),
          Text("Score: $_score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: _processDrawing,
            child: Text("Submit Drawing"),
          ),
        ],
      ),
    );
  }
}
