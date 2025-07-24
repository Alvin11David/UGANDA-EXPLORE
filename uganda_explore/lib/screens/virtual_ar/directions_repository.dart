import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Directions {
  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  Directions({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });
}

class DirectionsRepository {
  final String apiKey;

  DirectionsRepository(this.apiKey);

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String mode = 'driving',
  }) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$mode&'
        'overview=full&'
        'key=$apiKey';

    if (waypoints != null && waypoints.isNotEmpty) {
      final waypointsStr = waypoints
          .map((w) => '${w.latitude},${w.longitude}')
          .join('|');
      url += '&waypoints=$waypointsStr';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' &&
          data['routes'] != null &&
          data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];
        final polylinePoints = _decodePolyline(points);
        final leg = route['legs'][0];
        return Directions(
          polylinePoints: polylinePoints,
          totalDistance: leg['distance']['text'] ?? '',
          totalDuration: leg['duration']['text'] ?? '',
        );
      }
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
} 