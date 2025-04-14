import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import 'package:qlyhoso/presentation/widgets/create_nhanvien_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/nhanvien_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/nhanvien_services.dart';
import '../../components/search_bar.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  EmployeeListScreenState createState() => EmployeeListScreenState();
}

class EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 7;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      Map<String, dynamic> response = await EmployeeService().fetchEmployees(
        token: token,
        limit: _limit,
        page: _currentPage,
        searchQuery: _searchController.text.trim(),
      );

      setState(() {
        _employees = response['data'];
        _filteredEmployees = _employees;
        _totalPages = (response['total'] / _limit).ceil();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
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
      _loadEmployees();
    }
  }

  void _onSearchChanged() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      if (!mounted) return;
      setState(() {
        _filteredEmployees = _employees;
      });
    } else {
      try {
        final token = await _getToken();
        if (!mounted) return;
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

        final result = await EmployeeService().searchNhanvien(token, {
          'keyword': keyword,
        });
        if (!mounted) return;

        if (result['success'] == true) {
          setState(() {
            _filteredEmployees = result['data'] ?? [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Lỗi tìm kiếm dữ liệu')),
          );
        }
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $error')),
        );
      }
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreatedNhanvienDialog(
          onEmployeeAdded: (newEmployee) {
            setState(() {
              _employees.add(newEmployee);
              _filteredEmployees = _employees;
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
          title: Text("Quản lý Nhân Viên",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEmployees,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController, onSearch: (keyword) => _onSearchChanged()),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("Lỗi: $_errorMessage"))
                : _employees.isEmpty
                ? Center(child: Text("Không có nhân viên nào."))
                : ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final emPloyee = _filteredEmployees[index];
                return EmployeeCard(
                  employee: emPloyee,
                  onDelete: () => _deleteEmployee(emPloyee.id),
                  onExportPDF: () {
                  },
                );
              },
            ),
          ),
          _buildPaginationControls(),

        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: SizedBox(
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: Icon(Icons.first_page), onPressed: _currentPage > 1 ? () => _changePage(1) : null),
          IconButton(icon: Icon(Icons.chevron_left), onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null),
          Text("Trang $_currentPage / $_totalPages"),
          IconButton(icon: Icon(Icons.chevron_right), onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null),
          IconButton(icon: Icon(Icons.last_page), onPressed: _currentPage < _totalPages ? () => _changePage(_totalPages) : null),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(int nhanvienID) async {
    bool success = await EmployeeService().deleteEmployee(nhanvienID);
    if (!mounted) return;
    if (success) {
      setState(() {
        _employees.removeWhere((e) => e.id == nhanvienID);
        _filteredEmployees = _employees;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành công!")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại!")),
      );
    }
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