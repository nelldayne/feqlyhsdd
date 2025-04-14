import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/taikhoan_serviecs.dart';

class updateTaikhoanScreen extends StatefulWidget {
  final TaiKhoan taiKhoan;

  const updateTaikhoanScreen({super.key, required this.taiKhoan});

  @override
  State<updateTaikhoanScreen> createState() => _UpdateTaikhoanScreenState();
}

class _UpdateTaikhoanScreenState extends State<updateTaikhoanScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController tenDangNhapController;
  late TextEditingController matKhauController;
  late TextEditingController emailController;
  late TextEditingController soDienThoaiController;
  late TextEditingController vaiTroController;
  late TextEditingController ngayTaoController;
  late TextEditingController trangThaiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String formatNgay(String? ngay) {
    try {
      if (ngay == null || ngay.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngay).toLocal(); // Chuyển sang giờ địa phương
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không có thông tin'; // Nếu lỗi, trả về thông báo lỗi
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    tenDangNhapController = TextEditingController(text: widget.taiKhoan.tenDangNhap);
    matKhauController = TextEditingController(text: widget.taiKhoan.matKhau ?? ''); // Ẩn mật khẩu trong giao diện
    emailController = TextEditingController(text: widget.taiKhoan.email ?? '');
    soDienThoaiController = TextEditingController(text: widget.taiKhoan.soDienThoai ?? '');
    vaiTroController = TextEditingController(text: widget.taiKhoan.vaiTro ?? '');
    ngayTaoController = TextEditingController(text: formatNgay(widget.taiKhoan.ngayTao.toString()));
    trangThaiController = TextEditingController(text: widget.taiKhoan.trangThai);
  }

  @override
  void dispose() {
    _animationController.dispose();
    tenDangNhapController.dispose();
    matKhauController.dispose();
    emailController.dispose();
    soDienThoaiController.dispose();
    vaiTroController.dispose();
    ngayTaoController.dispose();
    trangThaiController.dispose();
    super.dispose();
  }

  Future<void> _updateTaikhoan() async {
    if (!_formKey.currentState!.validate()) return;

    TaiKhoan updatedTaikhoan = TaiKhoan(
      taikhoanID: widget.taiKhoan.taikhoanID,
      tenDangNhap: tenDangNhapController.text,
      matKhau: matKhauController.text.isNotEmpty ? matKhauController.text : widget.taiKhoan.matKhau, // Giữ mật khẩu cũ nếu không thay đổi
      email: emailController.text,
      soDienThoai: soDienThoaiController.text,
      vaiTro: vaiTroController.text,
      ngayTao: DateTime.tryParse(ngayTaoController.text) ?? DateTime.now(),
      trangThai: trangThaiController.text,
    );

    try {
      bool success = await TaikhoanServiecs().updateTaikhoan(updatedTaikhoan);

      if (success) {
        showCustomDialog(
          context,
          title: "Thành công",
          message: "Cập nhật tài khoản thành công!",
          isSuccess: true,
        );
        // Đợi người dùng nhấn "Đóng" trong dialog, sau đó quay lại
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        throw Exception("Lỗi không xác định!");
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
          position: AlwaysStoppedAnimation(Offset.zero),
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
              DropdownMenuItem(value: "user", child: Text("Khách hàng")),
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


  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey),
          hintText: controller.text.isEmpty ? 'Chọn ngày' : null,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
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
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toIso8601String().split('T').first; // Định dạng yyyy-MM-dd
            });
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Không được để trống";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa tài khoản",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField("Tên đăng nhập", tenDangNhapController),
                _buildTextField("Email", emailController, isOptional: false),
                _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true, isOptional: false),
                _buildRoleDropdown(),
                _buildDatePickerField("Ngày tạo", ngayTaoController),
                SizedBox(height: 12,),
                _buildStatusDropdown(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateTaikhoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}