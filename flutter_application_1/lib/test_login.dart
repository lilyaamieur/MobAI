import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  Future<void> updateAccountStatus(String status) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase
          .from('Account')
          .update({'status': status}).eq('id', userId);
    }
  }

  void checkUserStatus() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await updateAccountStatus("online"); // ✅ Set status to "online"
    } else {
      await updateAccountStatus("offline"); // ✅ Set status to "offline"
    }
  }

  void navigateToMainScreen2(AuthResponse response) {
    final userId = response.user?.id ?? '';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  void navigateToMainScreen1(AuthResponse response) {
    final userId = response.user?.id ?? '';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SignUp(),
      ),
    );
  }

  Future<void> logout() async {
    await updateAccountStatus(
        "offline"); // ✅ Set status to "offline" before logout
    await supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: main_black,
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 150),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Register Now!',
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: main_green, offset: Offset(4, 4), blurRadius: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 10,
              color: const Color(0xFF181818),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Theme(
                  data: ThemeData.dark(),
                  child: SupaEmailAuth(
                    redirectTo: 'io.supabase.flutter://',
                    onSignInComplete: navigateToMainScreen1,
                    onSignUpComplete: navigateToMainScreen2,
                    localization: const SupaEmailAuthLocalization(
                      enterEmail: "email",
                      enterPassword: "password",
                      dontHaveAccount: "Already have an account? Sign Up",
                      forgotPassword: "Forgot password?",
                    ),
                    metadataFields: [
                      MetaDataField(
                        prefixIcon: const Icon(Icons.person),
                        label: 'Username',
                        key: 'username',
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please enter something'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
