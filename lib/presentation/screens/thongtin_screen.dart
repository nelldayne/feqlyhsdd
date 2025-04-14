import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qlyhoso/presentation/screens/baocaothongke_screen.dart';
import 'package:qlyhoso/presentation/screens/chusohuu_screen.dart';
import 'package:qlyhoso/presentation/screens/hotro_screen.dart';
import 'package:qlyhoso/presentation/screens/lichhop_screen.dart';
import 'package:qlyhoso/presentation/screens/login_screen.dart';
import 'package:qlyhoso/presentation/screens/nhanvien_screen.dart';
import 'package:qlyhoso/presentation/screens/profile_screen.dart';
import 'package:qlyhoso/presentation/screens/qltk_screen.dart';
import 'package:qlyhoso/presentation/screens/quanly_screen.dart';
import 'package:qlyhoso/presentation/screens/quyhoach_screen.dart';
import 'package:qlyhoso/presentation/screens/setting_Screen.dart';
import 'package:qlyhoso/services/auth_services.dart';
import 'package:qlyhoso/services/taikhoan_serviecs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThongtinScreen extends StatefulWidget {
  const ThongtinScreen({super.key});

  @override
  State<ThongtinScreen> createState() => _ThongtinScreenState();
}

class _ThongtinScreenState extends State<ThongtinScreen> {
  String vaiTro = "Đang tải...";
  String hoTen = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _loadVaiTro();
  }

  Future<void> _loadVaiTro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      if (mounted) { // Check mounted before setState
        setState(() {
          vaiTro = "Không xác định";
          hoTen = "Chưa cập nhật";
        });
      }
      return;
    }

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final dynamic taiKhoanIdRaw = decodedToken['taikhoanId'];

    int? taiKhoanId;
    if (taiKhoanIdRaw is int) {
      taiKhoanId = taiKhoanIdRaw;
    } else if (taiKhoanIdRaw is String) {
      taiKhoanId = int.tryParse(taiKhoanIdRaw);
    }

    if (taiKhoanId == null) {
      if (mounted) { // Check mounted before setState
        setState(() {
          vaiTro = "Không xác định";
          hoTen = "Chưa cập nhật";
        });
      }
      return;
    }

    String? savedVaiTro = prefs.getString("vaiTro");
    String savedHoten = "Chưa cập nhật"; // Giá trị mặc định

    final response = await TaikhoanServiecs().getHoTen(taiKhoanId);

    if (response is String) { // Đảm bảo response là String
      savedHoten = response;
    }

    if (mounted) { // Check mounted before setState
      setState(() {
        vaiTro = savedVaiTro ?? "Không xác định";
        hoTen = savedHoten;
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận đăng xuất"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _handleLogout(context); // Thực hiện đăng xuất
              },
              child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Auth_login_Service logoutService = Auth_login_Service();
    var result = await logoutService.logout();
    if (!context.mounted) return; // Check if context is still mounted
    if (result["success"]) {
      // Hiển thị thông báo đăng xuất thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng xuất thành công"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Hiển thị trong 2 giây
        ),
      );
      // Use SchedulerBinding to ensure navigation happens after the frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Check mounted before navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm kiểm tra vai trò và trả về danh sách các button chức năng phù hợp
  List<Widget> _getRoleBasedButtons(BuildContext context) {
    List<Widget> buttons = [];
    switch (vaiTro.toLowerCase()) { // Chuyển vaiTro về chữ thường để so sánh
      case "admin":
      // Admin có toàn quyền truy cập tất cả chức năng
        buttons.addAll([
          _buildNavButton(context, const QuanLyTaiKhoanScreen(), Icons.account_circle, "Tài khoản", 0.4),
          _buildNavButton(context, const QuanLyScreen(), Icons.people_alt, "Quản lý", 0.4),
          _buildNavButton(context, EmployeeListScreen(), Icons.people, "Nhân viên", 0.4),
          _buildNavButton(context, const ChuSoHuuListScreen(), Icons.home, "Chủ hộ", 0.4),
          _buildNavButton(context, const QuyHoachListScreen(), Icons.map, "Quy hoạch", 0.4),
          _buildNavButton(context, const StatisticsScreen(), Icons.add_chart, "Thống kê", 0.4),
          _buildNavButton(context, const HoTroScreen(), Icons.support_agent, "Khách hàng", 0.4),
          _buildNavButton(context, const LichHopScreen(), Icons.access_alarm_sharp, "Lịch họp", 0.4),
        ]);
        break;

      case "manager":
      // Quản lý có quyền truy cập một số chức năng quan trọng
        buttons.addAll([
          _buildNavButton(context, EmployeeListScreen(), Icons.people, "Nhân viên", 0.4),
          _buildNavButton(context, const ChuSoHuuListScreen(), Icons.home, "Chủ hộ", 0.4),
          _buildNavButton(context, const HoTroScreen(), Icons.support_agent, "Khách hàng", 0.4),
          _buildNavButton(context, const StatisticsScreen(), Icons.add_chart, "Thống kê", 0.4),
        ]);
        break;

      case "employee":
      // Nhân viên chỉ có quyền truy cập các chức năng cơ bản
        buttons.addAll([
          _buildNavButton(context, const ChuSoHuuListScreen(), Icons.home, "Chủ hộ", 0.4),
          _buildNavButton(context, const StatisticsScreen(), Icons.add_chart, "Thống kê", 0.4),
          _buildNavButton(context, const HoTroScreen(), Icons.support_agent, "Khách hàng", 0.4),
        ]);
        break;

      default:
        buttons.add(const SizedBox.shrink());
        break;
    }

    List<Widget> rows = [];
    for (int i = 0; i < buttons.length; i += 2) {
      if (i + 1 < buttons.length) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // Khoảng cách 1% chiều cao màn hình
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [buttons[i], buttons[i + 1]],
            ),
          ),
        );
      } else {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // Khoảng cách 1% chiều cao màn hình
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buttons[i]],
            ),
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildNavButton(BuildContext context, Widget screen, IconData icon, String label, double widthPercentage) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthPercentage, // Sử dụng phần trăm chiều rộng
      child: ElevatedButton(
        onPressed: () {
          if (mounted) { // Check mounted before navigation
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.03, // 3% chiều cao màn hình
            horizontal: MediaQuery.of(context).size.width * 0.05, // 5% chiều rộng màn hình
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02)), // 2% chiều rộng cho bo tròn
          elevation: 2, // Thêm shadow nhẹ
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: MediaQuery.of(context).size.width * 0.07, color: Colors.blueAccent), // 7% chiều rộng cho icon
            SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Khoảng cách 3% chiều rộng
            Text(
              label,
              style: TextStyle(
                fontSize: MediaQuery.textScalerOf(context).scale(15), // Tùy chỉnh font size dựa trên tỷ lệ text
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(""),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Padding 4% chiều rộng màn hình
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.1, // 10% chiều cao màn hình
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                    topRight: Radius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bọc khu vực hình ảnh và thông tin bằng GestureDetector để chuyển sang ProfileScreen
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02), // Padding 2% chiều rộng
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) { // Already checked, looks good
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfileScreen()),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15, // 15% chiều rộng màn hình
                              height: MediaQuery.of(context).size.width * 0.15, // 15% chiều rộng màn hình (giữ tỷ lệ)
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage('assets/hinh-anh-avatar-nu.jpg'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.3), // Fixed withValues to withOpacity
                                    spreadRadius: MediaQuery.of(context).size.width * 0.005, // 0.5% chiều rộng cho spread
                                    blurRadius: MediaQuery.of(context).size.width * 0.01, // 1% chiều rộng cho blur
                                    offset: Offset(0, MediaQuery.of(context).size.height * 0.005), // 0.5% chiều cao cho shadow
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.05), // Khoảng cách 5% chiều rộng
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hoTen,
                                  style: TextStyle(
                                    fontSize: MediaQuery.textScalerOf(context).scale(15), // Tùy chỉnh font size dựa trên tỷ lệ text
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  vaiTro,
                                  style: TextStyle(
                                    fontSize: MediaQuery.textScalerOf(context).scale(15), // Tùy chỉnh font size dựa trên tỷ lệ text
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (mounted) { // Add mounted check before navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingScreen()),
                          );
                        }
                      },
                      icon: Icon(Icons.settings, size: MediaQuery.of(context).size.width * 0.06, color: Colors.blueAccent), // 6% chiều rộng cho icon
                    ),
                  ],
                ),
              ),
              Divider(
                height: MediaQuery.of(context).size.height * 0.02, // 2% chiều cao màn hình
                color: Colors.grey,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Khoảng cách 3% chiều cao màn hình
              Text(
                "Chức năng chính",
                style: TextStyle(
                  fontSize: MediaQuery.textScalerOf(context).scale(20), // Tùy chỉnh font size dựa trên tỷ lệ text
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015), // Khoảng cách 1.5% chiều cao màn hình
              ..._getRoleBasedButtons(context), // Hiển thị các button dựa trên vai trò
              SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Khoảng cách 3% chiều cao màn hình
              Divider(
                height: MediaQuery.of(context).size.height * 0.02, // 2% chiều cao màn hình
                color: Colors.grey,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015), // Khoảng cách 1.5% chiều cao màn hình
              _buildLogoutButton(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedButton(
        onPressed: () => _showLogoutConfirmationDialog(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.1,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3), // Fixed withValues to withOpacity
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Đăng xuất",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.logout, size: 24, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedButton({super.key, required this.onPressed, required this.child});

  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}