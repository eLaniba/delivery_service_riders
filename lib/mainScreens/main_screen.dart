import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/in_progress_main_screen.dart';
import 'package:delivery_service_riders/mainScreens/new_delivery_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainScreen extends StatefulWidget {
  MainScreen({
    super.key,
    required this.mainScreenIndex,
    required this.inProgressScreenIndex,
  });

 int mainScreenIndex;
 int inProgressScreenIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _screens;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _screens = [
      const Placeholder(child: Center(child: Text('My Profile'),),),
      const NewDeliveryScreen(),
      InProgressMainScreen(index: widget.inProgressScreenIndex,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mainScreenIndex == 0
              ? '${sharedPreferences!.getString('name')}'
              : widget.mainScreenIndex == 1
              ? 'New Delivery'
              : 'In Progress Delivery'
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: _screens[widget.mainScreenIndex],
      floatingActionButton:
        widget.mainScreenIndex == 2 // Check if the Products tab is selected
            ? FloatingActionButton(
                onPressed: () {

                },
                child: Icon(
               PhosphorIcons.package(PhosphorIconsStyle.fill),
          ),
        ) : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widget.mainScreenIndex = index;
          });
        },
        currentIndex: widget.mainScreenIndex,
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
