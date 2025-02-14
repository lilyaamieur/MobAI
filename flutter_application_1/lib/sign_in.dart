import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';
import 'package:flutter_application_1/colors.dart';
import 'constants.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
  

  void navigateToMainScreen2(AuthResponse response) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(
          ),
        ),
      );
    }


  
  void navigateToMainScreen1(AuthResponse response) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SignUp(
          ),
        ),
      );
    }




    final darkModeThemeData = ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(248, 183, 183, 183),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.blueGrey[300],
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.black,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 1,
          ),
        ),
        labelStyle: const TextStyle(
          color: Color.fromARGB(179, 255, 255, 255),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: main_green,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: main_black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [main_black, Colors.black87, main_black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: main_green.withOpacity(1), // Neon green glow
              blurRadius: 40,
              spreadRadius: 5,
              offset: Offset(0, -15), // Top glow
            ),
                        BoxShadow(
              color: main_black.withOpacity(1), // Neon green glow
              blurRadius: 40,
              spreadRadius: 5,
              offset: Offset(0, -15), // Top glow
            ),
            BoxShadow(
              color: main_green.withOpacity(0.7), // Neon green glow
              blurRadius: 40,
              spreadRadius: 5,
              offset: Offset(0, 15), // Bottom glow
            ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 150),

            Align(
              alignment: Alignment.center,
              child: Text(
                'Register Now !',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: screenWidth * 0.1,
                  shadows: [
                    Shadow(
                      color: main_green,
                      offset: Offset(4, 4),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            spacer,

            Card(
              elevation: 10,
              color: const Color.fromARGB(255, 24, 24, 24),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Theme(
                  data: darkModeThemeData,
                  child: SupaEmailAuth(
                    redirectTo: kIsWeb ? null : 'io.supabase.flutter://',
                    onSignInComplete: navigateToMainScreen2,
                    onSignUpComplete: navigateToMainScreen1,
                    prefixIconEmail: null,
                    prefixIconPassword: null,
                    localization: const SupaEmailAuthLocalization(
                      enterEmail: "email",
                      enterPassword: "password",
                      dontHaveAccount: "Already have an account ? Sign Up",
                      forgotPassword: "forgot password",
                    ),
                    metadataFields: [
                      MetaDataField(
                        prefixIcon: const Icon(Icons.person),
                        label: 'Username',
                        key: 'username',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter something';
                          }
                          return null;
                        },
                      ),
                      BooleanMetaDataField(
                        label:
                            'Keep me up to date with the latest news and updates.',
                        key: 'marketing_consent',
                        checkboxPosition: ListTileControlAffinity.leading,
                      ),
                      BooleanMetaDataField(
                        key: 'terms_agreement',
                        isRequired: true,
                        checkboxPosition: ListTileControlAffinity.leading,
                        richLabelSpans: [
                          const TextSpan(text: 'I have read and agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions.',
                            style: const TextStyle(
                              color: main_green,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print('Terms and Conditions');
                              },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            spacer,
          ],
        ),
      ),
    );
  }
}
