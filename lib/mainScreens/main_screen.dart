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
      Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
      ),
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
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
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
        items: [
          BottomNavigationBarItem(
            icon: widget.mainScreenIndex == 0
                ? Icon(PhosphorIcons.user(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: widget.mainScreenIndex == 1
                ? Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.regular)),
            label: 'New Delivery',
          ),
          BottomNavigationBarItem(
            icon: widget.mainScreenIndex == 2
                ? Icon(PhosphorIcons.path(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.path(PhosphorIconsStyle.regular)),
            label: 'In Progress',
          ),
        ],
      ),
    );
  }
}
