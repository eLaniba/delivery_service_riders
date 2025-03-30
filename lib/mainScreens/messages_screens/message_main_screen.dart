import 'package:delivery_service_riders/mainScreens/messages_screens/message_store_screen.dart';
import 'package:delivery_service_riders/mainScreens/messages_screens/message_user_screen.dart';
import 'package:delivery_service_riders/services/providers/badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class MessageMainScreen extends StatefulWidget {
  const MessageMainScreen({super.key});

  @override
  State<MessageMainScreen> createState() => _MessageMainScreenState();
}

class _MessageMainScreenState extends State<MessageMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const MessageStoreScreen(),
    const MessageUserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeMessageCount = context.watch<StoreMessageCount>().count ?? 0;
    final userMessageCount = context.watch<UserMessageCount>().count ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _selectedIndex == 0
                    ? Icon(PhosphorIcons.storefront(PhosphorIconsStyle.fill))
                    : Icon(PhosphorIcons.storefront(PhosphorIconsStyle.regular)),

                if (storeMessageCount > 0)
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
                      child: Text(storeMessageCount < 99 ? '$storeMessageCount' : '99',
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
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _selectedIndex == 0
                    ? Icon(PhosphorIcons.user(PhosphorIconsStyle.fill))
                    : Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),

                if (userMessageCount > 0)
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
                      child: Text(userMessageCount < 99 ? '$userMessageCount' : '99',
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
            label: 'User',
          ),
        ],
      ),
    );
  }
}
