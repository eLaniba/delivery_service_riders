import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/models/add_to_cart_item.dart';

class NewOrder{
  //Order Information
  String? orderStatus;
  String? orderID;
  int? prepDuration;
  Timestamp? prepStartTime;
  Timestamp? orderTime;
  Timestamp? orderDelivered;
  String? paymentMethod;
  double? riderFee;
  double? serviceFee;
  double? subTotal;
  double? orderTotal;

  //Store information
  String? storeStatus;
  Timestamp? storeDelivered;
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
  String? userStatus;
  Timestamp? userDelivered;
  String? userProfileURL;
  String? userID;
  String? userName;
  String? userPhone;
  String? userAddress;
  bool? userConfirmDelivery;
  GeoPoint? userLocation;
  bool? userModify;


  //Rider information
  bool? riderStoreDelivered;
  bool? riderUserDelivered;
  String? riderProfileURL;
  String? riderID;
  String? riderName;
  String? riderPhone;
  GeoPoint? riderLocation;

  bool? rate;

  //Constructor for Order
  NewOrder({
    //Order Information
    this.orderStatus,
    this.orderID,
    this.prepDuration,
    this.prepStartTime,
    this.orderTime,
    this.orderDelivered,
    this.paymentMethod,
    this.riderFee,
    this.serviceFee,
    this.subTotal,
    this.orderTotal,

    //Store information
    this.storeStatus,
    this.storeDelivered,
    this.storeProfileURL,
    this.storeID,
    this.storeName,
    this.storePhone,
    this.storeAddress,
    this.storeConfirmDelivery,
    this.storeLocation,

    this.items,

    //User Information
    this.userStatus,
    this.userDelivered,
    this.userProfileURL,
    this.userID,
    this.userName,
    this.userPhone,
    this.userAddress,
    this.userConfirmDelivery,
    this.userLocation,

    //Rider information
    this.riderStoreDelivered,
    this.riderUserDelivered,
    this.riderProfileURL,
    this.riderID,
    this.riderName,
    this.riderPhone,
    this.riderLocation,
    this.rate,
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
    prepDuration = json['prepDuration'];
    prepStartTime = json['prepStartTime'];
    orderTime = json['orderTime'];
    orderDelivered = json['orderDelivered'];
    paymentMethod = json['paymentMethod'];
    riderFee = json['riderFee'];
    serviceFee = json['serviceFee'];
    subTotal = json['subTotal'];
    orderTotal = json['orderTotal'];

    storeStatus = json['storeStatus'];
    storeDelivered = json['storeDelivered'];
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

    userStatus = json['userStatus'];
    userDelivered = json['userDelivered'];
    userProfileURL = json['userProfileURL'];
    userID = json['userID'];
    userName = json['userName'];
    userPhone = json['userPhone'];
    userAddress = json['userAddress'];
    userConfirmDelivery = json['userConfirmDelivery'];
    userLocation = json['userLocation'];
    userModify = json['userModify'];

    riderStoreDelivered = json['riderStoreDelivered'];
    riderUserDelivered = json['riderUserDelivered'];
    riderProfileURL = json['riderProfileURL'];
    riderID = json['riderID'];
    riderName = json['riderName'];
    riderPhone = json['riderPhone'];
    riderLocation = json['riderLocation'];

    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderStatus'] = orderStatus;
    data['orderID'] = orderID;
    data['prepDuration'] = prepDuration;
    data['prepStartTime'] = prepStartTime;
    data['orderTime'] = orderTime;
    data['orderDelivered'] = orderDelivered;
    data['paymentMethod'] = paymentMethod;
    data['riderFee'] = riderFee;
    data['serviceFee'] = serviceFee;
    data['subTotal'] = subTotal;
    data['orderTotal'] = orderTotal;

    data['storeStatus'] = storeStatus;
    data['storeDelivered'] = storeDelivered;
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

    data['userStatus'] = userStatus;
    data['userDelivered'] = userDelivered;
    data['userProfileURL'] = userProfileURL;
    data['userID'] = userID;
    data['userName'] = userName;
    data['userPhone'] = userPhone;
    data['userAddress'] = userAddress;
    data['userConfirmDelivery'] = userConfirmDelivery;
    data['userLocation'] = userLocation;
    data['userModify'] = userModify;

    data['riderStoreDelivered'] = riderStoreDelivered;
    data['riderUserDelivered'] = riderUserDelivered;
    data['riderProfileURL'] = riderProfileURL;
    data['riderID'] = riderID;
    data['riderName'] = riderName;
    data['riderPhone'] = riderPhone;
    data['riderLocation'] = riderLocation;

    data['rate'] = rate;

    return data;
  }

}