import 'package:delivery_service_riders/mainScreens/inProgressScreens/store_pickup_screen.dart';
import 'package:flutter/material.dart';

class InProgressMainScreen extends StatefulWidget {
  InProgressMainScreen({
    super.key,
    required this.index,
  });

  int index;

  @override
  State<InProgressMainScreen> createState() => _InProgressMainScreenState();
}

class _InProgressMainScreenState extends State<InProgressMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Store Pickup',),
                  Tab(text: 'Start Delivery',),
                  Tab(text: 'Completing',),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  StorePickupScreen(),
                  Placeholder(child: Center(child: Text('Start Delivery'),),),
                  Placeholder(child: Center(child: Text('Completing'),),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
