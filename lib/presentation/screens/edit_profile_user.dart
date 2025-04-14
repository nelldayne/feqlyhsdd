import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController hoTenController = TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController ngaySinhController = TextEditingController();
  final TextEditingController gioiTinhController = TextEditingController();
  final TextEditingController soCMNDCCCDController = TextEditingController();
  final TextEditingController ngayCapController = TextEditingController();
  final TextEditingController noiCapController = TextEditingController();
  final TextEditingController diaChiThuongTruController = TextEditingController();
  final TextEditingController diaChiLienHeController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController emailController = TextEditingController(text: 'example@gmail.com');

  @override
  void dispose() {
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

  Widget _buildTextField(IconData icon, String label, TextEditingController controller,
      {bool obscureText = false, bool isOptional = false, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: isDate,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
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
          suffixIcon: isDate ? IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
            onPressed: () => _selectDate(context, controller),
          ) : null,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin', style: TextStyle(color: Colors.blue)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('assets/hinh-anh-avatar-nu.jpg'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Chỉnh sửa ảnh', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(Icons.email, 'Email', emailController),
              _buildTextField(Icons.person, 'Họ và Tên', hoTenController),
              _buildTextField(Icons.calendar_today, 'Ngày sinh', ngaySinhController, isDate: true),
              _buildTextField(Icons.wc, 'Giới tính', gioiTinhController),
              _buildTextField(Icons.credit_card, 'Số CMND/CCCD', soCMNDCCCDController),
              _buildTextField(Icons.calendar_today, 'Ngày cấp', ngayCapController, isDate: true),
              _buildTextField(Icons.location_city, 'Nơi cấp', noiCapController),
              _buildTextField(Icons.home, 'Địa chỉ thường trú', diaChiThuongTruController),
              _buildTextField(Icons.location_on, 'Địa chỉ liên hệ', diaChiLienHeController),
              _buildTextField(Icons.phone, 'Số điện thoại', soDienThoaiController),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Xử lý lưu thông tin (có thể gọi API tại đây)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thông tin đã được cập nhật')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}