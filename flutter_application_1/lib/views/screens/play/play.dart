import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/drawing/offline_mode.dart';
//import 'package:flutter_application_1/drawing/offline_mode.dart';
import 'package:flutter_application_1/drawing/online_mode.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        automaticallyImplyLeading: false, // ✅ Removes the back button
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: Text(
            "Play",
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
        children: [
          SizedBox(height: 50),
          Align(
            alignment: Alignment.center,
            child: Image.asset('lib/images/play.png'),
          ),
          SizedBox(height: 30), // Space after image

          // ✅ Buttons wrapped in a Column to ensure alignment
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildButton("Start Game", () => print("Start Game Pressed")),
              SizedBox(height: 20), // Space between buttons
              _buildButton("Leaderboard", () => print("Leaderboard Pressed")),
              SizedBox(height: 20),
              _buildButton("Settings", () => print("Settings Pressed")),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // ✅ Function to create uniform buttons
  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 250, // Ensures all buttons have the same width
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OfflineMode()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: main_green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15), // Ensures same height
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }
}
