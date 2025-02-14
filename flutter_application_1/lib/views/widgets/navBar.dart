import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/screens/play/play.dart';
import 'package:flutter_application_1/views/screens/ranking/ranking.dart';
import 'package:flutter_application_1/views/screens/account/account.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = Play();
        break;
      case 1:
        nextScreen = Ranking();
        break;
      case 2:
        nextScreen = Account();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      selectedItemColor: main_green,
      unselectedItemColor: Colors.white54,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(context, index), // Use context for navigation
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.mood),
          label: "Play",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_add),
          label: "Friends",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Account",
        ),
      ],
    );
  }
}
