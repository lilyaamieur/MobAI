import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/views/screens/authentication/sign_in.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';

import 'package:flutter_application_1/views/screens/authentication/home.dart';
import 'package:flutter_application_1/views/screens/authentication/sign_in.dart';
import 'package:flutter_application_1/views/screens/authentication/magic_link.dart';
import 'package:flutter_application_1/views/screens/authentication/update_password.dart';
import 'package:flutter_application_1/views/screens/authentication/phone_sign_in.dart';
import 'package:flutter_application_1/views/screens/authentication/phone_sign_up.dart';

import 'package:flutter_application_1/views/screens/authentication/verify_phone.dart';


void main() async {
  await Supabase.initialize(
    url: 'https://mshrjmoigzxwimnnnatu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zaHJqbW9pZ3p4d2ltbm5uYXR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxMTk4MjAsImV4cCI6MjA1NDY5NTgyMH0.9oU70sil_DZAyHzbcWQEln-vyqdi5eez7Tf7JwmEr6E',
  );

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