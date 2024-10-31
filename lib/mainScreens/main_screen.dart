import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/new_delivery_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int widgetIndex = 0;

  final List<Widget> _screens = [
    const Placeholder(child: Center(child: Text('My Profile'),),),
    const NewDeliveryScreen(),
    const Placeholder(child: Center(child: Text('In Progress Delivery'),),),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widgetIndex == 0
              ? '${sharedPreferences!.getString('name')}'
              : widgetIndex == 1
              ? 'New Delivery'
              : 'In Progress Delivery'
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: _screens[widgetIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widgetIndex = index;
          });
        },
        currentIndex: widgetIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases_outlined),
            label: 'New Delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike_outlined),
            label: 'In Progress',
          ),
        ],
      ),
    );
  }
}
