import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/views/widgets/list_players_game.dart';

class MultiplayerGame extends StatefulWidget {
  @override
  _MultiplayerGameState createState() => _MultiplayerGameState();
}

class _MultiplayerGameState extends State<MultiplayerGame> {
  final DrawingController _controller = DrawingController();
  final SupabaseClient supabase = Supabase.instance.client;
  String gameId = "";
  String userId = "";
  List<String> players = [];
  String? currentDrawer;
  bool isDrawingTurn = false;
  String? guessedWord;
  String chatMessage = "";
  List<Map<String, String>> chatMessages = [];
  
  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    findOrCreateGame();
    listenToGameUpdates();
  }

  Future<void> findOrCreateGame() async {
    var response = await supabase
        .from("games_multi")
        .select()
        .eq("status", "waiting")
        .limit(1)
        .maybeSingle();

    if (response != null) {
      gameId = response["id"];
      players = List<String>.from(response["list_players"]);
      if (!players.contains(userId)) {
        players.add(userId);
        await supabase.from("games_multi").update({
          "list_players": players,
          "status": players.length == 3 ? "in_progress" : "waiting"
        }).eq("id", gameId);
      }
    } else {
      gameId = const Uuid().v4();
      await supabase.from("games_multi").insert({
        "id": gameId,
        "list_players": [userId],
        "status": "waiting"
      });
      players = [userId];
    }
    setState(() {});
  }

  void listenToGameUpdates() {
    supabase.from("games_multi").stream(primaryKey: ["id"]).eq("id", gameId).listen((data) {
      if (data.isNotEmpty) {
        var gameData = data[0];
        setState(() {
          players = List<String>.from(gameData["list_players"]);
          currentDrawer = gameData["current_drawer"];
          isDrawingTurn = currentDrawer == userId;
        });
      }
    });
  }

  void sendMessage() async {
    if (chatMessage.isNotEmpty) {
      chatMessages.add({"user": userId, "message": chatMessage});
      await supabase.from("chat_messages").insert({
        "game_id": gameId,
        "user_id": userId,
        "message": chatMessage
      });
      setState(() => chatMessage = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multiplayer Drawing Game")),
      body: Column(
        children: [
          Text("Players: ${players.join(", ")}", style: TextStyle(fontSize: 18)),
          isDrawingTurn
              ? Expanded(
                  child: DrawingBoard(
                    controller: _controller,
                    background: Container(color: Colors.white),
                  ),
                )
              : Expanded(
                  child: Center(
                    child: Text("Guess the word!", style: TextStyle(fontSize: 22)),
                  ),
                ),
          ProfileAvatarList(
            avatarUrls: [
              "images\douda.png",
              "images\douda.png","images\douda.png","images\douda.png",

            ],
          ),
          Divider(),
          Expanded(
                      child: DrawingBoard(
                        controller: _controller,
                        background: Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                        ),
                        showDefaultActions: true,
                        showDefaultTools: true,
                      ),
                    ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatMessages[index]["user"]!),
                  subtitle: Text(chatMessages[index]["message"]!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => chatMessage = value,
                    decoration: InputDecoration(labelText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
