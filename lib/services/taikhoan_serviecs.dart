import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TaikhoanServiecs{
  final String apiUrl = "${Appconfig.apiBaseUrl}/taikhoan";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, dynamic>> fetchTaikhoan(String token, {
    int limit = 7,
    int page = 1,
    Map<String, String?>? filters,
  }) async {
    final queryParams = {
      "limit": limit.toString(),
      "page": page.toString(),
    };

    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          queryParams[key] = value;
        }
      });
    }

    final uri = Uri.parse("$apiUrl/get").replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    // Debug dữ liệu trả về
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse["EC"] == 0) {
        return {
          "data": (jsonResponse["data"] as List)
              .map((e) => TaiKhoan.fromJson(e))
              .toList(),
          "total": jsonResponse["total"] ?? 0,
          "currentPage": jsonResponse["currentPage"] ?? page,
          "totalPages": jsonResponse["totalPages"] ?? 1,
        };
      } else {
        throw Exception("Lỗi từ API: ${jsonResponse["message"] ?? "Không rõ lỗi"}");
      }
    } else {
      throw Exception("Lỗi kết nối API: Mã trạng thái ${response.statusCode}");
    }
  }


  Future<TaiKhoan?> getTaikhoanById(int taikhoanID) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$taikhoanID'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaiKhoan.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }


  Future<bool> addTaikhoan(TaiKhoan taiKhoan) async {
    try {
      String? token = await _getToken(); // Lấy token
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$apiUrl/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Gửi token để xác thực
        },
        body: jsonEncode(taiKhoan.toJson()),
      );

      if (response.statusCode ==
          201) { // API trả về 201 (Created) là thành công
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  Future<bool> updateTaikhoan(TaiKhoan taiKhoan) async {
    String? token = await _getToken();
    if (token == null) return false; // Không có token, không xóa được
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${taiKhoan.taikhoanID}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(taiKhoan.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // ✅ Cập nhật thành công
      } else {
        // ✅ Lấy lỗi chi tiết từ API
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData["error"] ??
            responseData["message"] ?? "Lỗi không xác định!";
        throw Exception(errorMessage); // 🚀 Ném lỗi để hiển thị trong Dialog
      }
    } catch (e) {
      throw Exception(e.toString()); // 🚀 Đảm bảo lỗi không bị mất
    }
  }


  Future<bool> deleteTaikhoan(int taikhoanID) async {
    String? token = await _getToken();
    if (token == null) throw Exception("Chưa có token!");

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$taikhoanID"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> searchTaikhoan(String token,Map<String, dynamic> filters) async {

    try {
      final uri = Uri.parse("$apiUrl/search").replace(queryParameters: filters);
      final response = await http.get(uri,
          headers:{
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          }
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse["EC"] == 0) {
          List<TaiKhoan> Taikhoanlist = (jsonResponse["data"] as List)
              .map((e) => TaiKhoan.fromJson(e))
              .toList();

          return {
            "success": true,
            "data": Taikhoanlist,
          };
        } else {
          throw Exception("Lỗi từ API: ${jsonResponse["message"] ?? "Không rõ lỗi"}");
        }
      } else {
        throw Exception("Lỗi kết nối API: Mã trạng thái ${response.statusCode}");
      }

    }catch(error){
      return {
        "success": false,
        "message": "Đã xảy ra lỗi: $error",
      };
    }
  }

  Future<String?> getHoTen(int taikhoanID) async {
    String? token = await _getToken();
    try {
      Uri uri = Uri.parse("$apiUrl/hoten?taikhoanID=$taikhoanID");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse["EC"] == 0) {
          return jsonResponse["data"].toString() ?? "Chưa cập nhật";
        } else {
          return "Chưa cập nhật";
        }
      } else {
        return "Chưa cập nhật";
      }
    } catch (e) {
      return "Chưa cập nhật";
    }
  }
}