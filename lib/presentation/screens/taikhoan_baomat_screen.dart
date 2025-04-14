import 'package:flutter/material.dart';

class TaikhoanBaomatScreen extends StatefulWidget {
  const TaikhoanBaomatScreen({super.key});

  @override
  State<TaikhoanBaomatScreen> createState() => _TaikhoanBaomatScreenState();
}

class _TaikhoanBaomatScreenState extends State<TaikhoanBaomatScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController matKhauCuController = TextEditingController();
  final TextEditingController matKhauMoiController = TextEditingController();

  @override
  void dispose() {
    matKhauCuController.dispose();
    matKhauMoiController.dispose();
    super.dispose();
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
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        title: Text("Thông tin và bảo mật"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            _buildTextField(Icons.lock, 'Mật khẩu cũ', matKhauCuController, obscureText: true),
            _buildTextField(Icons.lock_outline, 'Mật khẩu mới', matKhauMoiController, obscureText: true),

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
            const SizedBox(height: 30),

            Text(
              'Chính Sách Bảo Mật',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Chúng tôi cam kết bảo vệ quyền riêng tư của bạn. ...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '1. Thu thập thông tin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Chúng tôi có thể thu thập các thông tin như tên, email, số điện thoại...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. Sử dụng thông tin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Thông tin được sử dụng để cải thiện dịch vụ, liên hệ hỗ trợ...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. Bảo vệ thông tin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Chúng tôi áp dụng các biện pháp bảo mật để bảo vệ thông tin của bạn...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. Liên hệ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Nếu có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi qua email...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
