import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:async';
import 'package:qlyhoso/constrain/images_path.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/widgets/create_chusohuu_nguoidung_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/thuadat_card_for_nguoidung.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import 'package:qlyhoso/services/thuadat_Services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeUserScreen> {
  List<ThuaDat> _dsThuaDat = [];
  late PageController _pageController;
  late Timer _autoSlideTimer;
  var _currentPage = 0;
  int? _taiKhoanId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _startAutoSlide();
    _initializeData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer.cancel();
    super.dispose();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  void _initializeData() async {
    _taiKhoanId = await getTaiKhoanId(context, _getToken);
    if (_taiKhoanId != null) {
      _loadThongtin();
      _loadThuaDat();
    }
  }

  Future<int?> getTaiKhoanId(BuildContext context, Future<String?> Function() getToken) async {
    String? token = await getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy token")),
      );
      return null;
    }

    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final dynamic taiKhoanIdRaw = decodedToken['taikhoanId'];

      int? taiKhoanId;
      if (taiKhoanIdRaw is int) {
        taiKhoanId = taiKhoanIdRaw;
      } else if (taiKhoanIdRaw is String) {
        taiKhoanId = int.tryParse(taiKhoanIdRaw);
      }

      if (taiKhoanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể xác định taiKhoanId")),
        );
      }

      return taiKhoanId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi giải mã token: $e")),
      );
      return null;
    }
  }

  Future<void> _loadThongtin() async {
    _taiKhoanId = await getTaiKhoanId(context, _getToken);
    if (_taiKhoanId == null) return;
    try {
      final hasOwner = await ChuSoHuuService().checkOwnerInfo(_taiKhoanId!);
      if(!mounted) return;
      if (!hasOwner) {
        setState(() {});
        _showAddOwnerDialog(context);
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    }
  }

  Future<void> _loadThuaDat() async {
    setState(() {});

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
      Map<String, dynamic> response = await ThuaDatService().fetchThuadatByTaikhoanID(_taiKhoanId!);
      if (!mounted) return;

      setState(() {
        _dsThuaDat = response['data'];
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {});
    } finally {
      if (!mounted) return;

      setState(() {});
    }
  }

  void _showAddOwnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddOwnerDialog(
        taiKhoanId: _taiKhoanId!,
        onSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    if (_autoSlideTimer.isActive) {
      _autoSlideTimer.cancel();
    }
  }

  void _resumeAutoSlide() {
    if (mounted) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted && _pageController.hasClients) {
          int nextPage = (_currentPage + 1) % 4;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            ImagesPath.logo,
            height: 32,
          ),
        ),
        title: const Text(
          "Huyện Đại Từ",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Badge(
              child: const Icon(
                Icons.notifications,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: GestureDetector(
                onTapDown: (_) => _stopAutoSlide(),
                onTapUp: (_) => _resumeAutoSlide(),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildImageSlide(
                      "https://th.bing.com/th/id/OIP.5CygFmQHpJXL38OVnO7VKwHaE2?w=261&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7",
                      "Thửa Đất",
                      "Thông tin về số lượng thửa đất đang quản lý.",
                    ),
                    _buildImageSlide(
                      "https://th.bing.com/th/id/OIP.3FjekWbKhdyPscVeBn3etwHaFj?rs=1&pid=ImgDetMain",
                      "Hồ Sơ Giao Dịch",
                      "Số lượng hồ sơ giao dịch đã được xử lý.",
                    ),
                    _buildImageSlide(
                      "https://cdn.thuvienphapluat.vn/uploads/tintuc/2024/01/18/luat-dat-dai-2024.jpg",
                      "Chủ Sở Hữu",
                      "Tổng số chủ sở hữu đã đăng ký.",
                    ),
                    _buildImageSlide(
                      "https://cdn.thuvienphapluat.vn/uploads/tintuc/2024/01/18/luat-dat-dai-2024.jpg",
                      "Chủ Sở Hữu",
                      "Tổng số chủ sở hữu đã đăng ký.",
                    ),
                  ],
                ),
              ),
            ),
            // Tiêu đề danh sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Các Thửa Đất Sở Hữu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "(${_dsThuaDat.length} thửa)",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách thửa đất
            _dsThuaDat.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Chưa có thửa đất nào được đăng ký.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dsThuaDat.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 16,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  itemBuilder: (context, index) {
                    final thuaDat = _dsThuaDat[index];
                    return ThuaDatCardKH(
                      thuaDat: thuaDat,
                    );
                  },
                ),
            const SizedBox(height: 16), // Khoảng cách cuối danh sách
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlide(String imageUrl, String title, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}