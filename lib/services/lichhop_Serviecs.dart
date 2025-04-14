import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/data/models/lichhop_Model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qlyhoso/config/config.dart';

class LichHopService {
  static const String apiUrl = "${Appconfig.apiBaseUrl}/lichhop";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token"); // Lấy token từ SharedPreferences
  }

  Future<List<LichHop>> getLichHopList() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$apiUrl/get'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      // Nếu API trả về object chứa danh sách
      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey("data")) {
        List<dynamic> dataList = jsonResponse["data"];
        return dataList.map((e) => LichHop.fromJson(e)).toList();
      }

      throw Exception("Dữ liệu trả về không đúng định dạng");
    } else {
      throw Exception('Lỗi khi tải lịch họp: ${response.statusCode}');
    }
  }
  Future<void> createLichHop(LichHop lichHop) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$apiUrl/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(lichHop.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi tạo lịch họp: ${response.statusCode}');
    }
  }

  Future<void> updateLichHop(int id, LichHop lichHop) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$apiUrl/update/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(lichHop.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật lịch họp: ${response.statusCode}');
    }
  }

  Future<void> deleteLichHop(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$apiUrl/delete/$id'),
      headers: {
        "Authorization": "Bearer $token",

      },
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi xóa lịch họp: ${response.statusCode}');
    }
  }



}
