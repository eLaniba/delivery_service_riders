
import 'package:delivery_service_riders/authentication/login_screen.dart';
import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  void quickLogout() {
    _authService.setLoginState(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quickLogout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data == true) {
          return MainScreen(mainScreenIndex: 0, inProgressScreenIndex: 1,);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
