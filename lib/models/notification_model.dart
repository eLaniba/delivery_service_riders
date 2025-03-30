import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? notificationID;
  String? title;
  String? body;
  String? orderID;
  String? type;
  bool? read;
  Timestamp? timestamp;

  NotificationModel({
    this.notificationID,
    this.title,
    this.body,
    this.orderID,
    this.type,
    this.read,
    this.timestamp,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationID = json['notificationID'];
    title = json['title'];
    body = json['body'];
    orderID = json['orderID'];
    type = json['type'];
    read = json['read'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['notificationID'] = notificationID;
    data['title'] = title;
    data['body'] = body;
    data['orderID'] = orderID;
    data['type'] = type;
    data['read'] = read;
    data['timestamp'] = timestamp;
    return data;
  }
}
