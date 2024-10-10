import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, // Main color
            accentColor: Colors.blueAccent, // Accent color
            errorColor: Colors.red, // Error color
            brightness: Brightness.light
        ),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}