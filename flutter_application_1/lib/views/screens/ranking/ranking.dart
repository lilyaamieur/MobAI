import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';

class Ranking extends StatefulWidget {
  const Ranking({Key? key}) : super(key: key);

  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        automaticallyImplyLeading: false,  // ✅ Removes the back button
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: Text(
            "Friends",
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: const Center(
        child: Text(
          "Welcome to Ranking Screen!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // ✅ Remove onTabSelected

    );
  }
}
