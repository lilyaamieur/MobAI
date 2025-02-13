import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Authentication directories
import 'package:flutter_application_1/views/screens/authentication/Sign_in.dart';

class AppRoutes {


  static const String login = '/login';
  static const String signup = '/signup';

// Route generator

  // Route generator
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      
      case login:
        return MaterialPageRoute(builder: (_) => SignUp());

    }
    return null;
  }
}