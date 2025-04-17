import 'package:cloud_firestore/cloud_firestore.dart';

class Sales {
  double earnings;
  Timestamp orderCompleted;
  String orderID;
  String paymentMethod;
  double serviceCommission;
  double serviceFee;
  double serviceFeeTotal;

  Sales({
    required this.earnings,
    required this.orderCompleted,
    required this.orderID,
    required this.paymentMethod,
    required this.serviceCommission,
    required this.serviceFee,
    required this.serviceFeeTotal,
  });

    factory Sales.fromJson(Map<String, dynamic> json) {
      return Sales(
        earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
        orderCompleted: json['orderCompleted'] as Timestamp? ?? Timestamp.now(),
        orderID: json['orderID'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        serviceCommission: (json['serviceCommission'] as num?)?.toDouble() ?? 0.0,
        serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
        serviceFeeTotal: (json['serviceFeeTotal'] as num?)?.toDouble() ?? 0.0,
      );
    }

  Map<String, dynamic> toJson() {
    return {
      'earnings': earnings,
      'orderCompleted': orderCompleted,
      'orderID': orderID,
      'paymentMethod': paymentMethod,
      'serviceCommission': serviceCommission,
      'serviceFee': serviceFee,
      'serviceFeeTotal': serviceFeeTotal,
    };
  }
}
