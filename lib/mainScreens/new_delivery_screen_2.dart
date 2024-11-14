import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/inProgressScreens/in_progress_main_screen.dart';
import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/services/geopoint_json.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewDeliveryScreen2 extends StatefulWidget {
  NewDeliveryScreen2({
    super.key,
    this.orderDetail,
  });

  NewOrder? orderDetail;

  @override
  State<NewDeliveryScreen2> createState() => _NewDeliveryScreenState();
}

class _NewDeliveryScreenState extends State<NewDeliveryScreen2> {
  String orderDateRead() {
    DateTime orderTimeRead = widget.orderDetail!.orderTime!.toDate();

    String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderTimeRead);
    return formattedOrderTime;
  }

  //Popup Note
  void showDialogNote() {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Accept Order?'),
        content: const Text(
          'You are about to accept this order. Once you are successfully assigned as the rider, please proceed to the store.',
          // textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss dialog on Cancel
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 20,),
              ElevatedButton(
                onPressed: _acceptOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 40,
                    child: Center(child: Text('Ok')),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _acceptOrder() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(message: "Accepting order");
        }
    );

    DocumentReference orderDocument = FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}');

    try {
      await orderDocument.update({
        'orderStatus': 'Assigned',
        'riderID': sharedPreferences!.getString('uid'),
        'riderName': sharedPreferences!.getString('name'),
        'riderPhone': sharedPreferences!.getString('phone'),
        'riderConfirmDelivery': false,
        'riderLocation': parseGeoPointFromJson(sharedPreferences!.getString('location').toString()),
      });

      // Close the loading dialog
      Navigator.of(context).pop();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 2, inProgressScreenIndex: 0)));

      // Show a success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order Accepted! Proceed to the store for pickup'),
          backgroundColor: Colors.blue, // Optional: Set background color
          duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );

    } catch (e) {
      Navigator.of(context).pop();

      // Show an error Snackbar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept order: $e'),
          backgroundColor: Colors.red, // Optional: Set background color for error
          duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if(!snapshot.hasData || !snapshot.data!.exists) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_shopping_cart_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                          Text(
                            'Error encounter, please try again',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          //Order Information
                          Container(
                            // height: 140,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Order Information Text
                                  const Text(
                                    'Order Information',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Order Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.circle,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${widget.orderDetail!.orderStatus}',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4,),
                                  //Order ID
                                  RichText(
                                    text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Order ID: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${widget.orderDetail!.orderID}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  const SizedBox(height: 4,),
                                  //Order Time
                                  RichText(
                                    text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Order time: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: orderDateRead(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  //Payment Method
                                  const Text(
                                    'Payment method',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Cash on Delivery
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Icon(Icons.payment_rounded),
                                      Text(
                                        ' Cash on Delivery',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8,),
                                  const DottedLine(
                                    dashColor: Colors.grey,
                                    lineThickness: 2,
                                    dashLength: 10,
                                    dashGapLength: 4,
                                    dashRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Store Information
                          Container(
                            // height: 180,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Order from Text
                                  const Text(
                                    'Order from',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Store Icon, Name, and Phone Number
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.storefront_outlined,
                                          // color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${widget.orderDetail!.storeName}',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${widget.orderDetail!.storePhone}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                  //Store Address
                                  Text(
                                    '${widget.orderDetail!.storeAddress}',
                                    style:const TextStyle(
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14,),
                                  const DottedLine(
                                    dashColor: Colors.grey,
                                    lineThickness: 2,
                                    dashLength: 10,
                                    dashGapLength: 4,
                                    dashRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //User Information
                          Container(
                            // height: 180,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Order from Text
                                  const Text(
                                    'Deliver to',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //User Icon, Name, and Phone Number
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.person_2_outlined,
                                          // color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${widget.orderDetail!.userName}',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${widget.orderDetail!.userPhone}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                  //Store Address
                                  Text(
                                    '${widget.orderDetail!.userAddress}',
                                    style:const TextStyle(
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14,),
                                  const DottedLine(
                                    dashColor: Colors.grey,
                                    lineThickness: 2,
                                    dashLength: 10,
                                    dashGapLength: 4,
                                    dashRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Rider Information
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    child: Icon(
                                      Icons.sports_motorsports_outlined,
                                      // color: Colors.orange,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Flexible(
                                    child: Text(
                                      widget.orderDetail!.riderID != null
                                          ? '${widget.orderDetail!.riderName}'
                                          : 'Processing...',
                                      style:const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),

                                  if (widget.orderDetail!.riderID != null)
                                    Text(
                                      '${widget.orderDetail!.riderPhone}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  else
                                    const Text(''),
                                ],
                              ),
                            ),
                          ),
                          //Item(s) text
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: const Row(
                              children: [
                                Text(
                                  'Item(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Fixed Height ListView.builder
                          Container(
                            padding: const EdgeInsets.only(bottom: 24),
                            height: 250,
                            color: Colors.white,
                            child: ListView.builder(
                              itemCount: widget.orderDetail!.items!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.orderDetail!.items![index].itemName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '₱ ${widget.orderDetail!.items![index].itemPrice!.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '₱ ${widget.orderDetail!.items![index].itemTotal!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const DottedLine(),
                                    ],
                                  ),
                                  trailing: Text(
                                    'x${widget.orderDetail!.items![index].itemQnty}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Total Order: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: "₱${widget.orderDetail!.orderTotal!.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                    ),
                  ),
                  const SizedBox(width: 16,),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Colors.black,
          child: TextButton(
            onPressed: () {
              //cod here
              showDialogNote();
            },
            child: const Text(
              'Accept Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
