import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // Import UUID to generate unique IDs

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid uuid = Uuid(); // UUID generator for unique IDs

  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  String profileImage = 'lib/images/douda.png'; // Default profile picture

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final userEmail = user.email;

      final accountResponse = await supabase
          .from('Account')
          .select('id, user_name, bio')
          .eq('email', userEmail.toString())
          .maybeSingle(); // Avoids crashes if no account is found

      if (accountResponse == null) {
        // ✅ If no account exists, create a new one
        final newAccountId = uuid.v4();
        await supabase.from('Account').insert({
          'id': newAccountId,
          'user_name': "New User",
          'email': userEmail,
          'bio': "Hello, I'm new here!",
        });
        print("New account created.");
      } else {
        // ✅ If account exists, update UI with the data
        setState(() {
          usernameController.text =
              accountResponse['user_name'] ?? "Undetermined";
          bioController.text = accountResponse['bio'] ?? "Undetermined";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

Future<void> updateUserData() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // ✅ First, check if the user exists in the database
    final existingUser = await supabase
        .from('Account')
        .select('id')
        .eq('email', user.email.toString())
        .maybeSingle();

    if (existingUser == null) {
      // ✅ If user doesn't exist, insert a new account
      await supabase.from('Account').insert({
        'id': uuid.v4(), // Generates a unique ID
        'email': user.email,
        'user_name': usernameController.text.isNotEmpty
            ? usernameController.text
            : "New User",
        'bio': bioController.text.isNotEmpty
            ? bioController.text
            : "Hello, I'm new here!",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New account created successfully!")),
      );
    } else {
      // ✅ If user exists, update their profile data
      await supabase.from('Account').update({
        'user_name': usernameController.text,
        'bio': bioController.text,
      }).eq('email', user.email.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  } catch (e) {
    print("Error updating user data: $e");
  }
}

  void logout() {
    supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        automaticallyImplyLeading: true,
        centerTitle: true,
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
                  backgroundImage: NetworkImage(profileImage),
                  onBackgroundImageError: (_, __) =>
                      AssetImage('lib/images/douda.png'),
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
              controller: usernameController,
              style: TextStyle(color: Colors.white),
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
              controller: bioController,
              maxLines: 3,
              style: TextStyle(color: Colors.white),
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
                onPressed: updateUserData,
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
                onPressed: logout,
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
