
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/new_order.dart';

/// Wrapper classes to differentiate each stream


class StorePickupOrders {
  final List<NewOrder> orders;
  StorePickupOrders(this.orders);
}

class StartDeliveryOrders {
  final List<NewOrder> orders;
  StartDeliveryOrders(this.orders);
}

class CompletingDeliveryOrders {
  final List<NewOrder> orders;
  CompletingDeliveryOrders(this.orders);
}

class OrderStreamProvider {
  static final String? uid = sharedPreferences!.getString('uid');

  static Stream<StorePickupOrders> storePickupOrdersStream() {
    return firebaseFirestore
        .collection('active_orders')
        .where('riderID', isEqualTo: uid)
        .where('orderStatus', isEqualTo: 'Assigned')
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        StorePickupOrders(snapshot.docs.map((doc) => NewOrder.fromJson(doc.data())).toList()));
  }

  static Stream<StartDeliveryOrders> startDeliveryOrdersStream() {
    return firebaseFirestore
        .collection('active_orders')
        .where('riderID', isEqualTo: uid)
        .where('orderStatus', whereIn: [
          'Picked up',
          'Delivering',
        ])
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        StartDeliveryOrders(snapshot.docs.map((doc) => NewOrder.fromJson(doc.data())).toList()));
  }

  static Stream<CompletingDeliveryOrders> completingDeliveryOrdersStream() {
    return firebaseFirestore
        .collection('active_orders')
        .where('riderID', isEqualTo: uid)
        .where('orderStatus', whereIn: [
      'Delivered',
      'Completing',
    ])
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        CompletingDeliveryOrders(snapshot.docs.map((doc) => NewOrder.fromJson(doc.data())).toList()));
  }
}
