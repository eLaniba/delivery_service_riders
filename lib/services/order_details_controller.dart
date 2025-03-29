import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/main_screen_provider.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:delivery_service_riders/sample_features/live_location_tracking_page.dart';
import 'package:delivery_service_riders/sample_features/live_location_tracking_page_2.dart';
import 'package:delivery_service_riders/services/geopoint_json.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

BuildContext? confirmLoadingDialogContext;

String buttonTitle(String orderStatus) {
  if(orderStatus == 'Waiting') {
    return 'Accept Order';
  } else if(orderStatus == 'Assigned') {
    return 'Start Pickup Route';
  } else if(orderStatus == 'Picking up') {
    return 'Request Pickup Confirmation';
  } else if(orderStatus == 'Picked up') {
    return 'Start Delivery Route';
  } else if(orderStatus == 'Delivering') {
    return 'Request Delivery Confirmation';
  } else if(orderStatus == 'Delivered') {
    return 'Start Store Route';
  } else {
    return 'Complete Order';
  }
}
String orderDialogTitle(String orderStatus) {
  if(orderStatus == 'Waiting') {
    return 'Accept Order?';
  } else if(orderStatus == 'Assigned') {
    return 'Start Pickup Route?';
  } else if(orderStatus == 'Picking up') {
    return 'Request Pickup Confirmation';
  } else if(orderStatus == 'Picked up') {
    return 'Start Delivery Route?';
  } else if(orderStatus == 'Delivering') {
    return 'Request Delivery Confirmation?';
  } else if(orderStatus == 'Delivered') {
    return 'Start Store Route?';
  } else if(orderStatus == 'Completing') {
    return 'Complete Order?';
  }

  else {
    return 'Complete Order';
  }
}
String orderDialogContent(String orderStatus) {
  if(orderStatus == 'Waiting') {
    return 'You are about to accept this order. Once you are successfully assigned as the rider, please proceed to the store.';
  } else if(orderStatus == 'Assigned') {
    return 'You’re about to start the route to pick up the order. Follow the directions to the store for pickup.';
  } else if(orderStatus == 'Picking up') {
    return 'Request Pickup Confirmation';
  } else if(orderStatus == 'Picked up') {
    return 'You’re about to start the route to deliver the order to the customer. Follow the directions to deliver it to the customer’s address.';
  } else if(orderStatus == 'Delivering') {
    return "By pressing this button, you confirm that the customer has paid and received the items from the rider. \n\nPlease ensure all transactions are completed before confirming.";
  } else if(orderStatus == 'Delivered') {
    return 'You’re about to start the route back to the store. Follow the directions to deliver the payment to the store.';
  } else if(orderStatus == 'Completing') {
    return "By pressing this button, you confirm that you have successfully delivered the order to the customer and that the store owner has paid you for your delivery service.\n\nPlease ensure all transactions are completed before confirming.";
  }

  else {
    return 'Complete Order';
  }
}

orderDetailsController({required BuildContext context, required NewOrder order}) async {
  //If orderStatus == 'Waiting', perform this operation
  if(order.orderStatus == 'Waiting') {
    bool result = await orderDialog(
      context: context,
      title: orderDialogTitle(order.orderStatus!),
      content: orderDialogContent(order.orderStatus!),
      action: 'Accept',
    );
    if(result) {
      //Show Loading Dialog
      showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(message: 'Accepting order',);
        }
      );
      _acceptOrder(context, order);
    }
  } else if(order.orderStatus == 'Assigned') {
    bool result = await orderDialog(
      context: context,
      title: orderDialogTitle(order.orderStatus!),
      content: orderDialogContent(order.orderStatus!),
      action: 'Ok',
    );
    if(result) {
      //Show Loading Dialog
      showDialog(
          context: context,
          builder: (c) {
            return const LoadingDialog(message: 'Starting route',);
          }
      );
      _startPickupRoute(context, order);
    }
  } else if(order.orderStatus == 'Picking up') {
    confirmLoadingDialog(
      context: context,
      message: 'Requesting confirmation from the store',
    );
  } else if(order.orderStatus == 'Picked up') {
    if(!savedPickedUpOrderPop.contains(order.orderID)) {
      addOrderToPickedUpPop(order.orderID!);

      //Close the confirmLoadingDialog from 'Picking up' state
      closeConfirmLoadingDialog();

      //Show Confirm Success Dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          confirmSuccessDialog(
            context: context,
            message: "Pick up request confirmed. You may now deliver the order to the customer.",
          );
        });

        // Navigate to Start Delivery Page
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreenProvider(mainScreenIndex: 1, inProgressScreenIndex: 1)));
          // Navigator.of(context).pop();
        });
      });
    } else {
      bool result = await orderDialog(
        context: context,
        title: orderDialogTitle(order.orderStatus!),
        content: orderDialogContent(order.orderStatus!),
        action: 'Ok',
      );
      if(result) {
        //Show Loading Dialog
        showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(message: 'Starting route',);
            }
        );
        _startDeliveryRoute(context, order);
      }
    }
  } else if(order.orderStatus == 'Delivering') {
    bool result = await orderDialog(
      context: context,
      title: orderDialogTitle(order.orderStatus!),
      content: orderDialogContent(order.orderStatus!),
      action: 'Confirm',
    );
    if(result) {
      confirmLoadingDialog(
        context: context,
        message: "Requesting confirmation from the customer",
      );
      _requestDeliveryConfirmation(context, order);
    }
  } else if(order.orderStatus == 'Delivered') {
    if(!savedDeliveredOrderPop.contains(order.orderID)) {
      addOrderToDeliveredPop(order.orderID!);

      //Close the confirmLoadingDialog from 'Picking up' state
      closeConfirmLoadingDialog();

      //Show Confirm Success Dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          confirmSuccessDialog(
            context: context,
            message: "Customer delivery confirmed. Return to the store to complete the order.",
          );
        });

        // Navigate to Start Delivery Page
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreenProvider(mainScreenIndex: 1, inProgressScreenIndex: 2)));
          // Navigator.of(context).pop();
        });
      });
    } else {
      bool result = await orderDialog(
        context: context,
        title: orderDialogTitle(order.orderStatus!),
        content: orderDialogContent(order.orderStatus!),
        action: 'Ok',
      );
      if(result) {
        //Show Loading Dialog
        showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(message: 'Starting route',);
            }
        );
        _startCompletingRoute(context, order);
      }
    }
  } else if(order.orderStatus == 'Completing') {
    bool result = await orderDialog(
      context: context,
      title: orderDialogTitle(order.orderStatus!),
      content: orderDialogContent(order.orderStatus!),
      action: 'Confirm',
    );
    if(result) {
      confirmLoadingDialog(
        context: context,
        message: "Completing order",
      );
      _startCompletingOrder(context, order);
    }
  } else if(order.orderStatus == 'Completed') {
    //Close the confirmLoadingDialog from 'Picking up' state
    closeConfirmLoadingDialog();

    //Show Confirm Success Dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        confirmSuccessDialog(
          context: context,
          message: "The order is complete. Thank you for your excellent service!",
        );
      });

      // Navigate to Start Delivery Page
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreenProvider(mainScreenIndex: 1, inProgressScreenIndex: 2)));
        // Navigator.of(context).pop();
      });
    });
  }
}

Future<bool> orderDialog({required BuildContext context, required String title, required String content, required String action}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false for Cancel
                },
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 25),
              // Confirm
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true for Confirm
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Center(
                  child: SizedBox(
                    width: 56,
                    child: Center(child: Text(action)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<void> confirmLoadingDialog({required BuildContext context, required String message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      confirmLoadingDialogContext = context;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16,),
            const CircularProgressIndicator(),
            const SizedBox(height: 18,),
            Text(
              '$message, please wait...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}
void closeConfirmLoadingDialog() {
  if (confirmLoadingDialogContext != null) {
    Navigator.of(confirmLoadingDialogContext!).pop();
    confirmLoadingDialogContext = null;
  }
}
Future<void> confirmSuccessDialog({required BuildContext context, required String message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 18,),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

// void _acceptOrder(BuildContext context, NewOrder order) async {
//   DocumentReference orderDocument = firebaseFirestore
//       .collection('active_orders')
//       .doc('${order.orderID}');
//
//   try {
//     await orderDocument.update({
//       'orderStatus': 'Assigned',
//       'riderID': sharedPreferences!.getString('uid'),
//       'riderName': sharedPreferences!.getString('name'),
//       'riderPhone': sharedPreferences!.getString('phone'),
//       'riderConfirmDelivery': false,
//       'riderLocation': parseGeoPointFromJson(sharedPreferences!.getString('location').toString()),
//     });
//
//     // Close the loading dialog
//     Navigator.of(context).pop();
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 2, inProgressScreenIndex: 0)));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Order Accepted! Proceed to the store for pickup'),
//             backgroundColor: Colors.blue, // Optional: Set background color
//             duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
//           ),
//         );
//       });
//     });
//   }catch(e) {
//     // Close the loading dialog
//     Navigator.of(context).pop();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to accept order: $e'),
//             backgroundColor: Colors.red, // Optional: Set background color for error
//             duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
//           ),
//         );
//       });
//     });
//   }
// }

void _acceptOrder(BuildContext context, NewOrder order) async {
  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try {
    await firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(orderDocument);

      // Check if the order is still available
      if (snapshot.get('orderStatus') != 'Waiting') {
        throw Exception('Order already accepted');
      }

      transaction.update(orderDocument, {
        'orderStatus': 'Assigned',
        'riderProfileURL': sharedPreferences!.getString('profileURL'),
        'riderID': sharedPreferences!.getString('uid'),
        'riderName': sharedPreferences!.getString('name'),
        'riderPhone': sharedPreferences!.getString('phone'),
        'riderConfirmDelivery': false,
        'riderLocation': parseGeoPointFromJson(sharedPreferences!.getString('location').toString()),
      });
    });

    // Continue with success actions...
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreenProvider(mainScreenIndex: 1, inProgressScreenIndex: 0)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Accepted! Proceed to the store for pickup'),
            backgroundColor: Colors.green, // Optional: Set background color
            duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });

  } catch (e) {
    //Close loading dialog
    Navigator.of(context).pop();

    if(e.toString().contains('Order already accepted')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order already assigned by another rider'),
          backgroundColor: Colors.red, // Optional: Set background color
          duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unknown error occurred, please try again'),
          backgroundColor: Colors.red, // Optional: Set background color
          duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );
    }
  }
}

void _requestDeliveryConfirmation(BuildContext context, NewOrder order) async {
  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try {
    await orderDocument.update({
      'riderConfirmDelivery': true,
    });

  }catch(e) {
    // Close the loading dialog
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept order: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });
  }
}
void _startPickupRoute(BuildContext context, NewOrder order) async {
  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try{
    await orderDocument.update({
      'orderStatus': 'Picking up',
    });

    // Close the loading dialog
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveLocationTrackingPage(
          order: order, // Example destination
        ),
      ),
    );
  } catch(e) {
    // Close the loading dialog
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept order: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });
  }
}
void _startDeliveryRoute(BuildContext context, NewOrder order) async {
  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try{
    await orderDocument.update({
      'orderStatus': 'Delivering',
    });

    // Close the loading dialog
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveLocationTrackingPage2(
          order: order, // Example destination
        ),
      ),
    );
  } catch(e) {
    // Close the loading dialog
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });
  }
}
void _startCompletingRoute(BuildContext context, NewOrder order) async {
  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try{
    await orderDocument.update({
      'orderStatus': 'Completing',
    });

    // Close the loading dialog
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveLocationTrackingPage2(
          order: order, // Example destination
        ),
      ),
    );
  } catch(e) {
    // Close the loading dialog
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept order: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });
  }
}
void _startCompletingOrder(BuildContext context, NewOrder order) async {
  DateTime now = DateTime.now();
  Timestamp orderDelivered = Timestamp.fromDate(now);

  DocumentReference orderDocument = firebaseFirestore
      .collection('active_orders')
      .doc('${order.orderID}');

  try{
    await orderDocument.update({
      'orderDelivered': orderDelivered,
    });

  } catch(e) {
    // Close the loading dialog
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close order: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      });
    });
  }
}
