import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  ChatScreen({required this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    supabase.from("messages").stream(primaryKey: ["id"]).eq("room_id", widget.roomId).listen((data) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });
    });
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    await supabase.from("messages").insert({
      "room_id": widget.roomId,
      "user_id": supabase.auth.currentUser!.id,
      "message": message,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]["message"]),
                );
              },
            ),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: _sendMessage)),
          ),
        ],
      ),
    );
  }
}
