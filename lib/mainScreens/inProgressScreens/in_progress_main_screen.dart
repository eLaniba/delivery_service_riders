import 'package:delivery_service_riders/mainScreens/inProgressScreens/completing_screen.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/start_delivery_screen.dart';
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

class _InProgressMainScreenState extends State<InProgressMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the initial index
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.index);
  }

  @override
  void dispose() {
    // Dispose the TabController
    _tabController.dispose();
    super.dispose();
  }

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
              child: TabBar(
                indicator: null,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Store Pickup',),
                  Tab(text: 'Start Delivery',),
                  Tab(text: 'Completing',),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  StorePickupScreen(),
                  StartDeliveryScreen(),
                  CompletingScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
