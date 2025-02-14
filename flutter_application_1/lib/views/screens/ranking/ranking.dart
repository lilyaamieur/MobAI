import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Map<String, dynamic>> friends = [
    {'name': 'Lalak', 'status': 'Online'},
    {'name': 'Lalak', 'status': 'Offline'},
    {'name': 'Lalak', 'status': 'Offline'},
    {'name': 'Lalak', 'status': 'Offline'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        automaticallyImplyLeading: true,
        elevation: 0,
        title: Text(
          "Friends",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add a new friend !", style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: main_green),
                hintText: "Username",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black54,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white24),
            Text("Invite a friend to play together !", style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  bool isOnline = friend['status'] == 'Online';
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOnline
                            ? [const Color.fromARGB(253, 255, 255, 255), main_green]
                            : [const Color.fromARGB(255, 255, 255, 255), Colors.white10],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[200],
                        child: Text("A", style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        friend['name'],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        friend['status'],
                        style: TextStyle(color: isOnline ? main_green : Colors.redAccent),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: main_green, size: 30),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
