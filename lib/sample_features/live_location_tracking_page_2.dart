import 'dart:async';
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
  _LiveLocationTrackingPage2State createState() => _LiveLocationTrackingPage2State();
}

class _LiveLocationTrackingPage2State extends State<LiveLocationTrackingPage2> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  Marker? _storeMarker;
  Marker? _userMarker;
  Marker? _currentLocationMarker;

  BitmapDescriptor? storeMarkerIcon;
  BitmapDescriptor? userMarkerIcon;
  BitmapDescriptor? currentLocationMarkerIcon;

  bool _isMarkerReady = false;
  bool _isDisposed = false;

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  StreamSubscription<Position>? _positionStreamSubscription;

  final String _mapStyle = '''
  [
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
    {"featureType": "road", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative", "stylers": [{"visibility": "off"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    try {
      storeMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/custom_icons/custom_store_marker.png',
      );
      userMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/custom_icons/custom_user_marker.png',
      );
      currentLocationMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/custom_icons/custom_rider_marker.png',
      );

      if (!_isDisposed) {
        setState(() => _isMarkerReady = true);
        _setMarkers();
        _getCurrentLocation();
      }
    } catch (e) {
      debugPrint("❌ Failed to load custom marker icons: $e");
    }
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
      markerId: const MarkerId('store'),
      position: LatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
      icon: storeMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _userMarker = Marker(
      markerId: const MarkerId('user'),
      position: LatLng(widget.order.userLocation!.latitude, widget.order.userLocation!.longitude),
      icon: userMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (_isDisposed) return;

      setState(() {
        _currentPosition = position;
        _currentLocationMarker = Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon: currentLocationMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
        _createPolylines();
      });

      _updateLocationInFirestore(position);
      _centerCameraOnAllLocations();
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('active_orders')
          .doc(widget.order.orderID)
          .update({
        'riderLocation': GeoPoint(position.latitude, position.longitude),
      });
    } catch (error) {
      debugPrint("Failed to update location: $error");
    }
  }

  Future<void> _createPolylines() async {
    if (_isDisposed) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude),
      PointLatLng(widget.order.userLocation!.latitude, widget.order.userLocation!.longitude),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyline();
    } else {
      debugPrint("Failed to fetch route: ${result.errorMessage}");
    }
  }

  void _addPolyline() {
    PolylineId id = const PolylineId('polyline');
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

  void _centerCameraOnAllLocations() {
    if (_currentPosition == null || _isDisposed) return;

    LatLng storeLocation = LatLng(widget.order.storeLocation!.latitude, widget.order.storeLocation!.longitude);
    LatLng userLocation = LatLng(widget.order.userLocation!.latitude, widget.order.userLocation!.longitude);
    LatLng currentLocation = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        [storeLocation.latitude, userLocation.latitude, currentLocation.latitude].reduce((a, b) => a < b ? a : b),
        [storeLocation.longitude, userLocation.longitude, currentLocation.longitude].reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        [storeLocation.latitude, userLocation.latitude, currentLocation.latitude].reduce((a, b) => a > b ? a : b),
        [storeLocation.longitude, userLocation.longitude, currentLocation.longitude].reduce((a, b) => a > b ? a : b),
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMarkerReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
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

          // Legend top-left
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendRow(
                    'assets/custom_icons/custom_store_marker.png',
                    'Store',
                  ),
                  const SizedBox(height: 8),
                  _buildLegendRow(
                    'assets/custom_icons/custom_user_marker.png',
                    'Customer',
                  ),
                  const SizedBox(height: 8),
                  _buildLegendRow(
                    'assets/custom_icons/custom_rider_marker.png',
                    'You',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String assetPath, String label) {
    return Row(
      children: [
        Image.asset(
          assetPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}
