import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('active_orders')
              .where('riderID', isEqualTo: sharedPreferences!.get('uid'))
              .where('orderStatus', whereIn: ['Delivered', 'Completed', 'Cancelled'])
              .orderBy('orderTime', descending: true)
              .snapshots(),
          builder: (context, orderSnapshot) {
            if(orderSnapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(),));
            } else if(orderSnapshot.hasError) {
              return SliverToBoxAdapter(child: Center(child: Text('Error: ${orderSnapshot.error}'),));
            } else if(orderSnapshot.hasData && orderSnapshot.data!.docs.isNotEmpty) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index){
                  NewOrder order = NewOrder.fromJson(orderSnapshot.data!.docs[index].data()! as Map<String, dynamic>,);
                  return OrderCard(order: order,);

                },
                  childCount: orderSnapshot.data!.docs.length,
                ),
              );
            } else {
              // return const SliverFillRemaining(child: Center(child: Text('No order yet.')));
              return const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
