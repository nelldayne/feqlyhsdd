import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/taikhoan_serviecs.dart';

class createTaikhoanDialog extends StatefulWidget {
  final Function(TaiKhoan) onTaikhoanAdded;

  const createTaikhoanDialog({super.key, required this.onTaikhoanAdded});

  @override
  State<createTaikhoanDialog> createState() => _CreateTaikhoanDialogState();
}

class _CreateTaikhoanDialogState extends State<createTaikhoanDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController tenDangNhapController = TextEditingController();
  final TextEditingController matKhauController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController vaiTroController = TextEditingController();
  final TextEditingController trangThaiController = TextEditingController();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    tenDangNhapController.dispose();
    matKhauController.dispose();
    emailController.dispose();
    soDienThoaiController.dispose();
    vaiTroController.dispose();
    trangThaiController.dispose();
    super.dispose();
  }

  Future<String> hashPassword(String password) async {
    const saltRounds = 10; // Số vòng lặp salt, giá trị phổ biến để cân bằng giữa bảo mật và hiệu suất
    return await BCrypt.hashpw(password, BCrypt.gensalt(logRounds: saltRounds)); // Sử dụng bcrypt để băm mật khẩu
  }

  Future<void> _addTaikhoan() async {
    if (!_formKey.currentState!.validate()) return;

    TaiKhoan newTaikhoan = TaiKhoan(
      taikhoanID: 0,
      tenDangNhap: tenDangNhapController.text,
      matKhau: await hashPassword(matKhauController.text),
      email: emailController.text,
      soDienThoai: soDienThoaiController.text,
      vaiTro: vaiTroController.text,
      ngayTao: DateTime.now(),
      trangThai: trangThaiController.text,
    );

    try {
      bool success = await TaikhoanServiecs().addTaikhoan(newTaikhoan);
      if (success) {
        widget.onTaikhoanAdded(newTaikhoan);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm tài khoản thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Lỗi khi thêm mới!");

      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains("Exception:")) {
        errorMsg = errorMsg.replaceFirst("Exception:", "").trim();
      }
      showCustomDialog(
        context,
        title: "Lỗi",
        message: errorMsg,
        isSuccess: false,
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            obscureText: obscureText, // Ẩn text nếu là mật khẩu
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return "Không được để trống";
              }
              if (label == "Email" && value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Email không hợp lệ";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DropdownButtonFormField<String>(
        value: trangThaiController.text.isNotEmpty ? trangThaiController.text : null,
        decoration: InputDecoration(
          labelText: "Trạng thái",
          labelStyle: TextStyle(color: Colors.blueGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        items: const [
          DropdownMenuItem(value: "HoatDong", child: Text("Hoạt động")),
          DropdownMenuItem(value: "Chuakichhoat", child: Text("Chưa kích hoạt")),
          DropdownMenuItem(value: "BiKhoa", child: Text("Đã khóa")),
        ],
        onChanged: (value) {
          setState(() {
            trangThaiController.text = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Vui lòng chọn trạng thái";
          }
          return null;
        },
      ),
    );
  }




  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: DropdownButtonFormField<String>(
            value: vaiTroController.text.isNotEmpty ? vaiTroController.text : null,
            decoration: InputDecoration(
              labelText: "Vai trò",
              labelStyle: TextStyle(color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "admin", child: Text("Admin")),
              DropdownMenuItem(value: "manager", child: Text("Quản lý")),
              DropdownMenuItem(value: "employee", child: Text("Nhân viên")),
            ],
            onChanged: (value) {
              setState(() {
                vaiTroController.text = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng chọn vai trò";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Thêm mới tài khoản",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9, // Giảm chiều rộng để phù hợp hơn
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField("Tên tài khoản", tenDangNhapController),
                  _buildTextField("Mật khẩu", matKhauController, obscureText: true),
                  _buildTextField("Email", emailController, isOptional: false),
                  _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true, isOptional: false),
                  _buildRoleDropdown(),
                  _buildStatusDropdown(),
                ],
              ),
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
              child: ElevatedButton(
                onPressed: _addTaikhoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}