import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class Auth_login_Service {
  final String baseUrl = "${Appconfig.apiBaseUrl}/auth";


  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final Uri url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {

        if (responseData["token"]
            .toString()
            .isEmpty || responseData["taikhoan"]["vaiTro"]
            .toString()
            .isEmpty) {
          throw Exception("API không trả về token hoặc vai trò!");
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", responseData["token"]);
        await prefs.setString("vaiTro", responseData["taikhoan"]["vaiTro"]);

        return {"success": true, "message": "Đăng nhập thành công"};
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Lỗi không xác định"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi: ${e.toString()}"};
    }
  }

  /// 🔹 **Đăng xuất**
  Future<Map<String, dynamic>> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      return {"success": false, "message": "Không tìm thấy token!"};
    }

    final Uri url = Uri.parse("$baseUrl/logout");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Xóa token sau khi đăng xuất thành công
        await prefs.remove("token");
        await prefs.remove("vaiTro");

        return {"success": true, "message": "Đăng xuất thành công"};
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Đăng xuất thất bại"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối API: ${e.toString()}"};
    }
  }

}
class Auth_register_Service {
  final String baseUrl = Appconfig.apiBaseUrl; // 🔹 Đổi thành URL thực tế

  /// 🛠 **Hàm đăng ký người dùng**
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "email": email,
          "sdt": phone
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body); // ✅ Trả về JSON hợp lệ
      } else {
        return {"success": false, "message": jsonDecode(response.body)["message"] ?? "Đăng ký thất bại"};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối API: ${e.toString()}"};
    }
  }
}