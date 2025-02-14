import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/game_service.dart';
import '../widgets/drawing_board.dart';
import '../widgets/timer_widget.dart';

class OnlineModeScreen extends StatefulWidget {
  final String userId;

  OnlineModeScreen({required this.userId});

  @override
  _OnlineModeScreenState createState() => _OnlineModeScreenState();
}

class _OnlineModeScreenState extends State<OnlineModeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GameService _gameService = GameService();
  final int _timerDuration = 60; // 1 minute
  int _remainingTime = 60;
  bool _isTimerRunning = false;
  String _aiGuessUser1 = '';
  String _aiGuessUser2 = '';
  int _scoreUser1 = 0;
  int _scoreUser2 = 0;
  Timer? _timer;
  String _sessionId = '';
  String _prompt = ''; // Store the chosen prompt

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
          _submitDrawing(); // Submit the drawing when time runs out
        }
      });
    });
  }

  Future<void> _createSession() async {
    final sessionId = await _gameService.createSession(widget.userId);
    final prompt = {
      'text': 'A drawing prompt',
      'category': 'A category',
      'difficulty_level': '1',
    };
    setState(() {
      _sessionId = sessionId;
      _prompt = prompt['text']!; // Set the chosen prompt
    });
  }

  Future<void> _submitDrawing() async {
    final drawingData = 'base64-encoded-drawing'; // Replace with actual drawing data
    final result = await _gameService.submitDrawing(_sessionId, widget.userId, drawingData);

    setState(() {
      _aiGuessUser1 = result['ai_guess'];
      _scoreUser1 = result['score'];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Mode'),
      ),
      body: Column(
        children: [
          Text(
            'Prompt: $_prompt', // Display the chosen prompt
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TimerWidget(remainingTime: _remainingTime),
          Expanded(
            child: Drawing_Board(),
          ),
          if (_aiGuessUser1.isNotEmpty && _aiGuessUser2.isNotEmpty)
            Column(
              children: [
                Text('Your Guess: $_aiGuessUser1\nScore: $_scoreUser1'),
                Text('Opponent Guess: $_aiGuessUser2\nScore: $_scoreUser2'),
              ],
            ),
          ElevatedButton(
            onPressed: _isTimerRunning ? null : () {
              _createSession().then((_) => _startTimer());
            },
            child: Text(_isTimerRunning ? 'Drawing...' : 'Start Drawing'),
          ),
        ],
      ),
    );
  }
}