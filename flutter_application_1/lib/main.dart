import 'package:flutter_application_1/auth/auth_wrapper.dart';
import 'package:flutter_application_1/phone_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase_auth_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import './home.dart';
import './sign_in.dart';
import './magic_link.dart';
import './update_password.dart';
import 'phone_sign_in.dart';
import './verify_phone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {  
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
  catch (e) {
    print('Error initializing Supabase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/home': (context) => AuthWrapper()
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
