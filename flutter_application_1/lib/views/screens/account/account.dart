import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';
import 'package:image_picker/image_picker.dart'; // For profile picture updates

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid uuid = Uuid();

  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String profileImage = 'lib/images/douda.png';

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
          .maybeSingle();

      if (accountResponse == null) {
        final newAccountId = uuid.v4();
        await supabase.from('Account').insert({
          'id': newAccountId,
          'user_name': "New User",
          'email': userEmail,
          'bio': "Hello, I'm new here!",
        });
      } else {
        setState(() {
          usernameController.text = accountResponse['user_name'] ?? "Undetermined";
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

      final existingUser = await supabase
          .from('Account')
          .select('id')
          .eq('email', user.email.toString())
          .maybeSingle();

      if (existingUser == null) {
        await supabase.from('Account').insert({
          'id': uuid.v4(),
          'email': user.email,
          'user_name': usernameController.text.isNotEmpty ? usernameController.text : "New User",
          'bio': bioController.text.isNotEmpty ? bioController.text : "Hello, I'm new here!",
        });
      } else {
        await supabase.from('Account').update({
          'user_name': usernameController.text,
          'bio': bioController.text,
        }).eq('email', user.email.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  void logout() {
    supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        centerTitle: true,
        title: Text(
          "Account",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Profile Picture
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: main_green, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Username Input
            buildInputField("Username", usernameController),

            const SizedBox(height: 15),

            // Bio Input
            buildInputField("Bio", bioController, maxLines: 3),

            const SizedBox(height: 30),

            // Save Button
            buildActionButton("Save", updateUserData, Colors.green),

            const SizedBox(height: 20),

            // Logout Button
            buildActionButton("Logout", logout, Colors.red),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // Custom Input Field Widget
  Widget buildInputField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black54,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Custom Action Button Widget
  Widget buildActionButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
