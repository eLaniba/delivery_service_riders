
// 🔢 Named wrapper models
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/chat.dart';
import 'package:delivery_service_riders/models/new_order.dart';

class NewDeliveryOrders {
  final List<NewOrder> orders;
  NewDeliveryOrders(this.orders);
}

class InProgressCount {
  final int count;
  InProgressCount(this.count);
}


class NotificationCount{
  final int count;
  NotificationCount(this.count);
}

class MessageCount {
  final int count;
  MessageCount(this.count);
}

class StoreMessageCount {
  final int count;
  StoreMessageCount(this.count);
}

class UserMessageCount {
  final int count;
  UserMessageCount(this.count);
}

class BadgeProvider {
  static final uid = sharedPreferences!.getString('uid');

  static Stream<NewDeliveryOrders> newDeliveryOrdersStream() {
    return firebaseFirestore
        .collection('active_orders')
        .where('orderStatus', isEqualTo: 'Waiting')
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        NewDeliveryOrders(snapshot.docs.map((doc) => NewOrder.fromJson(doc.data())).toList()));
  }

  static Stream<InProgressCount> inProgressOrderCountStream() {
    return firebaseFirestore
        .collection('active_orders')
        .where('riderID', isEqualTo: uid)
        .where('orderStatus', whereNotIn: [
          'Pending',
          'Preparing',
          'Waiting',
          'Cancelled',
          'Completed',
        ])
        .snapshots()
        .map((snapshot) => InProgressCount(snapshot.docs.length));
  }

  static Stream<NotificationCount> unreadNotificationCountStream() {
    return firebaseFirestore
        .collection('riders')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => NotificationCount(snapshot.docs.length));
  }

  static Stream<MessageCount> unreadMessagesCountStream() {
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unread = data['unreadCount'] ?? {};
        if (unread[uid] != null && unread[uid] > 0) {
          count++;
        }
      }
      return MessageCount(count);
    });
  }

  static Stream<StoreMessageCount> storeUnreadMessageStream() {
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();
      final storeChats = chats.where((chat) =>
      chat.partnerRoleFor?[uid] == 'store' &&
          (chat.unreadCount?[uid] ?? 0) > 0);
      return StoreMessageCount(storeChats.length);
    });
  }

  static Stream<UserMessageCount> userUnreadMessageStream() {
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();
      final userChats = chats.where((chat) =>
      chat.partnerRoleFor?[uid] == 'user' &&
          (chat.unreadCount?[uid] ?? 0) > 0);
      return UserMessageCount(userChats.length);
    });
  }

}
