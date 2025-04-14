import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chính sách quyền riêng tư"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chính sách quyền riêng tư",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Chúng tôi coi trọng quyền riêng tư của bạn và cam kết bảo vệ thông tin cá nhân của bạn. Chính sách quyền riêng tư này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ dữ liệu của bạn khi bạn sử dụng ứng dụng của chúng tôi.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("1. Thông tin thu thập"),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi có thể thu thập thông tin cá nhân như tên, địa chỉ email, số điện thoại và các thông tin khác khi bạn đăng ký tài khoản hoặc sử dụng dịch vụ của chúng tôi.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("2. Cách chúng tôi sử dụng thông tin"),
            const SizedBox(height: 8),
            Text(
              "Thông tin của bạn được sử dụng để cung cấp, duy trì và cải thiện dịch vụ. Chúng tôi cũng có thể sử dụng thông tin để liên hệ với bạn về các cập nhật và thay đổi quan trọng liên quan đến dịch vụ của chúng tôi.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("3. Bảo mật thông tin"),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn bằng các biện pháp bảo mật hợp lý để tránh việc truy cập trái phép hoặc tiết lộ thông tin.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("4. Quyền của người dùng"),
            const SizedBox(height: 8),
            Text(
              "Bạn có quyền truy cập, sửa đổi và xóa thông tin cá nhân của mình trong hệ thống của chúng tôi. Nếu bạn có bất kỳ câu hỏi nào liên quan đến quyền riêng tư, vui lòng liên hệ với chúng tôi.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("5. Thay đổi chính sách"),
            const SizedBox(height: 8),
            Text(
              "Chính sách quyền riêng tư này có thể được thay đổi theo thời gian. Chúng tôi sẽ thông báo cho bạn về những thay đổi quan trọng qua ứng dụng hoặc email.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Hàm để tạo tiêu đề các phần của chính sách quyền riêng tư
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
