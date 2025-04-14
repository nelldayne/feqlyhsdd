import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThuaDatService {
  static const String apiUrl = "${Appconfig.apiBaseUrl}/thuadat";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Token được lưu khi đăng nhập
  }

  Future<List<ThuaDat>> fetchThuadatList() async {
    final uri = Uri.parse("$apiUrl/getlist");
    String? token = await _getToken();
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
        return (jsonResponse["data"] as List)
            .map((e) => ThuaDat.fromJson(e))
            .toList();
      } else {
        throw Exception(
            "Lỗi từ API: ${jsonResponse["message"] ?? "Không rõ lỗi"}");
      }
    } else {
      throw Exception("Lỗi kết nối API: Mã trạng thái ${response.statusCode}");
    }
  }




  Future<Map<String, dynamic>> fetchThuadat(String token, {
    int limit = 7,
    int page = 1,
    String? searchQuery,
    Map<String, String?>? filters,
  }) async {
    final queryParams = {
      "limit": limit.toString(),
      "page": page.toString(),
      if (searchQuery != null &&
          searchQuery.isNotEmpty) "searchQuery": searchQuery,
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
              .map((e) => ThuaDat.fromJson(e))
              .toList(),
          "total": jsonResponse["total"] ?? 0,
          "currentPage": jsonResponse["currentPage"] ?? page,
          "totalPages": jsonResponse["totalPages"] ?? 1,
        };
      } else {
        throw Exception(
            "Lỗi từ API: ${jsonResponse["message"] ?? "Không rõ lỗi"}");
      }
    } else {
      throw Exception("Lỗi kết nối API: Mã trạng thái ${response.statusCode}");
    }
  }

  Future<ThuaDat?> getThuaDatById(int thuadatID) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$thuadatID'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ThuaDat.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> addThuaDat(ThuaDat thuaDat) async {
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
        body: jsonEncode(thuaDat.toJson()),
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

  Future<bool> addThuaDatTemp(ThuaDat thuaDat) async {
    try {
      String? token = await _getToken(); // Lấy token
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$apiUrl/temp"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Gửi token để xác thực
        },
        body: jsonEncode(thuaDat.toJson()),
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


  Future<bool> deleteThuaDat(int thuadatID) async {
    String? token = await _getToken();
    if (token == null) return false; // Không có token, không xóa được

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$thuadatID"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response.statusCode == 200; // Trả về true nếu xóa thành công
  }


  Future<bool> updateThuaDat(ThuaDat thuaDat) async {
    String? token = await _getToken();
    if (token == null) return false; // Không có token, không xóa được
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${thuaDat.thuadatID}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(thuaDat.toJson()),
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

  Future<Map<String, dynamic>> searchThuadat(String token,
      Map<String, dynamic> filters) async {
    try {
      final uri = Uri.parse("$apiUrl/search").replace(queryParameters: filters);
      final response = await http.get(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          }
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse["EC"] == 0) {
          List<ThuaDat> thuaDatList = (jsonResponse["data"] as List)
              .map((e) => ThuaDat.fromJson(e))
              .toList();

          return {
            "success": true,
            "data": thuaDatList,
          };
        } else {
          throw Exception(
              "Lỗi từ API: ${jsonResponse["message"] ?? "Không rõ lỗi"}");
        }
      } else {
        throw Exception(
            "Lỗi kết nối API: Mã trạng thái ${response.statusCode}");
      }
    } catch (error) {
      return {
        "success": false,
        "message": "Đã xảy ra lỗi: $error",
      };
    }
  }

  Future<bool> addTachThua(Map<String, dynamic> tachThuaData) async {
    String? token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/tachthua'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(tachThuaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> hopThua(String token, List<int> thuadatIDList) async {
    const String uri = '$apiUrl/hopthua';

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "thuadatIDList": thuadatIDList,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Parse lỗi từ backend (giả định JSON trả về có trường "message")
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Lỗi không xác định từ server';
        debugPrint("🚨 Lỗi khi hợp thửa: ${response.statusCode} - $errorMessage");
        throw Exception(errorMessage); // Ném lỗi với thông điệp từ backend
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc lỗi khác
      String errorMsg = e.toString();
      if (errorMsg.contains("Exception:")) {
        errorMsg = errorMsg.replaceFirst("Exception:", "").trim();
      } else {
        errorMsg = "Lỗi kết nối hoặc xử lý yêu cầu: $e";
      }
      debugPrint("🚨 Lỗi khi gọi API hợp thửa: $errorMsg");
      throw Exception(errorMsg); // Ném lỗi với thông điệp đã xử lý
    }
  }

  Future<Map<String, dynamic>> fetchThuadatByTaikhoanID(int taikhoanID) async {

    String? token = await _getToken();
    final String url = '$apiUrl/listthuadatbytaikhoanID?taikhoanID=$taikhoanID';

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
                .map((e) => ThuaDat.fromJson(e))
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


  Future<List<ThuaDat>> getListDiaChi({String keyword = ''}) async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/listdiachi?keyword=$keyword"),
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
          List<ThuaDat> uniqueThuadatList = [];

          for (var item in data) {
            if (item is Map<String, dynamic>) {
              ThuaDat diaChiThuaDat = ThuaDat.fromMiniJson(item);
              if (!seenIDs.contains(diaChiThuaDat.thuadatID) &&
                  diaChiThuaDat.diaChiThuaDat != 0) {
                seenIDs.add(diaChiThuaDat.thuadatID);
                uniqueThuadatList.add(diaChiThuaDat);
              }
            }
          }
          return uniqueThuadatList;
        } else {
          throw Exception('Dữ liệu không hợp lệ: ${responseData['EM'] ??
              'Không có thông điệp lỗi'}');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return [];
    }
  }
}