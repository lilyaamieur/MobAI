import 'package:flutter/material.dart';
import 'package:flutter_application_1/drawing/online_mode.dart';
import 'package:flutter_application_1/drawing/drawing_page.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Guess Drawing Challenge'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineModeScreen(userId: userId),
                  ),
                );
              },
              child: Text('Online Mode'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineModeScreen(),
                  ),
                );
              },
              child: Text('Offline Mode'),
            ),
          ],
        ),
      ),
    );
  }
}