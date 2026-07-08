import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getCurrentLocationLabel() async {
    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) return 'Izin lokasi ditolak';

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return 'Lokasi tidak ditemukan';

      final place = placemarks.first;
      final city = (place.subAdministrativeArea?.isNotEmpty ?? false)
          ? place.subAdministrativeArea
          : place.locality;
      final province = place.administrativeArea;

      if (city != null &&
          city.isNotEmpty &&
          province != null &&
          province.isNotEmpty) {
        return '$city, $province';
      }
      return province ?? city ?? 'Lokasi tidak diketahui';
    } catch (e) {
      return 'Gagal mendapatkan lokasi';
    }
  }

  static Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }
}
