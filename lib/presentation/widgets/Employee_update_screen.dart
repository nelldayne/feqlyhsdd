import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/nhanvien_services.dart';

class updateEmployeeScreen extends StatefulWidget {
  final Employee emPloyee;

  const updateEmployeeScreen({super.key, required this.emPloyee});

  @override
  State<updateEmployeeScreen> createState() => _UpdateEmployeeScreenState();
}

class _UpdateEmployeeScreenState extends State<updateEmployeeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController taikhoanIDController;
  late TextEditingController hoTenController;
  late TextEditingController ngaySinhController;
  late TextEditingController gioiTinhController;
  late TextEditingController phongBanController;
  late TextEditingController soDienThoaiController;
  late TextEditingController emailController;
  late TextEditingController trangThaiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String formatNgaysinh(String? ngaySinh) {
    try {
      if (ngaySinh == null || ngaySinh.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngaySinh).toLocal(); // Chuyển sang giờ địa phương
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
      duration: const Duration(milliseconds: 800), // Tăng thời gian animation để mượt mà hơn
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    taikhoanIDController = TextEditingController(text: widget.emPloyee.taikhoanid.toString());
    hoTenController = TextEditingController(text: widget.emPloyee.hoten);
    ngaySinhController = TextEditingController(text: formatNgaysinh(widget.emPloyee.ngaysinh.toIso8601String()));
    gioiTinhController = TextEditingController(text: widget.emPloyee.gioitinh);
    phongBanController = TextEditingController(text: widget.emPloyee.phongban);
    soDienThoaiController = TextEditingController(text: widget.emPloyee.sodienthoai);
    emailController = TextEditingController(text: widget.emPloyee.email);
    trangThaiController = TextEditingController(text: widget.emPloyee.trangthai);
  }

  @override
  void dispose() {
    _animationController.dispose();
    taikhoanIDController.dispose();
    hoTenController.dispose();
    ngaySinhController.dispose();
    gioiTinhController.dispose();
    phongBanController.dispose();
    soDienThoaiController.dispose();
    emailController.dispose();
    trangThaiController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    Employee updatedEmployee = Employee(
      id: widget.emPloyee.id,
      taikhoanid: int.tryParse(taikhoanIDController.text) ?? 0,
      hoten: hoTenController.text,
      ngaysinh: DateTime.tryParse(ngaySinhController.text) ?? DateTime.now(),
      gioitinh: gioiTinhController.text,
      phongban: phongBanController.text,
      sodienthoai: soDienThoaiController.text,
      email: emailController.text,
      trangthai: trangThaiController.text,
    );

    try {
      bool success = await EmployeeService().updateEmployee(updatedEmployee);

      if (success) {
        showCustomDialog(
          context,
          title: "Thành công",
          message: "Cập nhật thành công!",
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa nhân viên",
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
                _buildTextField("Tài khoản", taikhoanIDController, isNumber: true, isOptional: true),
                _buildTextField("Họ tên", hoTenController),
                _buildTextField("Ngày sinh", ngaySinhController),
                _buildTextField("Giới tính", gioiTinhController),
                _buildTextField("Phòng ban", phongBanController, isOptional: true),
                _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true, isOptional: false),
                _buildTextField("Email", emailController, isOptional: false),
                _buildTextField("Trạng thái", trangThaiController),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
                      child: ElevatedButton(
                        onPressed: _updateEmployee,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}