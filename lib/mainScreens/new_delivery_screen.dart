import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/mainScreens/new_delivery_screen_2.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../global/global.dart';

class NewDeliveryScreen extends StatefulWidget {
  const NewDeliveryScreen({super.key});

  @override
  State<NewDeliveryScreen> createState() => _NewDeliveryScreenState();
}

class _NewDeliveryScreenState extends State<NewDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('active_orders')
              .where('orderStatus', isEqualTo: 'Waiting')
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

                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 2,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (c) => NewDeliveryScreen2(orderDetail: order,)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            //Icon + Order Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  child: Icon(
                                    Icons.circle,
                                    color: Colors.blueGrey,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8,),
                                Flexible(
                                  child: Text('${order.orderStatus}'),
                                ),
                              ],
                            ),
                            //Icon + User Name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  child: Icon(
                                    Icons.person_2_outlined,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8,),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${order.storeName}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${order.storePhone}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                            //Item(s) Text
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 12,),
                                Text(
                                  'Item(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            //Vertical Scroll list of Items
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: order.items!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 100,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          // padding: const EdgeInsets.all(4),
                                          height: 80,
                                          width: 80,
                                          color: Colors.grey[200],
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: order.items![index].itemImageURL != null
                                                ? CachedNetworkImage(
                                              imageUrl: '${order.items![index].itemImageURL}',
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.grey[100]!,
                                                child: Center(
                                                  child: Icon(
                                                    PhosphorIcons.image(
                                                        PhosphorIconsStyle.fill),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      PhosphorIcons.imageBroken(
                                                          PhosphorIconsStyle.fill),
                                                      color: Colors.grey,
                                                      size: 48,
                                                    ),
                                                  ),
                                            )
                                                : Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                PhosphorIcons.imageBroken(
                                                    PhosphorIconsStyle.fill),
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '₱ ${order.items![index].itemPrice!.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' x ${order.items![index].itemQnty}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            '₱ ${order.items![index].itemTotal!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
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
                    children: [
                      LoadingAnimationWidget.waveDots(
                          color: Colors.blue, size: 48),
                      const Text('Looking for new delivery'),
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
