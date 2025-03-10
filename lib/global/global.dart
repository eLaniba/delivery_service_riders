import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;

//Colors temporary
Color white80 = const Color.fromARGB(255, 238, 238, 238);
Color white70 = const Color.fromARGB(255, 224, 224, 224);
Color grey50 = const Color.fromARGB(255, 189, 195, 199);
Color grey20 = const Color.fromARGB(255, 151, 154, 154);

//From Figma
Color gray = const Color.fromARGB(255, 142, 142, 147);
Color gray5 = const Color.fromARGB(255, 229, 229, 234);

String apiKey = 'AIzaSyDN4P2wLPNtH9NqROqux8NVc2XaHGViO2U';

//Color Blue #2196f3 for UnDraw

List<String> savedPickedUpOrderPop = [];
List<String> savedDeliveredOrderPop = [];

//Picked up Popup
void addOrderToPickedUpPop(String orderID) async {
  if (!savedPickedUpOrderPop.contains(orderID)) {
    savedPickedUpOrderPop.add(orderID); // Add new order
    await savePickedUpOrderPop(savedPickedUpOrderPop); // Save updated list
  }
}
Future<void> savePickedUpOrderPop(List<String> orderID) async {
  await sharedPreferences!.setStringList('pickedUpOrderPop', orderID);
}
Future<List<String>> loadPickedUpOrdersPop() async {
  return sharedPreferences!.getStringList('pickedUpOrderPop') ?? [];
}

//Delivered Popup
void addOrderToDeliveredPop(String orderID) async {
  if (!savedDeliveredOrderPop.contains(orderID)) {
    savedDeliveredOrderPop.add(orderID); // Add new order
    await saveDeliveredOrderPop(savedDeliveredOrderPop); // Save updated list
  }
}
Future<void> saveDeliveredOrderPop(List<String> orderID) async {
  await sharedPreferences!.setStringList('deliveredOrderPop', orderID);
}
Future<List<String>> loadDeliveredOrdersPop() async {
  return sharedPreferences!.getStringList('deliveredOrderPop') ?? [];
}