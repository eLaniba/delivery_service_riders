import 'package:delivery_service_riders/authentication/login.dart';
import 'package:delivery_service_riders/authentication/register.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rider'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.login),),
              Tab(icon: Icon(Icons.person_add_alt_1_outlined),),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Login(),
            Register(),
          ],
        ),
      ),
    );
  }
}
