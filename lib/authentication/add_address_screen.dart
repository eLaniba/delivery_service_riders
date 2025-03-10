
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController locationController = TextEditingController();

  GoogleMapController? _mapController;

  LatLng? _currentPosition; // Nullable current position

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Shows an alert dialog with a custom message and a Retry option.
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Method to fetch current location using Geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog("Location services are disabled. Please enable them and try again.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _showErrorDialog("Location permissions are denied. Please grant permissions and try again.");
        return;
      }
    }

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
        });
      }

      if (_currentPosition != null) {
        _getAddressFromLatLng(_currentPosition!);
      }
    } catch (e) {
      print('Error getting the location: $e');
      _showErrorDialog("An error occurred while fetching location. Please try again.");
    }
  }

  // Method to get the address from latitude and longitude
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark pMark = placemarks[1];
        if (mounted) {
          setState(() {
            locationController.text =
            '${pMark.street}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.country}';
          });
        }
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  // Saves the new address to Firestore
  Future<void> addNewAddressToFirestore() async {
    if (_currentPosition == null) {
      Navigator.of(context).pop();
      return;
    }

    GeoPoint newLocation = GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);

    CollectionReference addressCollection = firebaseFirestore
        .collection('users')
        .doc('${sharedPreferences!.getString('uid')}')
        .collection('address');

    DocumentReference addressDoc = await addressCollection.add({
      'addressEng': locationController.text,
      'location': newLocation,
    });

    await addressDoc.update({
      'addressID': addressDoc.id,
    });

    Navigator.of(context).pop(); // Pop the loading dialog
    Navigator.of(context).pop(); // Pop the Add New Address Screen
  }

  // Returns the address data to the previous screen
  void saveAddress() {
    GeoPoint newLocation = GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);

    Navigator.pop(context, {
      'addressEng': locationController.text.trim(),
      'location': newLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Pick a Location"),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16,),
              Text('Setting up your location, please wait.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container for Google Map with a border
            Container(
              height: 300,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  // Google Map wrapped in ClipRRect to follow container's curve
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 16.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                          _currentPosition = position.target;
                        });
                      },
                      onCameraIdle: () {
                        if (_currentPosition != null) {
                          _getAddressFromLatLng(_currentPosition!);
                        }
                      },
                      myLocationEnabled: false,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                  // Center pin icon
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -25),
                      child: Icon(
                        Icons.location_pin,
                        size: 50.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info(PhosphorIconsStyle.regular),
                    color: Colors.blue,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  const Flexible(
                    child: Text(
                      'The address might not be fully accurate. Please review and edit the address below.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  labelText: 'Address',
                  controller: locationController,
                  isObscure: false,
                  enabled: true,
                  validator: validateLocationNewAddress,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor,
          ),
          height: 60,
          child: TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Use one of the two methods depending on your flow:
                // addNewAddressToFirestore();
                saveAddress();
              }
            },
            child: const Text(
              'Save Address',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
