import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeService {
  final String apiUrl = "${Appconfig.apiBaseUrl}/nhanvien"; // URL backend
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Token được lưu khi đăng nhập
  }
  // 🟢 API: Lấy danh sách nhân viên
  Future<Map<String, dynamic>> fetchEmployees({
    required String token,
    int? limit,
    int? page,
    String? searchQuery,
  }) async {
    final queryParams = {
      "limit": limit.toString(),
      "page": page.toString(),
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams["search"] = searchQuery;
    }

    final uri = Uri.parse("$apiUrl/get").replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return {
        "data": (jsonResponse["data"] as List).map((e) => Employee.fromJson(e)).toList(),
        "total": jsonResponse["total"] ?? 0,
        "currentPage": jsonResponse["currentPage"] ?? page,
        "totalPages": jsonResponse["totalPages"] ?? 1,
      };
    } else {
      throw Exception("Lỗi khi tải danh sách nhân viên");
    }
  }

  // 🟢 API: Lấy thông tin một nhân viên
  Future<Employee> getEmployeeById(int id) async {
    final response = await http.get(Uri.parse("$apiUrl/get/$id"));

    if (response.statusCode == 200) {
      return Employee.fromJson(json.decode(response.body));
    } else {
      throw Exception("Lỗi lấy thông tin nhân viên: ${response.body}");
    }
  }

  // 🟢 API: Thêm nhân viên mới
  Future<bool> addEmployee(Employee employee) async {
    try{
      String? token = await _getToken(); // Lấy token
      if (token == null) {
        print("⚠️ Không tìm thấy token. Vui lòng đăng nhập lại.");
        return false;
      }

      final response = await http.post(
          Uri.parse("$apiUrl/add"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // Gửi token để xác thực
          },
          body: jsonEncode(
            {
              'NhanvienID': employee.id,
              'TaikhoanID': employee.taikhoanid,
              'HoTen': employee.hoten,
              'NgaySinh': employee.ngaysinh.toIso8601String(), // Chuyển DateTime -> String
              'GioiTinh': employee.gioitinh,
              'PhongBan': employee.phongban,
              'SoDienThoai': employee.sodienthoai,
              'Email': employee.email,
              'TrangThai': employee.trangthai,
            }),
      );
      if (response.statusCode == 201) { // API trả về 201 (Created) là thành công
        return true;
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = errorData["message"] ?? "Lỗi không xác định!";
        throw Exception(errorMessage);
        return false;
      }
    } catch (e) {
      throw Exception("Lỗi kết nối hoặc dữ liệu không hợp lệ: $e");
    }
  }
  // 🟢 API: Cập nhật nhân viên
  Future<bool> updateEmployee( Employee employee) async {
    String? token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/update/${employee.id}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(employee.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // ✅ Cập nhật thành công
      } else {
        // ✅ Lấy lỗi chi tiết từ API
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData["error"] ?? responseData["message"] ?? "Lỗi không xác định!";
        throw Exception(errorMessage); // 🚀 Ném lỗi để hiển thị trong Dialog
      }
    } catch (e) {
      throw Exception(e.toString()); // 🚀 Đảm bảo lỗi không bị mất
    }
  }
  // 🟢 API: Xóa nhân viên
  Future<bool> deleteEmployee(int nhanvienID) async {
    String? token = await _getToken();
    if (token == null) return false; // Không có token, không xóa được

    final response = await http.delete(
      Uri.parse("$apiUrl/delete/$nhanvienID"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response.statusCode == 200; // Trả về true nếu xóa thành công
  }

  Future<Map<String, dynamic>> searchNhanvien(String token,Map<String, dynamic> filters) async {

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
          List<Employee> NhanvienList = (jsonResponse["data"] as List)
              .map((e) => Employee.fromJson(e))
              .toList();

          return {
            "success": true,
            "data": NhanvienList,
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

  Future<List<Employee>> getListHoTenNV({String keyword = ''}) async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/listhotennv?keyword=$keyword"),
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
          List<Employee> uniqueNhanvienList = [];

          for (var item in data) {
            if (item is Map<String, dynamic>) {
              Employee hotenNV = Employee.fromMiniJson(item);
              if (!seenIDs.contains(hotenNV.id) &&
                  hotenNV.hoten != 0) {
                seenIDs.add(hotenNV.id);
                uniqueNhanvienList.add(hotenNV);
              }
            }
          }
          return uniqueNhanvienList;
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
