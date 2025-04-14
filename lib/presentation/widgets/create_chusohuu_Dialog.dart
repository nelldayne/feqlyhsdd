import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import '../../services/chusohuu_serviecs.dart';

class DialogChuSoHuu extends StatefulWidget {
  final Function(ChuSoHuu) onChuSoHuuAdded;

  const DialogChuSoHuu({super.key, required this.onChuSoHuuAdded});

  @override
  DialogChuSoHuuState createState() => DialogChuSoHuuState();
}

class DialogChuSoHuuState extends State<DialogChuSoHuu> with SingleTickerProviderStateMixin {
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

  Future<void> _addChuSoHuu() async {
    if (!_formKey.currentState!.validate()) return;

    ChuSoHuu newChuSoHuu = ChuSoHuu(
      chusohuuID: 0,
      hoTen: hoTenController.text,
      ngaySinh: DateTime.tryParse(ngaySinhController.text) ?? DateTime.now(),
      gioiTinh: gioiTinhController.text,
      soCMND_CCCD: soCMNDCCCDController.text,
      ngayCap: DateTime.tryParse(ngayCapController.text) ?? DateTime.now(),
      noiCap: noiCapController.text,
      diaChiThuongTru: diaChiThuongTruController.text,
      diaChiLienHe: diaChiLienHeController.text,
      soDienThoai: soDienThoaiController.text,
      email: emailController.text,
    );

    try {
      bool success = await ChuSoHuuService().addChuSoHuu(newChuSoHuu);
      if(!mounted) return;
      if (success) {
        widget.onChuSoHuuAdded(newChuSoHuu);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm chủ sở hữu thành công!"),
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
      // Hiển thị thông báo lỗi với nút "Xác nhận" và đóng dialog khi nhấn
      showCustomDialog(
        context,
        title: "Lỗi",
        message: errorMsg,
        isSuccess: false,
        onConfirm: () => Navigator.of(context).pop(), // Đóng dialog lỗi
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
                      ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Thêm mới chủ sở hữu",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
                onPressed: _addChuSoHuu,
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