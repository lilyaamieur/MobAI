import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/views/screens/authentication/sign_in.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';
import 'package:flutter_application_1/views/screens/authentication/home.dart';
import 'package:flutter_application_1/views/screens/authentication/magic_link.dart';
import 'package:flutter_application_1/views/screens/authentication/update_password.dart';
import 'package:flutter_application_1/views/screens/authentication/phone_sign_in.dart';
import 'package:flutter_application_1/views/screens/authentication/phone_sign_up.dart';
import 'package:flutter_application_1/views/screens/authentication/verify_phone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  try {
    print("loading dotenv ...");
    await dotenv.load(fileName: ".env");
    print("dotenv loaded!");
    print("initializing supabase ...");
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
  }
  catch (e) {
    print("Error loading dotenv: $e");
  }

  runApp(const MainApp());
}



class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUp(),
        '/magic_link': (context) => const MagicLink(),
        '/update_password': (context) => const UpdatePassword(),
        '/phone_sign_in': (context) => const PhoneSignIn(),
        '/phone_sign_up': (context) => const PhoneSignUp(),
        '/verify_phone': (context) => const VerifyPhone(),
        '/home': (context) => const Home(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const Scaffold(
            body: Center(
              child: Text(
                'Not Found',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}