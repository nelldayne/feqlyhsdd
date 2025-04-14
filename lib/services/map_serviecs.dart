import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
class RouteData {
  final List<LatLng> routePoints; // Danh sách tọa độ đường đi
  final List<Map<String, dynamic>> routeSteps; // Danh sách các bước hướng dẫn

  RouteData({required this.routePoints, required this.routeSteps});
}
class RouteService {
  // Khóa API của OpenRouteService
  final String orsApiKey = '5b3ce3597851110001cf624801eb9f99f0cb464a8585bc8fbcbbe6ca'; // Thay bằng API Key của bạn từ OpenRouteService

  // Hàm gọi OpenRouteService API để lấy đường đi
  Future<RouteData> calculateRoute(LatLng start, LatLng end, String travelMode) async {
    String profile;
    switch (travelMode) {
      case 'driving':
        profile = 'driving-car';
        break;
      case 'walking':
        profile = 'foot-walking';
        break;
      case 'bicycling':
        profile = 'cycling-regular';
        break;
      default:
        profile = 'driving-car';
    }

    final String url =
        'https://api.openrouteservice.org/v2/directions/$profile?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          // Lấy tọa độ đường đi từ geometry
          final List coordinates = data['features'][0]['geometry']['coordinates'];
          List<LatLng> routeCoordinates = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

          // Lấy danh sách các bước hướng dẫn
          final List steps = data['features'][0]['properties']['segments'][0]['steps'];
          List<Map<String, dynamic>> routeInstructions = steps.map((step) {
            return {
              'instruction': step['instruction'],
              'distance': "${(step['distance'] / 1000).toStringAsFixed(2)} km", // Chuyển đổi từ mét sang km
              'duration': "${(step['duration'] / 60).toStringAsFixed(1)} phút", // Chuyển đổi từ giây sang phút
            };
          }).toList();

          return RouteData(routePoints: routeCoordinates, routeSteps: routeInstructions);
        } else {
          throw Exception('Không tìm thấy đường đi');
        }
      } else {
        throw Exception('Lỗi khi gọi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Lỗi khi tính toán đường đi: $e");
    }
  }
}
Future<LatLng?> getCoordinatesFromAddress(String address) async {
  final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$address&format=json');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data.isNotEmpty) {
      double lat = double.parse(data[0]["lat"]);
      double lon = double.parse(data[0]["lon"]);
      return LatLng(lat, lon);
    }
  }
  return null; // Không tìm thấy kết quả
}

