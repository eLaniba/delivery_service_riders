import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'global/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  savedPickedUpOrderPop = await loadPickedUpOrdersPop();
  savedDeliveredOrderPop = await loadDeliveredOrdersPop();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore Persistence using the latest approach
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // ✅ Enables offline caching
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // ✅ Optional: No limit on cache size
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tindaPHrider',
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
