import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlyhoso/config/config.dart';
import 'package:qlyhoso/data/models/quanly_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class QuanLyServices {
  final String baseUrl = '${Appconfig.apiBaseUrl}/quanly';
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); // Token được lưu khi đăng nhập
  }
  // Lấy danh sách quản lý
  Future<Map<String, dynamic>> layDanhSachQuanly({
    int limit = 10,
    int page = 1,
    Map<String, dynamic> filters = const {},
  }) async {
    final queryParameters = {
      'limit': limit.toString(),
      'page': page.toString(),
      ...filters,
    };
    String? token = await _getToken();
    final uri = Uri.parse('$baseUrl/get').replace(
        queryParameters: queryParameters);
    print(uri);
    try {
      final response = await http.get(uri,
          headers:{'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',}
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<QuanLy> quanlyList = (data['data'] as List)
            .map((item) => QuanLy.fromJson(item))
            .toList();
        return {
          'EC': data['EC'],
          'quanly': quanlyList,
          'total': data['total'],
          'currentPage': data['currentPage'],
          'totalPages': data['totalPages'],
        };
      } else {
        throw Exception(
            'Lỗi khi tải danh sách quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }

  // Lấy thông tin quản lý theo ID
  Future<QuanLy> layQuanlyTheoId(String id) async {
    final uri = Uri.parse('$baseUrl/get/$id');
    String? token = await _getToken();
    try {
      final response = await http.get(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuanLy.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy quản lý');
      } else {
        throw Exception(
            'Lỗi khi tải thông tin quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }

  // Thêm quản lý
  Future<QuanLy> taoQuanly(QuanLy quanly) async {
    final uri = Uri.parse('$baseUrl/add');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(quanly.toJson());

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return QuanLy.fromJson(data);
      } else {
        throw Exception('Lỗi khi tạo quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }

  // Cập nhật quản lý
  Future<bool> capNhatQuanly(String id, QuanLy quanly) async {
    final uri = Uri.parse('$baseUrl/update/$id');
    String? token = await _getToken();
    final headers = {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',};
    final body = json.encode(quanly.toJson());

    try {
      final response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy quản lý');
      } else {
        throw Exception('Lỗi khi cập nhật quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }

  // Xóa quản lý
  Future<bool> xoaQuanly(String id) async {
    final uri = Uri.parse('$baseUrl/delete/$id');
    String? token = await _getToken();
    try {
      final response = await http.delete(uri,
          headers:{'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',} );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy quản lý');
      } else {
        throw Exception('Lỗi khi xóa quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }

  // Lọc và tìm kiếm quản lý
  Future<Map<String, dynamic>> searchQuanly(
      Map<String, dynamic> filters, Map<String, String> map) async {
    String? token = await _getToken();
    final queryParameters = {...filters};
    final uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: queryParameters);

    try {
      final response = await http.get(uri, headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<QuanLy> quanlyList = (data['data'] as List)
            .map((item) => QuanLy.fromJson(item))
            .toList();
        return {
          'EC': data['EC'],
          'quanly': quanlyList,
        };
      } else {
        throw Exception('Lỗi khi tìm kiếm quản lý: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Lỗi kết nối: $error');
    }
  }
}