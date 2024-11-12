import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// Function to convert GeoPoint to JSON string
String geoPointToJson(GeoPoint geoPoint) {
  if (geoPoint == null) {
    return '{}'; // Return an empty JSON object if the GeoPoint is null
  }
  return '{"latitude": ${geoPoint.latitude}, "longitude": ${geoPoint.longitude}}';
}

// Function to parse JSON string back to GeoPoint
GeoPoint parseGeoPointFromJson(String jsonString) {
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return GeoPoint(jsonMap['latitude'], jsonMap['longitude']);
}