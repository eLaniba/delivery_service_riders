import 'package:delivery_service_riders/authentication/login_screen.dart';
import 'package:delivery_service_riders/mainScreens/main_screen_provider.dart';
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
    // TODO: quick logout for testing
    // quickLogout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data == true) {
          return MainScreenProvider(mainScreenIndex: 0, inProgressScreenIndex: 2,);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
