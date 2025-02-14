import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are home',
              style: TextStyle(fontSize: 42),
            ),
            ElevatedButton(
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // ✅ Remove onTabSelected
    );
  }
}
