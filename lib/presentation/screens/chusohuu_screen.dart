import 'package:flutter/material.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/presentation/widgets/create_chusohuu_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/chusohuu_card.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChuSoHuuListScreen extends StatefulWidget {
  const ChuSoHuuListScreen({super.key});

  @override
  ChuSoHuuListScreenState createState() => ChuSoHuuListScreenState();
}

class ChuSoHuuListScreenState extends State<ChuSoHuuListScreen> {
  List<ChuSoHuu> _dsChuSoHuu = [];
  List<ChuSoHuu> _filteredChuSoHuu = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 15;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String?> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _loadChuSoHuu();
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

  Future<void> _loadChuSoHuu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      Map<String, dynamic> response = await ChuSoHuuService().fetchChuSoHuu(
        token,
        limit: _limit,
        page: _currentPage,
        filters: _selectedFilters,
      );

      if (!mounted) return;

      setState(() {
        _dsChuSoHuu = response['data'];
        _filteredChuSoHuu = _dsChuSoHuu;
        _totalPages = (response['total'] / _limit).ceil();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    } if (!mounted) return;
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text.trim();
    if(!mounted) return;
    if (keyword.isEmpty) {
      setState(() {
        _filteredChuSoHuu = _dsChuSoHuu;
      });
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
        final result = await ChuSoHuuService().searchChusohuu(token, {
          'keyword': keyword,
        });

        if (result['success'] == true) {
          setState(() {
            _filteredChuSoHuu = result['data'] ?? [];
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

  void _changePage(int newPage) {
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadChuSoHuu();
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogChuSoHuu(
          onChuSoHuuAdded: (newChuSoHuu) {
            setState(() {
              _dsChuSoHuu.add(newChuSoHuu);
              _filteredChuSoHuu = _dsChuSoHuu;
            });
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadChuSoHuu,
          ),
        ],
        title: Text("Quản lý chủ sở hữu",
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
          SearchBarWidget(controller: _searchController, onSearch: (keyword) => _onSearchChanged()),
          Row(
            children: [

              // IconButton(
              //   onPressed: _showFilterDialog,
              //   icon: Icon(Icons.filter_list),
              //   color: Colors.black,
              // ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("⚠️ Lỗi: $_errorMessage"))
                : _filteredChuSoHuu.isEmpty
                ? Center(child: Text("Không có chủ sở hữu nào được tìm thấy."))
                : ListView.builder(
              itemCount: _filteredChuSoHuu.length,
              itemBuilder: (context, index) {
                final chuSoHuu = _filteredChuSoHuu[index];
                return ChuSoHuuCard(
                  chuSoHuu: chuSoHuu,
                  stt: index + 1,
                  onDelete: () => _deleteChuSoHuu(chuSoHuu.chusohuuID),
                  onExportPDF: () {
                  },
                );
              },
            ),
          ),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.12,
            height: MediaQuery.of(context).size.width * 0.12,
            child: Center(
              child: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
            ),
          ),
      ),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        0,    // Không dịch ngang
        -40, // Dịch lên trên 100 pixel
      ),
    );
  }

  Future<void> _deleteChuSoHuu(int chusohuuID) async {
    bool success = await ChuSoHuuService().deleteChuSoHuu(chusohuuID);
    if(!mounted) return;
    if (success) {
      setState(() {
        _dsChuSoHuu.removeWhere((csh) => csh.chusohuuID == chusohuuID);
        _filteredChuSoHuu = _dsChuSoHuu;
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