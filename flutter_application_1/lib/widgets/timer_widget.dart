import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingTime;

  TimerWidget({required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Remaining: $remainingTime seconds',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}