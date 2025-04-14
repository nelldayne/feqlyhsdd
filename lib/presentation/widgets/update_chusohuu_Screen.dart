import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import '../widgets/thongbao_Dialog.dart';

class UpdateChuSoHuuScreen extends StatefulWidget {
  final ChuSoHuu chuSoHuu;

  const UpdateChuSoHuuScreen({super.key, required this.chuSoHuu});

  @override
  _UpdateChuSoHuuScreenState createState() => _UpdateChuSoHuuScreenState();
}

class _UpdateChuSoHuuScreenState extends State<UpdateChuSoHuuScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController hoTenController;
  late TextEditingController ngaySinhController;
  late TextEditingController gioiTinhController;
  late TextEditingController soCMND_CCCDController;
  late TextEditingController ngayCapController;
  late TextEditingController noiCapController;
  late TextEditingController diaChiThuongTruController;
  late TextEditingController diaChiLienHeController;
  late TextEditingController soDienThoaiController;
  late TextEditingController emailController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 800), // Tăng thời gian animation để mượt mà hơn
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    hoTenController = TextEditingController(text: widget.chuSoHuu.hoTen);
    ngaySinhController = TextEditingController(text: formatNgay(widget.chuSoHuu.ngaySinh.toString()));
    gioiTinhController = TextEditingController(text: widget.chuSoHuu.gioiTinh ?? "");
    soCMND_CCCDController = TextEditingController(text: widget.chuSoHuu.soCMND_CCCD);
    ngayCapController = TextEditingController(text: formatNgay(widget.chuSoHuu.ngayCap.toString()));
    noiCapController = TextEditingController(text: widget.chuSoHuu.noiCap ?? "");
    diaChiThuongTruController = TextEditingController(text: widget.chuSoHuu.diaChiThuongTru);
    diaChiLienHeController = TextEditingController(text: widget.chuSoHuu.diaChiLienHe ?? "");
    soDienThoaiController = TextEditingController(text: widget.chuSoHuu.soDienThoai ?? "");
    emailController = TextEditingController(text: widget.chuSoHuu.email ?? "");
  }

  @override
  void dispose() {
    _animationController.dispose();
    hoTenController.dispose();
    ngaySinhController.dispose();
    gioiTinhController.dispose();
    soCMND_CCCDController.dispose();
    ngayCapController.dispose();
    noiCapController.dispose();
    diaChiThuongTruController.dispose();
    diaChiLienHeController.dispose();
    soDienThoaiController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _updateChuSoHuu() async {
    if (!_formKey.currentState!.validate()) return;

    ChuSoHuu updatedChuSoHuu = ChuSoHuu(
      chusohuuID: widget.chuSoHuu.chusohuuID,
      hoTen: hoTenController.text,
      ngaySinh: DateTime.tryParse(ngaySinhController.text) ?? DateTime.now(),
      gioiTinh: gioiTinhController.text,
      soCMND_CCCD: soCMND_CCCDController.text,
      ngayCap: DateTime.tryParse(ngayCapController.text) ?? DateTime.now(),
      noiCap: noiCapController.text,
      diaChiThuongTru: diaChiThuongTruController.text,
      diaChiLienHe: diaChiLienHeController.text,
      soDienThoai: soDienThoaiController.text,
      email: emailController.text,
    );

    try {
      bool success = await ChuSoHuuService().updateChuSoHuu(updatedChuSoHuu);
      print(success);
      if (success) {
        showCustomDialog(
          context,
          title: "Thành công",
          message: "Cập nhật thông tin chủ sở hữu thành công!",
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

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cập nhật Chủ Sở Hữu",
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
                _buildTextField("Họ và tên", hoTenController),
                _buildDatePickerField("Ngày sinh", ngaySinhController),
                _buildTextField("Giới tính", gioiTinhController),
                _buildTextField("Số CMND/CCCD", soCMND_CCCDController),
                _buildDatePickerField("Ngày cấp", ngayCapController),
                _buildTextField("Nơi cấp", noiCapController),
                _buildTextField("Địa chỉ thường trú", diaChiThuongTruController),
                _buildTextField("Địa chỉ liên hệ", diaChiLienHeController),
                _buildTextField("Số điện thoại", soDienThoaiController, isNumber: true),
                _buildTextField("Email", emailController),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
                      child: ElevatedButton(
                        onPressed: _updateChuSoHuu,
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