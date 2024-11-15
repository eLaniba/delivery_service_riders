import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/new_order.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LiveLocationTrackingPage2 extends StatefulWidget {
  final NewOrder order;

  const LiveLocationTrackingPage2({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _LiveLocationTrackingPage2State createState() =>
      _LiveLocationTrackingPage2State();
}

class _LiveLocationTrackingPage2State extends State<LiveLocationTrackingPage2> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  Marker? _storeMarker;
  Marker? _userMarker;
  Marker? _currentLocationMarker;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

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
    _setMarkers();
    _getCurrentLocation();
    _createPolylines();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);

    if (_currentPosition != null) {
      _centerCameraOnAllLocations();
    }
  }

  void _setMarkers() {
    _storeMarker = Marker(
      markerId: MarkerId('store'),
      position: LatLng(widget.order.storeLocation!.latitude,
          widget.order.storeLocation!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _userMarker = Marker(
      markerId: MarkerId('user'),
      position: LatLng(widget.order.userLocation!.latitude,
          widget.order.userLocation!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _currentLocationMarker = Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      });

      _updateLocationInFirestore(position);
      _centerCameraOnAllLocations();
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    FirebaseFirestore.instance
        .collection('active_orders')
        .doc(widget.order.storeID)
        .update({
      'riderLocation': GeoPoint(position.latitude, position.longitude),
    }).catchError((error) {
      print("Failed to update location: $error");
    });
  }

  Future<void> _createPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(widget.order.storeLocation!.latitude,
          widget.order.storeLocation!.longitude),
      PointLatLng(widget.order.userLocation!.latitude,
          widget.order.userLocation!.longitude),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyline();
    } else {
      print("Failed to fetch route: ${result.errorMessage}");
    }
  }

  void _addPolyline() {
    PolylineId id = PolylineId('polyline');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      width: 4,
      points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  void _centerCameraOnAllLocations() {
    if (_currentPosition == null) return;

    LatLng storeLocation = LatLng(widget.order.storeLocation!.latitude,
        widget.order.storeLocation!.longitude);
    LatLng userLocation = LatLng(widget.order.userLocation!.latitude,
        widget.order.userLocation!.longitude);
    LatLng currentLocation =
    LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        [storeLocation.latitude, userLocation.latitude, currentLocation.latitude]
            .reduce((a, b) => a < b ? a : b),
        [storeLocation.longitude, userLocation.longitude, currentLocation.longitude]
            .reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        [storeLocation.latitude, userLocation.latitude, currentLocation.latitude]
            .reduce((a, b) => a > b ? a : b),
        [storeLocation.longitude, userLocation.longitude, currentLocation.longitude]
            .reduce((a, b) => a > b ? a : b),
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracking'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 10,
        ),
        markers: {
          if (_storeMarker != null) _storeMarker!,
          if (_userMarker != null) _userMarker!,
          if (_currentLocationMarker != null) _currentLocationMarker!,
        },
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
