import 'package:intl/intl.dart';

String orderDateRead(DateTime orderDateTime) {
  String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderDateTime);
  return formattedOrderTime;
}