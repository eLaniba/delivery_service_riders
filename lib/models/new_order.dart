import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/models/add_to_cart_item.dart';

class NewOrder{
  //Order Information
  String? orderStatus;
  String? orderID;
  Timestamp? orderTime;
  Timestamp? orderDelivered;
  String? paymentMethod;
  double? riderFee;
  double? serviceFee;
  double? subTotal;
  double? orderTotal;

  //Store information
  String? storeProfileURL;
  String? storeID;
  String? storeName;
  String? storePhone;
  String? storeAddress;
  bool? storeConfirmDelivery;
  GeoPoint? storeLocation;

  //Items
  List<AddToCartItem>? items;

  //User Information
  String? userProfileURL;
  String? userID;
  String? userName;
  String? userPhone;
  String? userAddress;
  bool? userConfirmDelivery;
  GeoPoint? userLocation;

  //Rider information
  String? riderProfileURL;
  String? riderID;
  String? riderName;
  String? riderPhone;
  bool? riderConfirmDelivery;
  GeoPoint? riderLocation;

  //Constructor for Order
  NewOrder({
    //Order Information
    this.orderStatus,
    this.orderID,
    this.orderTime,
    this.orderDelivered,
    this.paymentMethod,
    this.riderFee,
    this.serviceFee,
    this.subTotal,
    this.orderTotal,

    //Store information
    this.storeProfileURL,
    this.storeID,
    this.storeName,
    this.storePhone,
    this.storeAddress,
    this.storeConfirmDelivery,
    this.storeLocation,

    this.items,

    //User Information
    this.userProfileURL,
    this.userID,
    this.userName,
    this.userPhone,
    this.userAddress,
    this.userConfirmDelivery,
    this.userLocation,

    //Rider information
    this.riderProfileURL,
    this.riderID,
    this.riderName,
    this.riderPhone,
    this.riderConfirmDelivery,
    this.riderLocation,
  });

  double calculateOrderTotal(List<AddToCartItem>? items) {
    double total = 0;
    for(var item in items!) {
      total += item.itemTotal!;
    }
    orderTotal = total;
    return total;
  }

  NewOrder.fromJson(Map<String, dynamic> json) {
    orderStatus = json['orderStatus'];
    orderID = json['orderID'];
    orderTime = json['orderTime'];
    orderDelivered = json['orderDelivered'];
    paymentMethod = json['paymentMethod'];
    riderFee = json['riderFee'];
    serviceFee = json['serviceFee'];
    subTotal = json['subTotal'];
    orderTotal = json['orderTotal'];

    storeProfileURL = json['storeProfileURL'];
    storeID = json['storeID'];
    storeName = json['storeName'];
    storePhone = json['storePhone'];
    storeAddress = json['storeAddress'];
    storeConfirmDelivery = json['storeConfirmDelivery'];
    storeLocation = json['storeLocation'];

    if (json['items'] != null) {
      items = List<AddToCartItem>.from(json['items'].map((item) => AddToCartItem.fromJson(item)));
    }

    userProfileURL = json['userProfileURL'];
    userID = json['userID'];
    userName = json['userName'];
    userPhone = json['userPhone'];
    userAddress = json['userAddress'];
    userConfirmDelivery = json['userConfirmDelivery'];
    userLocation = json['userLocation'];

    riderProfileURL = json['riderProfileURL'];
    riderID = json['riderID'];
    riderName = json['riderName'];
    riderPhone = json['riderPhone'];
    riderConfirmDelivery = json['riderConfirmDelivery'];
    riderLocation = json['riderLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderStatus'] = orderStatus;
    data['orderID'] = orderID;
    data['orderTime'] = orderTime;
    data['orderDelivered'] = orderDelivered;
    data['paymentMethod'] = paymentMethod;
    data['riderFee'] = riderFee;
    data['serviceFee'] = serviceFee;
    data['subTotal'] = subTotal;
    data['orderTotal'] = orderTotal;

    data['storeProfileURL'] = storeProfileURL;
    data['storeID'] = storeID;
    data['storeName'] = storeName;
    data['storePhone'] = storePhone;
    data['storeAddress'] = storeAddress;
    data['storeConfirmDelivery'] = storeConfirmDelivery;
    data['storeLocation'] = storeLocation;

    if (items != null) {
      data['items'] = items!.map((item) => item.toJson()).toList();
    }

    data['userProfileURL'] = userProfileURL;
    data['userID'] = userID;
    data['userName'] = userName;
    data['userPhone'] = userPhone;
    data['userAddress'] = userAddress;
    data['userConfirmDelivery'] = userConfirmDelivery;
    data['userLocation'] = userLocation;

    data['riderProfileURL'] = riderProfileURL;
    data['riderID'] = riderID;
    data['riderName'] = riderName;
    data['riderPhone'] = riderPhone;
    data['riderConfirmDelivery'] = riderConfirmDelivery;
    data['riderLocation'] = riderLocation;

    return data;
  }

}