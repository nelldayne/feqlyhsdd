import 'package:qlyhoso/data/models/thongke_model.dart';

import '../config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ThongkeServiecs{
  static const String apiUrl = "${Appconfig.apiBaseUrl}/thongke";
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Token được lưu khi đăng nhập
  }
  Future<int> slthuadat() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/slthuadat"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is int) return data;
        if (data is Map<String, dynamic>) {
          if (data case {'data': {'total': int total}}) {
            return total;
          }
        }
      }
      throw Exception("⚠️ Lỗi API hoặc dữ liệu không hợp lệ: ${response.body}");
    } catch (e) {
      throw Exception("❌ Lỗi khi gọi API: $e");
    }
  }


  Future<int> slhoso() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/slhoso"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is int) return data;
        if (data is Map<String, dynamic>) {
          if (data case {'data': {'total': int total}}) {
            return total;
          }
        }
      }
      print("⚠️ Lỗi API hoặc dữ liệu không hợp lệ: ${response.body}");
      return -1; // Trả về -1 nếu có lỗi
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return -1; // Trả về -1 khi có lỗi mạng
    }
  }

  Future<int> slchuho() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/slchuho"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is int) return data;
        if (data is Map<String, dynamic>) {
          if (data case {'data': {'total': int total}}) {
            return total;
          }
        }
      }
      print("⚠️ Lỗi API hoặc dữ liệu không hợp lệ: ${response.body}");
      return -1; // Trả về -1 nếu có lỗi
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return -1; // Trả về -1 khi có lỗi mạng
    }
  }

  Future<int> slquyhoach() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/slquyhoach"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is int) return data;
        if (data is Map<String, dynamic>) {
          if (data case {'data': {'total': int total}}) {
            return total;
          }
        }
      }
      throw Exception("⚠️ Lỗi API hoặc dữ liệu không hợp lệ: ${response.body}");
    } catch (e) {
      throw Exception("❌ Lỗi khi gọi API: $e");
    }
  }

  Future<List<Map<String, dynamic>>> slThuadatTheoXa() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/slthuadattheoxa"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Kiểm tra nếu API trả về đúng định dạng
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
          final dataList = jsonResponse['data'];

          if (dataList is List) {
            return List<Map<String, dynamic>>.from(dataList);
          }
        }

        throw Exception("⚠️ Lỗi: Dữ liệu API không đúng định dạng! Phản hồi: $jsonResponse");
      } else {
        throw Exception("⚠️ Lỗi HTTP: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw  Exception("❌ Lỗi khi gọi API slThuadatTheoXa: $e");
    }
  }



}