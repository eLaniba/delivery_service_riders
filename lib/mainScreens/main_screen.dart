import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/in_progress_main_screen_provider.dart';
import 'package:delivery_service_riders/mainScreens/messages_screens/message__main_screen_provider.dart';
import 'package:delivery_service_riders/mainScreens/new_delivery_screens/new_delivery_screen.dart';
import 'package:delivery_service_riders/mainScreens/profile_screens/profile_screen.dart';
import 'package:delivery_service_riders/services/providers/badge_provider.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late final List<Widget> _screens;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ///Handles Online/Offline Status
    WidgetsBinding.instance.addObserver(this);

    _screens = [
      const NewDeliveryScreen(),
      InProgressMainScreenProvider(index: widget.inProgressScreenIndex,),
      const ProfileScreen(),
    ];

    updateRiderStatus('online');
  }

  ///Online Offline Status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateRiderStatus('online');
        break;
      case AppLifecycleState.paused:
        updateRiderStatus('idle');
        break;
      case AppLifecycleState.detached:
        updateRiderStatus('offline');
        break;
      case AppLifecycleState.inactive:
      // Optional: can be ignored for now
        break;
      case AppLifecycleState.hidden:
      // iOS/macOS specific, safe to treat like paused or do nothing
        updateRiderStatus('idle');
        break;
    }
  }


  @override
  void dispose() {
    updateRiderStatus('offline');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newDeliveryOrders = Provider.of<NewDeliveryOrders?>(context)?.orders ?? [];
    final inProgressCount = context.watch<InProgressCount>().count ?? 0;
    final notificationCount = context.watch<NotificationCount>().count ?? 0;
    final messageCount = context.watch<MessageCount>().count ?? 0;

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
          //Notification
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Placeholder()), // Your search screen
                  );
                },
                icon: Icon(PhosphorIcons.bell()),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount < 99 ? '$notificationCount' : '99',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          //Messages
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MessageMainScreenProvider()), // Your search screen
                  );
                },
                icon: Icon(PhosphorIcons.chatText()),
              ),
              if (messageCount > 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      messageCount < 99 ? '$messageCount' : '99',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: _screens[widget.mainScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widget.mainScreenIndex = index;
          });
        },
        currentIndex: widget.mainScreenIndex,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.mainScreenIndex == 0
                    ? Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.fill))
                    : Icon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.regular)),

                if (newDeliveryOrders.isNotEmpty)
                  Positioned(
                    left: 16,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(newDeliveryOrders.length < 99 ? '${newDeliveryOrders.length}' : '99',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'New Delivery',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.mainScreenIndex == 1
                    ? Icon(PhosphorIcons.path(PhosphorIconsStyle.fill))
                    : Icon(PhosphorIcons.path(PhosphorIconsStyle.regular)),

                if (inProgressCount > 0)
                  Positioned(
                    left: 16,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(inProgressCount < 99 ? '$inProgressCount' : '99',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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
