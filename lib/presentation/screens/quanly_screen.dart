import 'package:flutter/material.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/quanly_model.dart';
import 'package:qlyhoso/presentation/widgets/quanly_card.dart';
import 'package:qlyhoso/services/quanly_serviecs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuanLyScreen extends StatefulWidget {
  const QuanLyScreen({Key? key}) : super(key: key);

  @override
  QuanLyScreenState createState() => QuanLyScreenState();
}

class QuanLyScreenState extends State<QuanLyScreen> {
  final QuanLyServices _quanLyServices = QuanLyServices();
  List<QuanLy> _quanlys = [];
  List<QuanLy> _filteredQuanly = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _fetchQuanlys();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _fetchQuanlys() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _quanLyServices.layDanhSachQuanly(
        limit: _limit,
        page: _currentPage,
        filters: _filters,
      );
      setState(() {
        _quanlys = result['quanly'] as List<QuanLy>;
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Lỗi khi tải danh sách quản lý: $error";
        _isLoading = false;
      });
    }
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
    _fetchQuanlys();
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _filteredQuanly = _quanlys;
      });
      _fetchQuanlys(); // Gọi lại để lấy tổng số toàn bộ từ API gốc
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
        final result = await QuanLyServices().searchQuanly(token as Map<String, dynamic>, {
          'keyword': keyword,
        });
        if (!mounted) return;
        if (result['success'] == true) {
          setState(() {
            _filteredQuanly = result['data'] ?? [];
            _quanlys = _filteredQuanly;
            _totalPages = 1; // Giả định tìm kiếm không phân trang
            _totalPages = result['total'] ?? _totalPages; // Cập nhật tổng số nếu API trả về
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Lỗi tìm kiếm dữ liệu')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Quản Lý Quản Lý',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQuanlys,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController,onSearch: (keyword) => _onSearchChanged()),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : ListView.builder(
              itemCount: _quanlys.length,
              itemBuilder: (context, index) {
                final quanly = _quanlys[index];
                return QuanLyCard(
                  quanly: quanly,
                  onDelete: () {

                  },
                  onEdit: () {

                  },
                );
              },
            ),
          ),
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => _handlePageChange(_currentPage - 1)
                        : null,
                  ),
                  Text('$_currentPage/$_totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _totalPages
                        ? () => _handlePageChange(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add
        },
        child: Center(
          child: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
        ),
      ),
    );
  }
}