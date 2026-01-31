import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Determine the current position of the device.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could request again
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error("Location permission permanently denied.");
  }

  // When we reach here, permissions are granted
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 60),
  );
}

Future<String> getPlaceName(double latitude, double longitude) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  if (placemarks.isNotEmpty) {
    if (placemarks.length > 1) {
      print("Multiple placemarks found, returning the first one.");
    }
    Placemark place = placemarks[0];
    return "${place.locality}, ${place.administrativeArea}";
  } else {
    return "Unknown";
  }
}
