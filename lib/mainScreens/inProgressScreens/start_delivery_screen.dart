import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/services/providers/order_stream_provider.dart';
import 'package:delivery_service_riders/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class StartDeliveryScreen extends StatelessWidget {
  const StartDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<StartDeliveryOrders?>(context)?.orders ?? [];

    return CustomScrollView(
      slivers: [
        if (orders.isEmpty)
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.empty(PhosphorIconsStyle.regular), size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('No active order', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => OrderCard(order: orders[index]),
              childCount: orders.length,
            ),
          ),
      ],
    );
  }
}
