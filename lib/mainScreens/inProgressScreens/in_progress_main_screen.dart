import 'package:delivery_service_riders/mainScreens/inProgressScreens/completing_screen.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/start_delivery_screen.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/store_pickup_screen.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/services/providers/order_stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final storePickupOrders = Provider.of<StorePickupOrders?>(context)?.orders ?? [];
    final startDeliveryOrders = Provider.of<StartDeliveryOrders?>(context)?.orders ?? [];
    final completingOrders = Provider.of<CompletingDeliveryOrders?>(context)?.orders ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  buildTabWithBadge(context, 'Store Pickup', storePickupOrders.length),
                  buildTabWithBadge(context, 'Start Delivery', startDeliveryOrders.length),
                  buildTabWithBadge(context, 'Completing', completingOrders.length),
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

  Widget buildTabWithBadge(BuildContext context, String title, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tab(text: title),
        if (count > 0)
          Positioned(
            top: 0,
            right: -12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
