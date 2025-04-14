import 'package:flutter/material.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:qlyhoso/presentation/widgets/create_taikhoan_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/taikhoan_card.dart';
import 'package:qlyhoso/services/taikhoan_serviecs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuanLyTaiKhoanScreen extends StatefulWidget {
  const QuanLyTaiKhoanScreen({super.key});

  @override
  QuanLyTaiKhoanScreenState createState() => QuanLyTaiKhoanScreenState();
}

class QuanLyTaiKhoanScreenState extends State<QuanLyTaiKhoanScreen> {
  List<TaiKhoan> _dsTaikhoan = [];
  List<TaiKhoan> _searchTaikhoan = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 7;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTaikhoan();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _searchTaikhoan = _dsTaikhoan;
      });
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
        final result = await TaikhoanServiecs().searchTaikhoan(token, {
          'keyword': keyword,
        });

        if (result['success'] == true) {
          setState(() {
            _searchTaikhoan = result['data'] ?? [];
          });
        } else {
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Lỗi tìm kiếm dữ liệu')),
          );
        }
      } catch (error) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $error')),
        );
      }
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _loadTaikhoan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      Map<String, dynamic> response = await TaikhoanServiecs().fetchTaikhoan(
        token,
        limit: _limit,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _dsTaikhoan = response['data'];
        _searchTaikhoan = _dsTaikhoan;
        _totalPages = (response['total'] / _limit).ceil();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePage(int newPage) {
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadTaikhoan();
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return createTaikhoanDialog(
          onTaikhoanAdded: (newTaiKhoan) {
            setState(() {
              _dsTaikhoan.add(newTaiKhoan);
              _searchTaikhoan = _dsTaikhoan;
            });
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final double fabSize = MediaQuery.of(context).size.width * 0.12;
    return Scaffold(
      backgroundColor: Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Đổi màu icon quay lại thành trắng
        ),
        title: Text("Quản lý tài khoản",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTaikhoan,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarWidget(controller: _searchController, onSearch: (keyword) => _onSearchChanged()
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("⚠️ Lỗi: $_errorMessage"))
                : _searchTaikhoan.isEmpty
                ? Center(child: Text("Không có tài khoản nào được tìm thấy."))
                : ListView.builder(
              itemCount: _searchTaikhoan.length,
              itemBuilder: (context, index) {
                final taiKhoan = _searchTaikhoan[index];
                return TaiKhoanCard(
                  taiKhoan: taiKhoan,
                  onDelete: () => _deleteTaikhoan(taiKhoan.taikhoanID),
                );
              },
            ),
          ),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog,child: SizedBox(
        width: fabSize,  // Đặt chiều rộng dựa trên tỷ lệ màn hình
        height: fabSize,
        child: Center(
          child: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
        ),
      ),),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        0,    // Không dịch ngang
        -40, // Dịch lên trên 100 pixel
      ),
    );

  }

  Future<void> _deleteTaikhoan(int taikhoanID) async {
    bool success = await TaikhoanServiecs().deleteTaikhoan(taikhoanID);
    if(!mounted) return;
    if (success) {
      setState(() {
        _dsTaikhoan.removeWhere((tk) => tk.taikhoanID == taikhoanID);
        _searchTaikhoan = _dsTaikhoan;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại!")),
      );
    }
  }


  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed: _currentPage > 1 ? () => _changePage(1) : null,
          ),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
          ),
          Text("Trang $_currentPage / $_totalPages",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed: _currentPage < _totalPages ? () => _changePage(_totalPages) : null,
          ),
        ],
      ),
    );
  }

}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final double offsetX;
  final double offsetY;

  const CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset baseOffset = location.getOffset(scaffoldGeometry);
    return Offset(baseOffset.dx + offsetX, baseOffset.dy + offsetY);
  }
}
