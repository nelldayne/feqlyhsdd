import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuyHoachService {
  final String apiUrl = "${Appconfig.apiBaseUrl}/quyhoach";


  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 📥 Lấy danh sách Quy Hoạch từ API
  Future<Map<String, dynamic>> fetchQuyhoach(String token, {
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
              .map((e) => QuyHoach.fromJson(e))
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
  Future<QuyHoach?> getQuyhoachById(int quyhoachID) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$quyhoachID'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuyHoach.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<bool> addQuyhoach(QuyHoach quyHoach) async {
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
        body: jsonEncode(quyHoach.toJson()),
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
  Future<bool> updateQuyhoach(QuyHoach quyHoach) async {
    String? token = await _getToken();
    if (token == null) return false; // Không có token, không xóa được
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${quyHoach.quyhoachID}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(quyHoach.toJson()),
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

  // 🗑 Xóa quy hoạch
  Future<bool> deleteQuyHoach(int quyhoachID) async {
    String? token = await _getToken();
    if (token == null) throw Exception("Chưa có token!");

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$quyhoachID"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> searchQuyhoach(String token,Map<String, dynamic> filters) async {

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
          List<QuyHoach> QuyhoachList = (jsonResponse["data"] as List)
              .map((e) => QuyHoach.fromJson(e))
              .toList();

          return {
            "success": true,
            "data": QuyhoachList,
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



  Future<List<QuyHoach>> getListLoaiQuyHoach({String keyword = ''}) async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/listloaiquyhoach?keyword=$keyword"),
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
          List<QuyHoach> uniqueQuyhoachList = [];

          for (var item in data) {
            if (item is Map<String, dynamic>) {
              QuyHoach loaiQuyHoach = QuyHoach.fromminiJson(item);
              if (!seenIDs.contains(loaiQuyHoach.quyhoachID) && loaiQuyHoach.loaiQuyHoach != 0) {
                seenIDs.add(loaiQuyHoach.quyhoachID);
                uniqueQuyhoachList.add(loaiQuyHoach);
              }
            }

          }
          return uniqueQuyhoachList;

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
