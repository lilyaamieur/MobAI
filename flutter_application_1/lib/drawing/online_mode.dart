import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class OnlineMode extends StatefulWidget {
  @override
  _OnlineModeState createState() => _OnlineModeState();
}

class _OnlineModeState extends State<OnlineMode> {
  final DrawingController _controller = DrawingController();
  final SupabaseClient supabase = Supabase.instance.client;
  String gameId = "";
  String userId = "" ; // Example, fetch from auth
  String prompt = "Draw a House";

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    findOrCreateGame();
  }

  Future<void> findOrCreateGame() async {
    var response = await supabase.from("games").select().eq("status", "waiting").limit(1);
    
    if (response.isNotEmpty) {
      print(response);
      gameId = response[0]["id"];
      await supabase.from("games").update({"player2_id": userId, "status": "in_progress"}).eq("id", gameId);
    } else {
      print("Game joined");
      gameId = const Uuid().v4();
      await supabase.from("games").insert({
        "id": gameId,
        "prompt": prompt,
        "player1_id": userId,
        "status": "waiting"
      });
    }

    listenToGameUpdates();
  }

  void listenToGameUpdates() {
    supabase.from("games").stream(primaryKey: ["id"]).eq("id", gameId).listen((data) {
      if (data.isNotEmpty) {
        setState(() {
          prompt = data[0]["prompt"];
        });
      }
    });
  }

  Future<void> submitDrawing() async {
    ByteData? drawingData = await _controller.getImageData();
    if (drawingData == null) return;

    Uint8List uint8List = drawingData.buffer.asUint8List(); 
    String base64Image = base64Encode(uint8List);


    await supabase.from("games").update({
      userId == "player1_id" ? "player1_drawing" : "player2_drawing": base64Image
    }).eq("id", gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Online Mode: $prompt")),
      body: Column(
        children: [
          Expanded(child: DrawingBoard(
              controller: _controller,
              background: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
              ),
              showDefaultActions: true,
              showDefaultTools: true,
            ),),
          ElevatedButton(
            onPressed: submitDrawing,
            child: Text("Submit Drawing"),
          ),
        ],
      ),
    );
  }
}
