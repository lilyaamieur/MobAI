import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaitingScreen extends StatefulWidget {
  final String userId;

  WaitingScreen({required this.userId});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  bool _isMatched = false;
  late int _sessionId;
  String _opponentId = '';

  Future<void> _joinSession() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/sessions/join'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': widget.userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['status'] == 'matched') {
        setState(() {
          _isMatched = true;
          _sessionId = data['session_id'];
          _opponentId = data['opponent_id'];
        });
      } else {
        // Keep polling until matched
        await Future.delayed(Duration(seconds: 2));
        _joinSession();
      }
    } else {
      print('Failed to join session: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting for Opponent'),
      ),
      body: Center(
        child: _isMatched
            ? Text('Matched with opponent: $_opponentId')
            : CircularProgressIndicator(),
      ),
    );
  }
}