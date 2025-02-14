import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class Drawing_Board extends StatelessWidget {
  final DrawingController _drawingController = DrawingController();

  @override
  Widget build(BuildContext context) {
    return DrawingBoard(
      controller: _drawingController,
      background: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        color: Colors.white,
      ),
      showDefaultActions: true,
      showDefaultTools: true,
    );
  }
}