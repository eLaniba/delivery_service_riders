import 'dart:async';
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
  _LiveLocationTrackingPageState createState() =>
      _LiveLocationTrackingPageState();
}

class _LiveLocationTrackingPageState extends State<LiveLocationTrackingPage> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  Marker? _destinationMarker;
  Marker? _currentLocationMarker;

  BitmapDescriptor? destinationMarkerIcon;
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
      destinationMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/custom_icons/custom_store_marker.png',
      );
      currentLocationMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/custom_icons/custom_rider_marker.png',
      );

      if (!_isDisposed) {
        setState(() => _isMarkerReady = true);
        _setDestinationMarker();
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
      _centerCameraBetweenCoordinates();
    }
  }

  void _setDestinationMarker() {
    _destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(
        widget.order.storeLocation!.latitude,
        widget.order.storeLocation!.longitude,
      ),
      icon: destinationMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

      _centerCameraBetweenCoordinates();

      if (!_isDisposed) {
        _updateLocationInFirestore(position);
      }
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('active_orders')
          .doc(widget.order.storeID)
          .update({
        'riderLocation': GeoPoint(position.latitude, position.longitude),
      });
    } catch (error) {
      debugPrint("Failed to update location: $error");
    }
  }

  void _centerCameraBetweenCoordinates() {
    if (_currentPosition == null || _isDisposed) return;

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
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  Future<void> _createPolylines() async {
    if (_currentPosition == null || _isDisposed) return;

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
      debugPrint("Failed to fetch route: ${result.status}");
    }
  }

  void _addPolyline() {
    PolylineId id = const PolylineId('poly');
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
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
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
              if (_currentLocationMarker != null) _currentLocationMarker!,
              if (_destinationMarker != null) _destinationMarker!,
            },
            polylines: Set<Polyline>.of(polylines.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // ✅ Legend in the top-right corner
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
