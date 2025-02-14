import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';



class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,  // ✅ Removes the back button
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: Text(
            "Play",
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: const Center(
        child: Text(
          "Welcome to Account Screen!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // ✅ Remove onTabSelected

    );
  }
}
