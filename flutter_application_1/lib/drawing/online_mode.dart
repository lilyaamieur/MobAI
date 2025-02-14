import 'package:flutter/material.dart';
import 'waiting_screen.dart';

class OnlineModeScreen extends StatelessWidget {
  final String userId;

  OnlineModeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Mode'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingScreen(userId: userId),
              ),
            );
          },
          child: Text('Start Game'),
        ),
      ),
    );
  }
}