import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/play/play.dart';
import 'package:flutter_application_1/views/screens/account/account.dart';
import 'package:flutter_application_1/views/screens/ranking/ranking.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/sign_in.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/signin';
  static const String play = '/play';
  static const String account = '/account';
  static const String ranking = '/ranking';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => Home());
      case login:
        return MaterialPageRoute(builder: (_) => SignUp());
      case play:
        return MaterialPageRoute(builder: (_) => Play());
      case account:
        return MaterialPageRoute(builder: (_) => Account());
      case ranking:
        return MaterialPageRoute(builder: (_) => FriendsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
