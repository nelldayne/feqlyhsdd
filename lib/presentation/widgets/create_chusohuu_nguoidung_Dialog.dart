import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';

class AddOwnerDialog extends StatefulWidget {
  final int taiKhoanId;
  final VoidCallback onSuccess;

  const AddOwnerDialog({
    super.key,
    required this.taiKhoanId,
    required this.onSuccess,
  });

  @override
  AddOwnerDialogState createState() => AddOwnerDialogState();
}

class AddOwnerDialogState extends State<AddOwnerDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // 🎯 Các controller cho dữ liệu chủ sở hữu
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController ngaySinhController = TextEditingController();
  final TextEditingController gioiTinhController = TextEditingController();
  final TextEditingController soCMNDCCCDController = TextEditingController();
  final TextEditingController ngayCapController = TextEditingController();
  final TextEditingController noiCapController = TextEditingController();
  final TextEditingController diaChiThuongTruController = TextEditingController();
  final TextEditingController diaChiLienHeController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    hoTenController.dispose();
    ngaySinhController.dispose();
    gioiTinhController.dispose();
    soCMNDCCCDController.dispose();
    ngayCapController.dispose();
    noiCapController.dispose();
    diaChiThuongTruController.dispose();
    diaChiLienHeController.dispose();
    soDienThoaiController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first; // Định dạng yyyy-MM-dd
      });
    }
  }

  Future<void> _addChuSoHuu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    ChuSoHuu newChuSoHuu = ChuSoHuu(
      taikhoanID: widget.taiKhoanId,
      chusohuuID: 0,
      hoTen: hoTenController.text,
      ngaySinh: DateTime.parse(ngaySinhController.text),
      gioiTinh: gioiTinhController.text,
      soCMND_CCCD: soCMNDCCCDController.text,
      ngayCap: DateTime.parse(ngayCapController.text),
      noiCap: noiCapController.text,
      diaChiThuongTru: diaChiThuongTruController.text,
      diaChiLienHe: diaChiLienHeController.text,
      soDienThoai: soDienThoaiController.text,
      email: emailController.text,
    );

    try {
      final success = await ChuSoHuuService().addChuSoHuu(newChuSoHuu);
      if (!mounted) return;
      if (success) {
        widget.onSuccess();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã lưu thông tin chủ sở hữu"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi lưu thông tin")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isOptional = false}) {
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
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return "Không được để trống";
              }
              if (label == "Số điện thoại" && value != null && value.isNotEmpty && !RegExp(r'^(0[1-9][0-9]{8,9})$').hasMatch(value)) {
                return "Số điện thoại không hợp lệ (10-11 số bắt đầu bằng 0)";
              }
              if (label == "Email" && value != null && value.isNotEmpty && !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Email không hợp lệ";
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
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              hintText: controller.text.isEmpty ? 'Chọn ngày' : null,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            onTap: () => _selectDate(context, controller),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Không được để trống";
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
        "Thêm thông tin chủ sở hữu",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue, // Màu xanh biển
        ),
      ),
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField("Họ và Tên", hoTenController),
                  _buildDatePickerField("Ngày sinh", ngaySinhController),
                  _buildTextField("Giới tính", gioiTinhController),
                  _buildTextField("Số CMND/CCCD", soCMNDCCCDController),
                  _buildDatePickerField("Ngày cấp", ngayCapController),
                  _buildTextField("Nơi cấp", noiCapController),
                  _buildTextField("Địa chỉ thường trú", diaChiThuongTruController),
                  _buildTextField("Địa chỉ liên hệ", diaChiLienHeController),
                  _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true),
                  _buildTextField("Email", emailController, isOptional: true),
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
      backgroundColor: Colors.white, // Màu chủ đạo: trắng
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
              scale: 1.0 + (_animationController.value * 0.05), // Hiệu ứng scale nhẹ
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addChuSoHuu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Màu xanh biển
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
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