import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/upload_page.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://mshrjmoigzxwimnnnatu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zaHJqbW9pZ3p4d2ltbm5uYXR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxMTk4MjAsImV4cCI6MjA1NDY5NTgyMH0.9oU70sil_DZAyHzbcWQEln-vyqdi5eez7Tf7JwmEr6E',
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
