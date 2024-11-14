import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StorePickupScreen2 extends StatefulWidget {
  StorePickupScreen2({
    super.key,
    this.orderDetail,
  });

  final NewOrder? orderDetail;

  @override
  State<StorePickupScreen2> createState() => _StorePickupScreen2State();
}

class _StorePickupScreen2State extends State<StorePickupScreen2> {
  late NewOrder? orderListen;

  @override
  void initState() {
    super.initState();
    // Initialize order with the value from widget.orderDetail
    orderListen = widget.orderDetail;
  }

  BuildContext? loadingDialogContext;

  String orderDateRead() {
    DateTime orderTimeRead = widget.orderDetail!.orderTime!.toDate();

    String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderTimeRead);
    return formattedOrderTime;
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
        'orderStatus': 'Rider found! Picking the order from the store',
        'riderID': sharedPreferences!.getString('uid'),
        'riderName': sharedPreferences!.getString('name'),
        'riderPhone': sharedPreferences!.getString('phone'),
      });

      // Close the loading dialog
      Navigator.of(context).pop();

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 2, inProgressScreenIndex: 0)));

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

  void _requestPickupConfirmation() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          return const LoadingDialog(message: "Requesting confirmation from the store");
        }
    );

  }

  void showDialogPickUp() {
    // if(loadingDialogContext != null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingDialogContext = context;

        if(orderListen!.orderStatus == 'Assigned'){
          return AlertDialog(
            title: const Text('Start Pickup Route?'),
            content: const Text(
              'You’re about to start the route to pick up the order. Follow the directions to the store for pickup.'
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
                    onPressed: () {},
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
        }

        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text(
                "Requesting confirmation from the store, please wait...",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      },
    );
  }

  void closeLoadingDialog() {
    if (loadingDialogContext != null) {
      Navigator.of(loadingDialogContext!).pop();
      loadingDialogContext = null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline_outlined),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }

              if (snapshot.hasError) {
                // Show a SnackBar when there's an error
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${snapshot.error}')),
                  );
                });
                return SizedBox(); // Return an empty widget as a placeholder
              }

              NewOrder order = NewOrder.fromJson(snapshot.data!.data() as Map<String, dynamic>);
              orderListen = NewOrder.fromJson(snapshot.data!.data() as Map<String, dynamic>);

              if (order.orderStatus == 'Picked up') {
                closeLoadingDialog();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) {
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.green,
                                size: 50,
                              ),
                              SizedBox(height: 20,),
                              Text(
                                "Pick up request confirmed. You may now deliver the order to the customer",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  });
                });

                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 2, inProgressScreenIndex: 1)));
                });
              }

              return SingleChildScrollView(
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
                                      '${order.orderStatus}',
                                      style:const TextStyle(
                                        fontSize: 14,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Rider(You) text
                              const Text(
                                'Rider(You)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //Rider Icon, Name, and Phone
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Rider Icon
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
                                  //Rider name, conditional
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
                                  //Rider phone number, conditional
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
                              leading: SizedBox(
                                height: 50,
                                width: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
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
            onPressed: showDialogPickUp,
            child: Text(
              widget.orderDetail!.orderStatus == 'Assigned'
              ? 'Start Pickup'
              : widget.orderDetail!.orderStatus == 'Picking up'
              ? 'Request Pickup Confirmation' : '',
              style: const TextStyle(
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
