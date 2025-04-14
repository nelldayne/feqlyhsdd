import 'package:flutter/material.dart';
import 'package:qlyhoso/components/filter_component.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/presentation/widgets/create_Quyhoach_Dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/quyhoach_Serviecs.dart';
import '../widgets/quyhoach_card.dart';

class QuyHoachListScreen extends StatefulWidget {
  const QuyHoachListScreen({super.key});

  @override
  QuyHoachListScreenState createState() => QuyHoachListScreenState();
}

class QuyHoachListScreenState extends State<QuyHoachListScreen> {
  List<QuyHoach> _dsQuyhoach = [];
  List<QuyHoach> _filteredQuyhoach = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 15;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String?> _selectedFilters = {};
  @override
  void initState() {
    super.initState();
    _loadQuyhoach();
    _searchController.addListener(_onSearchChanged);
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

  void _changePage(int newPage) {
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadQuyhoach();
    }
  }

  // 📥 Lấy dữ liệu từ API
  Future<void> _loadQuyhoach() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      Map<String, dynamic> response = await QuyHoachService().fetchQuyhoach(
        token,
        limit: _limit,
        page: _currentPage,
        filters: _selectedFilters,
      );

      if (!mounted) return;

      setState(() {
        _dsQuyhoach = response['data'];
        _filteredQuyhoach = _dsQuyhoach;
        _totalPages = (response['total'] / _limit).ceil();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _filteredQuyhoach = _dsQuyhoach;
      });
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
        final result = await QuyHoachService().searchQuyhoach(token, {
          'keyword': keyword,
        });
        if(!mounted) return;
        if (result['success'] == true) {
          setState(() {
            _filteredQuyhoach = result['data'] ?? [];
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


  void _applyFilters() {
    setState(() {
      _filteredQuyhoach = _dsQuyhoach.where((quyHoach) {
        bool matchesFilters = _selectedFilters.entries.every((filter) =>
        filter.value == null || filter.value!.isEmpty ||
            quyHoach.toJson()[filter.key] == filter.value);

        return matchesFilters;
      }).toList();
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateQuyhoachDialog(
          onQuyhoachAdded: (newQuyHoach) {
            setState(() {
              _dsQuyhoach.add(newQuyHoach);
              _filteredQuyhoach = _dsQuyhoach;
            });
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterWidget(
          title: "Bộ lọc quy hoạch",
          fields: {
            "Loại quy hoạch": ["Quy hoạch hạ tầng đô thị", "Đất nông nghiệp", "Đất công nghiệp"], // 🔥 Hiển thị "Loại Đất"
            "Trang Thái Sử Dụng": ["Đang thực hiện", "Chưa sử dụng", "Bỏ trống", "Đang xây dựng"],
          },
          isModal: true,
          initialFilters: Map.from(_selectedFilters),
          onFilterChanged: (filters) {
            // 🔥 Chuyển đổi tên hiển thị thành key thực tế khi gửi API
            final Map<String, String?> mappedFilters = {};
            if (filters.containsKey("Loại quy hoạch")) {
              mappedFilters["LoaiQuyhoach"] = filters["Loại quy hoạch"];
            }
            if (filters.containsKey("Trang Thái Sử Dụng")) {
              mappedFilters["TrangThai"] = filters["Trang Thái Sử Dụng"];
            }

            setState(() {
              _selectedFilters = mappedFilters;
            });
            _applyFilters();
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
        title: Text("Quản lý quy hoạch",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBarWidget(controller: _searchController, onSearch: (keyword) => _onSearchChanged()
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadQuyhoach,
              ),
              IconButton(
                onPressed: _showFilterDialog,
                icon: Icon(Icons.filter_list),
                color: Colors.black,
              ),


            ],
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("⚠️ Lỗi: $_errorMessage"))
                : _filteredQuyhoach.isEmpty
                ? Center(child: Text("Không có thửa đất nào được tìm thấy."))
                : ListView.builder(
              // physics: BouncingScrollPhysics(),
                itemCount: _filteredQuyhoach.length,
                itemBuilder: (context, index) {
                final quyHoach = _filteredQuyhoach[index];
                return QuyHoachCard(
                  quyHoach: quyHoach,
                  onDelete: () => _deleteQuyhoach(quyHoach.quyhoachID),
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

  Future<void> _deleteQuyhoach(int quyhoachID) async {
    bool success = await QuyHoachService().deleteQuyHoach(quyhoachID);
    if(!mounted) return;
    if (success) {
      setState(() {
        _dsQuyhoach.removeWhere((qh) => qh.quyhoachID == quyhoachID);
        _filteredQuyhoach = _dsQuyhoach;
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