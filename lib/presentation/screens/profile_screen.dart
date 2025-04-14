import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Để giải mã JWT
import 'package:jwt_decoder/jwt_decoder.dart'; // Thêm package để giải mã JWT (nếu cần)

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TaiKhoan? _taiKhoan;
  bool _isLoading = true;
  String? _errorMessage;

  late TextEditingController emailController;
  late TextEditingController soDienThoaiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Tăng thời gian animation để mượt mà hơn
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadTaiKhoan(); // Tải thông tin tài khoản khi khởi tạo
  }

  Future<void> _loadTaiKhoan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Không tìm thấy token, vui lòng đăng nhập lại.";
      });
      return;
    }

    try {
      // Giải mã token để lấy taiKhoanID (giả định token là JWT)
      final decodedToken = JwtDecoder.decode(token);
      final taiKhoanId = decodedToken['taikhoanId']; // Trích xuất taiKhoanID từ payload JWT
      if (taiKhoanId == null) {
        throw Exception("Không tìm thấy taiKhoanID trong token.");
      }

      // Fetch thông tin TaiKhoan từ server sử dụng taiKhoanID và token
      final taiKhoan = await _fetchTaiKhoanFromService(token, taiKhoanId); // Thay bằng API thực tế
      setState(() {
        _taiKhoan = taiKhoan;
        emailController = TextEditingController(text: taiKhoan.email);
        soDienThoaiController = TextEditingController(text: taiKhoan.soDienThoai ?? '');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Lỗi tải thông tin tài khoản: ${e.toString()}";
      });
    }
  }

  Future<TaiKhoan> _fetchTaiKhoanFromService(String token, int taiKhoanId) async {
    // Thay bằng logic thực tế từ TaiKhoanService hoặc API
    // Đây là ví dụ giả định, bạn cần thay bằng dữ liệu từ server
    return TaiKhoan(
      taikhoanID: taiKhoanId,
      tenDangNhap: "nguyenvana",
      matKhau: "password123",
      email: "nguyenvana@example.com",
      soDienThoai: "0123456789",
      vaiTro: "user",
      ngayTao: DateTime.now(),
      trangThai: "Hoạt động",
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _taiKhoan == null) return;

    final updatedTaiKhoan = TaiKhoan(
      taikhoanID: _taiKhoan!.taikhoanID, // Giữ nguyên ID
      tenDangNhap: _taiKhoan!.tenDangNhap, // Giữ nguyên tên đăng nhập
      matKhau: _taiKhoan!.matKhau, // Giữ nguyên mật khẩu (không chỉnh sửa trong màn hình này)
      email: emailController.text,
      soDienThoai: soDienThoaiController.text.isNotEmpty ? soDienThoaiController.text : null,
      vaiTro: _taiKhoan!.vaiTro, // Giữ nguyên vai trò
      ngayTao: _taiKhoan!.ngayTao, // Giữ nguyên ngày tạo
      trangThai: _taiKhoan!.trangThai, // Giữ nguyên trạng thái
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");

      // Giả định bạn có service để cập nhật thông tin tài khoản
      final success = await _updateTaiKhoanOnService(token, updatedTaiKhoan); // Thay bằng API thực tế
      if (success && mounted) {
        Navigator.pop(context, updatedTaiKhoan); // Trả về TaiKhoan đã cập nhật khi đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thông tin thành công!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi cập nhật: ${e.toString()}")),
        );
      }
    }
  }

  Future<bool> _updateTaiKhoanOnService(String token, TaiKhoan taiKhoan) async {
    // Thay bằng logic thực tế từ TaiKhoanService hoặc API
    // Đây là ví dụ giả định, trả về true nếu cập nhật thành công
    return true;
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // 1% chiều cao màn hình
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.phone : TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey, fontSize: MediaQuery.textScalerOf(context).scale(16)), // Tùy chỉnh font size
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return "Không được để trống";
              }
              if (label == "Email" && value != null && !value.contains('@')) {
                return "Email không hợp lệ";
              }
              if (label == "Số điện thoại" && value != null && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return "Số điện thoại phải là 10 số";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    soDienThoaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Chỉnh sửa thông tin cá nhân",
          style: TextStyle(
            fontSize: screenWidth * 0.05, // 5% chiều rộng màn hình
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: screenWidth * 0.05, color: Colors.white), // 5% chiều rộng cho icon
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // 4% chiều rộng màn hình
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Text(
                _errorMessage!,
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.red),
              ),
            )
                : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.02), // 2% chiều rộng cho padding
                physics: const ClampingScrollPhysics(), // Tối ưu cuộn
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("Email", emailController),
                    _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true),
                    SizedBox(height: screenHeight * 0.02), // 2% chiều cao màn hình
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1, // 10% chiều cao màn hình
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                          topRight: Radius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            spreadRadius: MediaQuery.of(context).size.width * 0.005, // 0.5% chiều rộng cho spread
                            blurRadius: MediaQuery.of(context).size.width * 0.01, // 1% chiều rộng cho blur
                            offset: Offset(0, -2), // Shadow phía trên để tạo hiệu ứng nổi
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Nút "Lưu" sử dụng Container
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) _updateProfile();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015, // 1.5% chiều cao màn hình
                                    horizontal: screenWidth * 0.06, // 6% chiều rộng màn hình
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.015), // 1.5% chiều rộng cho bo tròn
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withValues(alpha: 0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Lưu",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04, // 4% chiều rộng màn hình
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}