import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/upload_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print("loading dotenv ...");
  await dotenv.load(fileName: ".env");
  print("dotenv loaded!");
  print("initializing supabase ...");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: UploadPage(),
        ),
      ),
    );
  }
}
