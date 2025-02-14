import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class OfflineMode extends StatefulWidget {
  @override
  _OfflineModeState createState() => _OfflineModeState();
}

class _OfflineModeState extends State<OfflineMode> {
  final DrawingController _controller = DrawingController();
  int timeLeft = 60; // Timer for 1 minute
  Timer? _timer;
  bool hasSubmitted = false;
  String? drawingImage;
  int aiScore = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
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
          submitDrawing();
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

    setState(() {
      drawingImage = base64Image;
      aiScore = (50 + (100 * (timeLeft / 60))).toInt(); // Dummy AI scoring logic
    });

    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Custom white back icon
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        centerTitle: true,
        title: Text("Offline Mode: Draw Something!", 
        style: TextStyle(color: Colors.white),
          
        ),
        backgroundColor: main_black,),
      body: Column(
        children: [
          SizedBox(height: 50,),

          Text("Time Left: $timeLeft seconds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),

          SizedBox(height: 50,),

          Expanded(
            child: DrawingBoard(
              controller: _controller,
              background: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
              ),
              showDefaultActions: false,
              showDefaultTools: true,
            ),
          ),

          SizedBox(height: 50,),
          ElevatedButton(
            onPressed: submitDrawing,
              style: ButtonStyle(
                backgroundColor:  MaterialStateProperty.all<Color>(Colors.green),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), 
              ),            
              child: Text(hasSubmitted ? "Submitted!" : "Submit Drawing"),
          ),
          if (hasSubmitted) ...[
            SizedBox(height: 20),
            Text("Game Over!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            if (drawingImage != null)
              Image.memory(base64Decode(drawingImage!), width: 100, height: 100),
            Text("AI Score: $aiScore", style: TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ],
      ),
    );
  }
}
