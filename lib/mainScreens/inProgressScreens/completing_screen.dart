import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/start_delivery_screen_2.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/widgets/order_card.dart';
import 'package:delivery_service_riders/widgets/order_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'completing_screen_2.dart';

class CompletingScreen extends StatefulWidget {
  const CompletingScreen({super.key});

  @override
  State<CompletingScreen> createState() => _CompletingScreenState();
}

class _CompletingScreenState extends State<CompletingScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('active_orders')
              .where('riderID', isEqualTo: '${sharedPreferences!.get('uid')}')
              .where('orderStatus', whereIn: ['Delivered', 'Completing'])
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

                  return OrderCard(order: order);
                },
                  childCount: orderSnapshot.data!.docs.length,
                ),
              );
            } else {
              // return const SliverFillRemaining(child: Center(child: Text('No order yet.')));
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.empty(PhosphorIconsStyle.regular),
                        size: 48,
                        color: Colors.grey,
                      ),
                      const Text(
                        'You don\'t have any active delivery',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
