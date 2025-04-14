import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HoSoDatDaiService {
  final String apiUrl = "${Appconfig.apiBaseUrl}/hosodatdai";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 📥 Lấy danh sách Hồ Sơ Đất Đai
  Future<Map<String, dynamic>> fetchHoSoDatDai(String token, {
    int? limit,
    int? page,
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

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse["EC"] == 0) {
        return {
          "data": (jsonResponse["data"] as List)
              .map((e) => HoSoDatDai.fromJson(e))
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

  // 🔍 Lấy thông tin Hồ Sơ Đất Đai theo ID
  Future<HoSoDatDai?> getHoSoDatDaiById(int hosodatdaiID) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$hosodatdaiID'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HoSoDatDai.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ➕ Thêm mới Hồ Sơ Đất Đai
  Future<bool> addHoSoDatDai(HoSoDatDai hoSoDatDai) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse("$apiUrl/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(hoSoDatDai.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ✏️ Cập nhật Hồ Sơ Đất Đai
  Future<bool> updateHoSoDatDai(HoSoDatDai hoSoDatDai) async {
    String? token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${hoSoDatDai.hosodatdaiID}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(hoSoDatDai.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🗑 Xóa Hồ Sơ Đất Đai
  Future<bool> deleteHoSoDatDai(int hosodatdaiID) async {
    String? token = await _getToken();
    if (token == null) throw Exception("Chưa có token!");

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$hosodatdaiID"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }



  Future<Map<String, dynamic>> searchHoso(String token,Map<String, dynamic> filters) async {

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
          List<HoSoDatDai> hoSoList = (jsonResponse["data"] as List)
              .map((e) => HoSoDatDai.fromJson(e))
              .toList();
          return {
            "success": true,
            "data": hoSoList,
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
  Future<Map<String, dynamic>> getHoSoDatDaiByNgayPheDuyet() async {
    String? token = await _getToken(); // Giả định bạn có phương thức _getToken
    try {
      Uri uri = Uri.parse('$apiUrl/getby/npd');
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse["EC"] == 0) {
          if (jsonResponse["data"] is List) {
            return {
              "data": (jsonResponse["data"] as List)
                  .map((e) => HoSoDatDai.fromJson(e))
                  .toList(),
            };
          } else if (jsonResponse["data"] is Map) {
            return {
              "data": [HoSoDatDai.fromJson(jsonResponse["data"])],
            };
          } else {
            return {"error": "Dữ liệu 'data' không hợp lệ"};
          }
        } else {
          return {"error": jsonResponse["EM"]};
        }
      } else {
        return {
          "error": "Lỗi phản hồi từ server: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "error": "Đã xảy ra lỗi khi gọi API: $e",
      };
    }
  }

}
