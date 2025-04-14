import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/hotro_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HoTroService {
  static const String apiUrl = "${Appconfig.apiBaseUrl}/hotro";


  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Token được lưu khi đăng nhập
  }


  Future<List<HoTro>> getHoTroList() async {
    final response = await http.get(
      Uri.parse('$apiUrl/get'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer your_token_here", // Thay bằng token thực tế
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = (json.decode(response.body) as Map)
          .cast<String, dynamic>();
      if (jsonResponse["EC"] == 0) {
        final data = jsonResponse["data"];
        List<HoTro> hoTroList;
        if (data is List) {
          hoTroList = (data as List).map((e) =>
              HoTro.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map) {
          hoTroList = [HoTro.fromJson(data as Map<String, dynamic>)];
        } else {
          throw Exception(
              'Dữ liệu "data" không hợp lệ: Không phải List hoặc Map');
        }
        return hoTroList;
      } else {
        throw Exception('Lỗi tải danh sách hỗ trợ: ${jsonResponse["EM"] ??
            response.statusCode}');
      }
    } else {
      throw Exception('Lỗi tải danh sách hỗ trợ: ${response.statusCode}');
    }
  }

  Future<bool> createHoTro(String noiDungHoTro, int taikhoanID,
      String soDienThoai) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/add1'), // Cập nhật URL API chính xác
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer your_token_here", // Thay bằng token thực tế
        },
        body: jsonEncode({
          "TaikhoanID": taikhoanID,
          "NoiDungHoTro": noiDungHoTro,
          "SoDienThoai": soDienThoai,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Thành công
      } else {
        print('Lỗi tạo yêu cầu: ${response.body}');
        return false; // Lỗi từ API
      }
    } catch (e) {
      print('Lỗi kết nối API: $e');
      return false; // Lỗi mạng hoặc lỗi khác
    }
  }


  Future<Map<String, dynamic>> fetchHoTroByTaikhoanID(int taikhoanID) async {

    String? token = await _getToken();
    final String url = '$apiUrl/$taikhoanID';

    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['EC'] == 0) {
          return {
            "data": (jsonResponse["data"] as List)
                .map((e) => HoTro.fromJson(e))
                .toList(),
          };
        } else {
          throw Exception("Lỗi từ server: ${jsonResponse['EC']}");
        }
      } else {
        throw Exception("Lỗi kết nối: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

}