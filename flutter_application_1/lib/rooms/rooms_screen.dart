import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'drawing_screen.dart';

class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final response = await supabase.from('rooms').select();
    setState(() {
      rooms = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _createRoom() async {
    await supabase.from('rooms').insert({'is_private': false});
    _fetchRooms();
  }

  void _joinRoom(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrawingScreen(roomId: roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rooms")),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Room ${rooms[index]['id']}"),
            trailing: ElevatedButton(
              onPressed: () => _joinRoom(rooms[index]['id']),
              child: Text("Join"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: Icon(Icons.add),
      ),
    );
  }
}
