import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'dart:async'; // Import Timer

class OfflineModeScreen extends StatefulWidget {
  @override
  _OfflineModeScreenState createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  final DrawingController _drawingController = DrawingController();
  final int _timerDuration = 60; // 1 minute
  int _remainingTime = 60;
  bool _isTimerRunning = false;
  String _aiGuess = '';
  int _score = 0;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingTime = _timerDuration;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel(); // Stop the timer
          _simulateAIGuess();
        }
      });
    });
  }

  void _simulateAIGuess() {
    setState(() {
      _isTimerRunning = false;
      _aiGuess = 'Computer'; // Dummy AI guess
      _score = _calculateScore();
    });
  }

  int _calculateScore() {
    // Dummy scoring logic: 100 points if guessed correctly
    return _aiGuess == 'Computer' ? 100 : 0;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Mode'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              _drawingController.undo();
            },
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: () {
              _drawingController.redo();
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _drawingController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            'Time Remaining: $_remainingTime seconds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                color: Colors.white,
              ),
              showDefaultActions: true,
              showDefaultTools: true,
            ),
          ),
          if (_aiGuess.isNotEmpty)
            Text(
              'AI Guess: $_aiGuess\nScore: $_score',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ElevatedButton(
            onPressed: _isTimerRunning ? null : _startTimer,
            child: Text(_isTimerRunning ? 'Drawing...' : 'Start Drawing'),
          ),
        ],
      ),
    );
  }
}