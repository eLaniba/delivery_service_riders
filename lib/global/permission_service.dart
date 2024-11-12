import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, proceed with geolocation or geocoding
      print("Location permission granted");
    } else if (status.isDenied) {
      // Permission denied, request again or show a message
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      // Open app settings for the user to enable permission manually
      await openAppSettings();
      print("Location permission is permanently denied, open settings.");
    }
  }
}
