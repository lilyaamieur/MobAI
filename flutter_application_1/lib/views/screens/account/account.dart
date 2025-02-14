import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        automaticallyImplyLeading: true, // Shows the back button
        centerTitle: true, // Centers the title
        title: Text(
          "Account",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // ✅ Profile Picture with Edit Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'lib/images/douda.png'), // Replace with actual profile image
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Name Input Field
            TextField(
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                hintText: "Username",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Bio Input Field
            TextField(
              maxLines: 3,
              style: TextStyle(color: Colors.white), // Text color
              decoration: InputDecoration(
                hintText: "Bio",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print("Save button pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
