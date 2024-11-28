// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:delivery_service_riders/global/global.dart';
// import 'package:delivery_service_riders/models/new_order.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// class LiveLocationTrackingPage extends StatefulWidget {
//   // final LatLng destination;
//   // final String orderId; // Add an orderId parameter to identify the order document
//   final NewOrder order;
//
//   const LiveLocationTrackingPage({
//     Key? key,
//     required this.order,
//   }) : super(key: key);
//
//   @override
//   _LiveLocationTrackingPageState createState() => _LiveLocationTrackingPageState();
// }
//
// class _LiveLocationTrackingPageState extends State<LiveLocationTrackingPage> {
//   late GoogleMapController mapController;
//   Position? _currentPosition;
//   Marker? _destinationMarker;
//   Marker? _currentLocationMarker;
//   PolylinePoints polylinePoints = PolylinePoints();
//   List<LatLng> polylineCoordinates = [];
//   Map<PolylineId, Polyline> polylines = {};
//
//   final String _mapStyle = '''
//   [
//     {
//       "featureType": "poi",
//       "stylers": [{"visibility": "off"}]
//     },
//     {
//       "featureType": "road",
//       "elementType": "labels",
//       "stylers": [{"visibility": "off"}]
//     },
//     {
//       "featureType": "transit",
//       "stylers": [{"visibility": "off"}]
//     },
//     {
//       "featureType": "administrative",
//       "stylers": [{"visibility": "off"}]
//     }
//   ]
//   ''';
//
//   @override
//   void initState() {
//     super.initState();
//     _setDestinationMarker();
//     _getCurrentLocation();
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     mapController.setMapStyle(_mapStyle);
//
//     if (_currentPosition != null) {
//       _centerCameraBetweenCoordinates();
//     }
//   }
//
//   void _setDestinationMarker() {
//     _destinationMarker = Marker(
//       markerId: MarkerId('destination'),
//       position: LatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     await Geolocator.requestPermission();
//     Geolocator.getPositionStream().listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//         _currentLocationMarker = Marker(
//           markerId: MarkerId('currentLocation'),
//           position: LatLng(position.latitude, position.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//         );
//         _createPolylines();
//       });
//
//       _centerCameraBetweenCoordinates();
//       _updateLocationInFirestore(position); // Update Firestore with the rider's location
//     });
//   }
//
//   // Update the Firestore document with the rider's current location as GeoPoint
//   Future<void> _updateLocationInFirestore(Position position) async {
//     FirebaseFirestore.instance.collection('active_orders').doc(widget.order.storeID).update({
//       'riderLocation': GeoPoint(position.latitude, position.longitude), // Use GeoPoint
//     }).catchError((error) {
//       print("Failed to update location: $error");
//     });
//   }
//
//   void _centerCameraBetweenCoordinates() {
//     if (_currentPosition == null) return;
//
//     // Calculate the midpoint between current location and destination
//     double midLat = (_currentPosition!.latitude + widget.order.storeLocation!.latitude) / 2;
//     double midLng = (_currentPosition!.longitude + widget.order.storeLocation!.longitude) / 2;
//     LatLng midpoint = LatLng(midLat, midLng);
//
//     // Calculate the bounds
//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(
//         _currentPosition!.latitude < widget.order.storeLocation!.latitude
//             ? _currentPosition!.latitude
//             : widget.order.storeLocation!.latitude,
//         _currentPosition!.longitude < widget.order.storeLocation!.longitude
//             ? _currentPosition!.longitude
//             : widget.order.storeLocation!.longitude,
//       ),
//       northeast: LatLng(
//         _currentPosition!.latitude > widget.order.storeLocation!.latitude
//             ? _currentPosition!.latitude
//             : widget.order.storeLocation!.latitude,
//         _currentPosition!.longitude > widget.order.storeLocation!.longitude
//             ? _currentPosition!.longitude
//             : widget.order.storeLocation!.longitude,
//       ),
//     );
//
//     mapController.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, 50), // 50 padding for a better view
//     );
//   }
//
//   Future<void> _createPolylines() async {
//     if (_currentPosition == null) return;
//
//     polylineCoordinates.clear();
//
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       apiKey,
//       PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//       PointLatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
//     );
//
//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//       _addPolyline();
//     } else {
//       print("Failed to fetch route: ${result.status}");
//     }
//   }
//
//   void _addPolyline() {
//     PolylineId id = PolylineId('poly');
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.blue,
//       width: 5,
//       points: polylineCoordinates,
//     );
//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Live Location Tracking'),
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: LatLng(0, 0), // Default initial position
//           zoom: 10,
//         ),
//         markers: {
//           if (_currentLocationMarker != null) _currentLocationMarker!,
//           if (_destinationMarker != null) _destinationMarker!,
//         },
//         polylines: Set<Polyline>.of(polylines.values),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//     );
//   }
// }

//Part 2, with dispose
import 'dart:async'; // Required for StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LiveLocationTrackingPage extends StatefulWidget {
  final NewOrder order;

  const LiveLocationTrackingPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _LiveLocationTrackingPageState createState() => _LiveLocationTrackingPageState();
}

class _LiveLocationTrackingPageState extends State<LiveLocationTrackingPage> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  Marker? _destinationMarker;
  Marker? _currentLocationMarker;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  StreamSubscription<Position>? _positionStreamSubscription; // Track the subscription

  final String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "administrative",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _setDestinationMarker();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);

    if (_currentPosition != null) {
      _centerCameraBetweenCoordinates();
    }
  }

  void _setDestinationMarker() {
    _destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return; // Check if widget is still in the tree
      setState(() {
        _currentPosition = position;
        _currentLocationMarker = Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
        _createPolylines();
      });

      _centerCameraBetweenCoordinates();
      _updateLocationInFirestore(position); // Update Firestore with the rider's location
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    FirebaseFirestore.instance.collection('active_orders').doc(widget.order.storeID).update({
      'riderLocation': GeoPoint(position.latitude, position.longitude), // Use GeoPoint
    }).catchError((error) {
      print("Failed to update location: $error");
    });
  }

  void _centerCameraBetweenCoordinates() {
    if (_currentPosition == null) return;

    // Calculate the midpoint between current location and destination
    double midLat = (_currentPosition!.latitude + widget.order.storeLocation!.latitude) / 2;
    double midLng = (_currentPosition!.longitude + widget.order.storeLocation!.longitude) / 2;

    // Calculate the bounds
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _currentPosition!.latitude < widget.order.storeLocation!.latitude
            ? _currentPosition!.latitude
            : widget.order.storeLocation!.latitude,
        _currentPosition!.longitude < widget.order.storeLocation!.longitude
            ? _currentPosition!.longitude
            : widget.order.storeLocation!.longitude,
      ),
      northeast: LatLng(
        _currentPosition!.latitude > widget.order.storeLocation!.latitude
            ? _currentPosition!.latitude
            : widget.order.storeLocation!.latitude,
        _currentPosition!.longitude > widget.order.storeLocation!.longitude
            ? _currentPosition!.longitude
            : widget.order.storeLocation!.longitude,
      ),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 padding for a better view
    );
  }

  Future<void> _createPolylines() async {
    if (_currentPosition == null) return;

    polylineCoordinates.clear();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyline();
    } else {
      print("Failed to fetch route: ${result.status}");
    }
  }

  void _addPolyline() {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      width: 5,
      points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracking'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target:  LatLng(0, 0), // Default initial position
          zoom: 10,
        ),
        markers: {
          if (_currentLocationMarker != null) _currentLocationMarker!,
          if (_destinationMarker != null) _destinationMarker!,
        },
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}


