import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChuSoHuuService {
  final String apiUrl = "${Appconfig.apiBaseUrl}/chusohuu"; // Cập nhật URL API thật

  // 🟢 Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 📥 Lấy danh sách Chủ Sở Hữu từ API
  Future<Map<String, dynamic>> fetchChuSoHuu(String token, {
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
              .map((e) => ChuSoHuu.fromJson(e))
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

  // 🔍 Lấy thông tin Chủ Sở Hữu theo ID
  Future<ChuSoHuu?> getChuSoHuuById(int chusohuuID) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$chusohuuID'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChuSoHuu.fromJson(data);
      } else {
        print("❌ Lỗi khi lấy dữ liệu chủ sở hữu: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi khi gọi API: $e");
      return null;
    }
  }

  // ➕ Thêm mới Chủ Sở Hữu
  Future<bool> addChuSoHuu(ChuSoHuu chuSoHuu) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print("⚠️ Không tìm thấy token. Vui lòng đăng nhập lại.");
        return false;
      }

      final response = await http.post(
        Uri.parse("$apiUrl/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(chuSoHuu.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("⚠️ Lỗi API khi thêm mới: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối API: $e");
      return false;
    }
  }

  Future<bool> checkOwnerInfo(int taiKhoanId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception("Không tìm thấy token");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/checkEN?taikhoanID=$taiKhoanId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['EC'] == 0; // Trả về true nếu có thông tin, false nếu không
      } else {
        throw Exception("Lỗi khi kiểm tra thông tin chủ sở hữu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // ✏️ Cập nhật thông tin Chủ Sở Hữu
  Future<bool> updateChuSoHuu(ChuSoHuu chuSoHuu) async {
    String? token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${chuSoHuu.chusohuuID}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(chuSoHuu.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData["error"] ?? responseData["message"] ?? "Lỗi không xác định!";
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 🗑 Xóa Chủ Sở Hữu
  Future<bool> deleteChuSoHuu(int chusohuuID) async {
    String? token = await _getToken();
    if (token == null) throw Exception("Chưa có token!");

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$chusohuuID"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> searchChusohuu(String token,Map<String, dynamic> filters) async {

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
          List<ChuSoHuu> chuSoHuuList = (jsonResponse["data"] as List)
              .map((e) => ChuSoHuu.fromJson(e))
              .toList();

          return {
            "success": true,
            "data": chuSoHuuList,
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



  Future<List<ChuSoHuu>> getListHoTenChuSoHuu({String keyword = ''}) async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/listhoten?keyword=$keyword"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['EC'] == 0 && responseData['data'] is List) {
          List<dynamic> data = responseData['data'];

          // 🛠 Sử dụng Set để loại bỏ dữ liệu trùng lặp theo `chusohuuID`
          final Set<int> seenIDs = {};
          List<ChuSoHuu> uniqueChuSoHuuList = [];

          for (var item in data) {
            if (item is Map<String, dynamic>) {
              ChuSoHuu chuSoHuu = ChuSoHuu.fromMinimalJson(item);
              if (!seenIDs.contains(chuSoHuu.chusohuuID) && chuSoHuu.chusohuuID != 0) {
                seenIDs.add(chuSoHuu.chusohuuID);
                uniqueChuSoHuuList.add(chuSoHuu);
              }
            }
          }
          return uniqueChuSoHuuList;
        } else {
          throw Exception('Dữ liệu không hợp lệ: ${responseData['EM'] ?? 'Không có thông điệp lỗi'}');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return [];
    }
  }


}
