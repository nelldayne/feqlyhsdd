import 'package:flutter/material.dart';
import 'package:qlyhoso/components/filter_component.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/screens/map_screen.dart';
import 'package:qlyhoso/presentation/widgets/create_thuadat_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/hopthua_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/thuadat_card.dart';
import 'package:qlyhoso/presentation/widgets/thuadat_update_detailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/thuadat_Services.dart';

class ThuaDatListScreen extends StatefulWidget {
  const ThuaDatListScreen({super.key});

  @override
  ThuaDatListScreenState createState() => ThuaDatListScreenState();
}

class ThuaDatListScreenState extends State<ThuaDatListScreen> with SingleTickerProviderStateMixin {
  List<ThuaDat> _dsThuaDat = [];
  List<ThuaDat> _filteredThuaDat = [];
  int _totalThuaDat = 0;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 20;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String?> _selectedFilters = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _loadThuaDat();
    _searchController.addListener(_onSearchChanged);
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadThuaDat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      Map<String, dynamic> response = await ThuaDatService().fetchThuadat(
        token,
        limit: _limit,
        page: _currentPage,
        searchQuery: _searchController.text.trim(),
        filters: _selectedFilters,
      );

      if (!mounted) return;

      setState(() {
        _dsThuaDat = response['data'];
        _filteredThuaDat = _dsThuaDat;
        _totalPages = (response['total'] / _limit).ceil();
        _totalThuaDat = response['total'];
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

  void reloadThuaDat() {
    _loadThuaDat();
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _filteredThuaDat = _dsThuaDat;
      });
      _loadThuaDat(); // Gọi lại để lấy tổng số toàn bộ từ API gốc
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
        final result = await ThuaDatService().searchThuadat(token, {
          'keyword': keyword,
        });
        if (!mounted) return;
        if (result['success'] == true) {
          setState(() {
            _filteredThuaDat = result['data'] ?? [];
            _dsThuaDat = _filteredThuaDat;
            _totalPages = 1; // Giả định tìm kiếm không phân trang
            _totalThuaDat = result['total'] ?? _totalThuaDat; // Cập nhật tổng số nếu API trả về
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

  void _changePage(int newPage) {
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadThuaDat();
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return createDialogThuaDat(
          onThuaDatAdded: (newThuaDat) {
            setState(() {
              _dsThuaDat.add(newThuaDat);
              _filteredThuaDat = _dsThuaDat;
            });
          },
        );
      },
    );
  }

  void _applyFilters() {
    _loadThuaDat();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FilterWidget(
              title: "Bộ lọc thửa đất",
              fields: {
                "Loại Đất": ["Đất ở", "Đất nông nghiệp", "Đất công nghiệp"],
                "Trang Thái Sử Dụng": ["Đang sử dụng", "Chưa sử dụng", "Bỏ trống", "Đang xây dựng"],
                "Tình Trạng Pháp Lý": ["Đã cấp Sổ đỏ", "Chưa cấp Sổ đỏ"],
                "Sắp xếp theo": ["Diện tích tăng dần", "Diện tích giảm dần"],
              },
              isModal: true,
              initialFilters: Map.from(_selectedFilters), // Truyền bộ lọc hiện tại
              onFilterChanged: (filters) {
                // Ánh xạ tên hiển thị sang key thực tế cho API
                final Map<String, String?> mappedFilters = {};
                if (filters.containsKey("Loại Đất")) {
                  mappedFilters["LoaiDat"] = filters["Loại Đất"];
                }
                if (filters.containsKey("Trang Thái Sử Dụng")) {
                  mappedFilters["TrangThaiSuDung"] = filters["Trang Thái Sử Dụng"];
                }
                if (filters.containsKey("Tình Trạng Pháp Lý")) {
                  mappedFilters["TinhTrangPhapLy"] = filters["Tình Trạng Pháp Lý"];
                }
                if (filters.containsKey("Sắp xếp theo")) {
                  final sortOption = filters["Sắp xếp theo"];
                  if (sortOption == "Diện tích tăng dần") {
                    mappedFilters["sortDirection"] = "asc";
                  } else if (sortOption == "Diện tích giảm dần") {
                    mappedFilters["sortDirection"] = "desc";
                  }
                }

                setState(() {
                  _selectedFilters = mappedFilters;
                });

                _applyFilters(); // Gọi API để lấy dữ liệu đã lọ
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteThuaDat(int thuadatID) async {
    bool success = await ThuaDatService().deleteThuaDat(thuadatID);
    if(!mounted) return;
    if (success) {
      setState(() {
        _dsThuaDat.removeWhere((td) => td.thuadatID == thuadatID);
        _filteredThuaDat = _dsThuaDat;
      });
      _loadThuaDat();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại!")),
      );
    }
  }
  void _updateDetailDialog(ThuaDat thuaDat) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return updateThuaDatDetailDialog(
          thuaDat: thuaDat,
          onThuaDatUpdated: () {
            if (mounted) {
              _loadThuaDat();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fabSize = MediaQuery.of(context).size.width * 0.12;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        title: SearchBarWidget(controller: _searchController, onSearch: (keyword) => _onSearchChanged()),
        backgroundColor: Colors.blue,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01, // 1% chiều cao màn hình
                horizontal: MediaQuery.of(context).size.width * 0.04, // 4% chiều rộng màn hình
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.06),
                    onPressed: _loadThuaDat,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  IconButton(
                    onPressed: _showFilterDialog,
                    icon: Icon(Icons.filter_list, size: MediaQuery.of(context).size.width * 0.06, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                      );
                    },
                    icon: Icon(Icons.location_on),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => HopthuaDialog(
                          onHopThua: (selectedList) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Đã chọn hợp thửa: Thửa ${selectedList[0].thuadatID} và Thửa ${selectedList[1].thuadatID}"),
                              ),
                            );
                            _loadThuaDat(); // Tải lại danh sách sau khi hợp thửa
                          },
                        ),
                      );
                    },
                    child: const Text("Hợp thửa"),
                  ),
                ],
              ),
            ),
            // Hiển thị tổng số toàn bộ thửa đất
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              child: Text(
                "Tổng số thửa đất: $_totalThuaDat",
                style: TextStyle(
                  fontSize: MediaQuery.textScalerOf(context).scale(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  "⚠️ Lỗi: $_errorMessage",
                  style: TextStyle(fontSize: MediaQuery.textScalerOf(context).scale(16)),
                ),
              )
                  : _filteredThuaDat.isEmpty
                  ? Center(
                child: Text(
                  "Không có thửa đất nào được tìm thấy.",
                  style: TextStyle(fontSize: MediaQuery.textScalerOf(context).scale(16)),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredThuaDat.length,
                itemBuilder: (context, index) {
                  final thuaDat = _filteredThuaDat[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.005),
                    child: ThuaDatCard(
                      thuaDat: thuaDat,
                      stt: index + 1,
                      onDelete: () => _deleteThuaDat(thuaDat.thuadatID),
                      onUpdate: () => _updateDetailDialog(thuaDat),
                      onExportPDF: () {},
                      tachThua: () {},
                    ),
                  );
                },
              ),
            ),
            _buildPaginationControls(),
          ],
        ),
      ),
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: fabSize,  // Đặt chiều rộng dựa trên tỷ lệ màn hình
          height: fabSize,
          child: FloatingActionButton(
            onPressed: _showAddDialog,
            child: Center(
              child: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01, // 1% chiều cao màn hình
        horizontal: MediaQuery.of(context).size.width * 0.04, // 4% chiều rộng màn hình
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.first_page, size: MediaQuery.of(context).size.width * 0.05), // 5% chiều rộng cho icon
            onPressed: _currentPage > 1 ? () => _changePage(1) : null,
            color: _currentPage > 1 ? Colors.blueAccent : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.chevron_left, size: MediaQuery.of(context).size.width * 0.05), // 5% chiều rộng cho icon
            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
            color: _currentPage > 1 ? Colors.blueAccent : Colors.grey,
          ),
          Text(
            "Trang $_currentPage / $_totalPages",
            style: TextStyle(
              fontSize: MediaQuery.textScalerOf(context).scale(16), // Tùy chỉnh font size
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: MediaQuery.of(context).size.width * 0.05), // 5% chiều rộng cho icon
            onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
            color: _currentPage < _totalPages ? Colors.blueAccent : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.last_page, size: MediaQuery.of(context).size.width * 0.05), // 5% chiều rộng cho icon
            onPressed: _currentPage < _totalPages ? () => _changePage(_totalPages) : null,
            color: _currentPage < _totalPages ? Colors.blueAccent : Colors.grey,
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