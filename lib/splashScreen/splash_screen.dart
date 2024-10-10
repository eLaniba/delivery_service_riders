import 'dart:async';

import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/mainScreens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const AuthScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Rider's App",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
