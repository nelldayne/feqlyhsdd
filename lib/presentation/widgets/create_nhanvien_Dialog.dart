import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import '../../services/nhanvien_services.dart';

class CreatedNhanvienDialog extends StatefulWidget {
  final Function(Employee) onEmployeeAdded;

  const CreatedNhanvienDialog({super.key, required this.onEmployeeAdded});

  @override
  State<CreatedNhanvienDialog> createState() => _CreatedNhanvienDialogState();
}

class _CreatedNhanvienDialogState extends State<CreatedNhanvienDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController taikhoanIDController = TextEditingController();
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController ngaySinhController = TextEditingController();
  final TextEditingController gioiTinhController = TextEditingController();
  final TextEditingController phongBanController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    Employee newEmployee = Employee(
      id: 0,
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
      bool success = await EmployeeService().addEmployee(newEmployee);
      if (success) {
        widget.onEmployeeAdded(newEmployee);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm nhân viên thành công!"),
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
              labelStyle: TextStyle(color: Colors.black),
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
    return AlertDialog(
      title: const Text(
        "Thêm mới nhân viên",
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
                  _buildTextField("Mã tài khoản", taikhoanIDController, isNumber: true),
                  _buildTextField("Họ và tên", hoTenController),
                  _buildTextField("Ngày sinh", ngaySinhController),
                  _buildTextField("Giới tính", gioiTinhController),
                  _buildTextField("Phòng ban", phongBanController),
                  _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true, isOptional: false),
                  _buildTextField("Email", emailController, isOptional: false),
                  _buildTextField("Trạng thái", trangThaiController),
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
                onPressed: _addEmployee,
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