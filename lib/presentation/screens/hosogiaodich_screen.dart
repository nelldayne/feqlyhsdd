import 'package:flutter/material.dart';
import 'package:qlyhoso/components/filter_component.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:qlyhoso/presentation/widgets/create_Hoso_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/hoso_card.dart';
import 'package:qlyhoso/presentation/widgets/update_Hosodatdai_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/hosodatdai_serviecs.dart';
import '../../components/search_bar.dart';

class HoSoScreen extends StatefulWidget {
  const HoSoScreen({super.key});

  @override
  HoSoScreenState createState() => HoSoScreenState();
}

class HoSoScreenState extends State<HoSoScreen> with SingleTickerProviderStateMixin {
  List<HoSoDatDai> _dsHoSo = [];
  List<HoSoDatDai> _filteredHoSo = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 15;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String?> _selectedFilters = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Animation cho toàn bộ nội dung
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _loadHoSo();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _loadHoSo() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
      Map<String, dynamic> response = await HoSoDatDaiService().fetchHoSoDatDai(
        token,
        limit: _limit,
        page: _currentPage,
        filters: _selectedFilters,
      );

      if (!mounted) return;

      setState(() {
        _dsHoSo = response['data'] ?? [];
        _filteredHoSo = _dsHoSo;
        _totalPages = ((response['total'] ?? 0) / _limit).ceil();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Lỗi tải dữ liệu: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    if (!mounted) return;
  }

  void _showFilterDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return FilterWidget(
              title: "Bộ lọc hồ sơ đất đai",
              fields: {
                "Loại Hồ Sơ": ["Đất đai 2", "Hồ sơ chuyển nhượng", "Hồ sơ quy hoạch"],
                "Tình Trạng Hồ Sơ": ["Chờ xử lý", "Đã phê duyệt", "Từ chối", "Hoàn thành"],
                "Trạng Thái": ["Hoạt động", "Ngưng hoạt động", "Tạm thời"],
              },
              isModal: true,
              initialFilters: Map.from(_selectedFilters), // Truyền bộ lọc hiện tại
              onFilterChanged: (filters) {
                if (mounted) {
                  // Ánh xạ tên hiển thị sang key thực tế cho API
                  final Map<String, String?> mappedFilters = {};
                  if (filters.containsKey("Loại Hồ Sơ")) {
                    mappedFilters["LoaiHoSo"] = filters["Loại Hồ Sơ"];
                  }
                  if (filters.containsKey("Tình Trạng Hồ Sơ")) {
                    mappedFilters["TinhTrangHoSo"] = filters["Tình Trạng Hồ Sơ"];
                  }
                  if (filters.containsKey("Trạng Thái")) {
                    mappedFilters["TrangThai"] = filters["Trạng Thái"];
                  }

                  setState(() {
                    _selectedFilters = mappedFilters;
                  });
                  _applyFilters();
                }
              },
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    if (mounted) {
      _loadHoSo(); // Gọi API với _selectedFilters đã cập nhật
    }
  }

  void _onSearchChanged() async {
    if (!mounted) return;

    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _filteredHoSo = _dsHoSo;
      });
      _loadHoSo(); // Gọi lại API để tải dữ liệu gốc nếu không có từ khóa
    } else {
      try {
        String? token = await _getToken();
        if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

        final result = await HoSoDatDaiService().searchHoso(token, {
          'keyword': keyword,
        });

        if (result['success'] == true) {
          if (mounted) {
            setState(() {
              _filteredHoSo = result['data'] ?? [];
              _dsHoSo = _filteredHoSo; // Cập nhật danh sách gốc khi tìm kiếm
              _totalPages = 1; // Reset trang khi tìm kiếm, giả định API trả về 1 trang
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Lỗi tìm kiếm dữ liệu')),
            );
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xảy ra lỗi: $error')),
          );
        }
      }
    }
  }

  void _changePage(int newPage) {
    if (mounted && newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _loadHoSo();
    }
  }

  void _showAddDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return CreateHoSoDialog(
          onHoSoAdded: (newHoso) {
            if (mounted) {
              setState(() {
                _dsHoSo.add(newHoso);
                _filteredHoSo = _dsHoSo;
              });
            }
          },
        );
      },
    );
  }

  void _updateDetailDialog(HoSoDatDai hoSoDatDai) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return UpdateHoSoDialog(
          hoSoDatDai: hoSoDatDai,
          onUpdatehoSo: () {
            if (mounted) {
              _loadHoSo(); // Gọi reloadThuaDat để tải lại danh sách từ server
            }
          },
        );
      },
    );
  }

  Future<void> _deleteHoSo(int hosoID) async {
    if (!mounted) return;

    bool success = await HoSoDatDaiService().deleteHoSoDatDai(hosoID);
    if (success && mounted) {
      setState(() {
        _dsHoSo.removeWhere((hs) => hs.hosodatdaiID == hosoID);
        _filteredHoSo = _dsHoSo;
      });
      _loadHoSo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thành công!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại!")),
      );
    }
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
              fontSize: MediaQuery.of(context).textScaler.scale(16),
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

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container(); // Trả về Container rỗng nếu widget đã bị hủy
    final double fabSize = MediaQuery.of(context).size.width * 0.12;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        title: SearchBarWidget(
          controller: _searchController,
          onSearch: (keyword) => _onSearchChanged(),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
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
                    icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.06), // 6% chiều rộng cho icon
                    onPressed: () {
                      if (mounted) _loadHoSo();
                    },
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04), // Khoảng cách 4% chiều rộng
                  IconButton(
                    onPressed: () {
                      if (mounted) _showFilterDialog();
                    },
                    icon: Icon(Icons.filter_list, size: MediaQuery.of(context).size.width * 0.06, color: Colors.black), // 6% chiều rộng cho icon
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  "⚠️ Lỗi: $_errorMessage",
                  style: TextStyle(fontSize: MediaQuery.of(context).textScaler.scale(16)), // Tùy chỉnh font size
                ),
              )
                  : _filteredHoSo.isEmpty
                  ? Center(
                child: Text(
                  "Không có hồ sơ nào được tìm thấy.",
                  style: TextStyle(fontSize: MediaQuery.of(context).textScaler.scale(16)), // Tùy chỉnh font size
                ),
              )
                  : ListView.builder(
                itemCount: _filteredHoSo.length,
                itemBuilder: (context, index) {
                  final hoSoDatDai = _filteredHoSo[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.005), // 0.5% chiều cao cho khoảng cách
                    child: HoSoCard(
                      hoSoDatDai: hoSoDatDai,
                      onDelete: () {
                        if (mounted) _deleteHoSo(hoSoDatDai.hosodatdaiID);
                      },
                      onUpdate: () => _updateDetailDialog(hoSoDatDai),
                      onExportPDF: () {
                      },
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
            onPressed: () {
              if (mounted) _showAddDialog();
            },
            child: Center(
              child: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
            ), // 6% chiều rộng cho icon
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