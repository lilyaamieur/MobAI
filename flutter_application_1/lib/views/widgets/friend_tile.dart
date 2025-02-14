import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';

class FriendTile extends StatelessWidget {
  final String name;
  final String status;

  const FriendTile({Key? key, required this.name, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOnline = status == 'Online';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [const Color.fromARGB(50, 255, 255, 255), main_green]
              : [const Color.fromARGB(50, 255, 255, 255), Colors.white10],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[200],
          child: Text(name[0], style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          name,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          status,
          style: TextStyle(color: isOnline ? main_green : Colors.redAccent),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: main_black, size: 30),
          onPressed: () {},
        ),
      ),
    );
  }
}
