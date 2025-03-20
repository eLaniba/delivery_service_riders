import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/in_progress_main_screen.dart';
import 'package:delivery_service_riders/mainScreens/messages_screens/messages_screen.dart';
import 'package:delivery_service_riders/mainScreens/new_delivery_screens/new_delivery_screen.dart';
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
      const NewDeliveryScreen(),
      InProgressMainScreen(index: widget.inProgressScreenIndex,),
      Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mainScreenIndex == 0
              ? 'New Delivery'
              : widget.mainScreenIndex == 1
              ? 'In Progress Delivery'
              : '${sharedPreferences!.getString('name')}'
        ),
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.get('uid')}')
                .collection('cart')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const CartScreen()),
                        // );
                      },
                      icon: Icon(PhosphorIcons.bell()),
                    ),
                    Positioned(
                      right: 10,
                      top: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (c) => const CartScreen()),
                        // );
                      },
                      icon: Icon(PhosphorIcons.bell()),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          //Chat Screen
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesScreen()),
              );
            },
            icon: Icon(PhosphorIcons.chatText()),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: _screens[widget.mainScreenIndex],
      floatingActionButton:
        widget.mainScreenIndex == 1 // Check if the Products tab is selected
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
                ? Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.regular)),
            label: 'New Delivery',
          ),
          BottomNavigationBarItem(
            icon: widget.mainScreenIndex == 1
                ? Icon(PhosphorIcons.path(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.path(PhosphorIconsStyle.regular)),
            label: 'In Progress',
          ),
          BottomNavigationBarItem(
            icon: widget.mainScreenIndex == 2
                ? Icon(PhosphorIcons.user(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
