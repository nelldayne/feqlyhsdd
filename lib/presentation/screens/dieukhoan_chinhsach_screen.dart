import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Điều khoản và Điều kiện"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Điều khoản và Điều kiện",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Chào mừng bạn đến với ứng dụng của chúng tôi! Trước khi sử dụng ứng dụng, vui lòng đọc kỹ các điều khoản và điều kiện sau. Khi bạn sử dụng ứng dụng, bạn đồng ý tuân thủ các điều khoản và điều kiện này.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("1. Chấp nhận điều khoản"),
            const SizedBox(height: 8),
            Text(
              "Bằng cách sử dụng ứng dụng của chúng tôi, bạn đồng ý tuân theo các điều khoản và điều kiện này. Nếu bạn không đồng ý với bất kỳ phần nào trong các điều khoản này, vui lòng ngừng sử dụng ứng dụng ngay lập tức.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("2. Thay đổi điều khoản"),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi có quyền thay đổi, cập nhật hoặc bổ sung các điều khoản này bất kỳ lúc nào mà không cần thông báo trước. Việc bạn tiếp tục sử dụng ứng dụng sau khi điều khoản được cập nhật có nghĩa là bạn chấp nhận các thay đổi đó.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("3. Trách nhiệm của người dùng"),
            const SizedBox(height: 8),
            Text(
              "Bạn có trách nhiệm tuân thủ tất cả các luật lệ hiện hành khi sử dụng ứng dụng. Bạn không được sử dụng ứng dụng để phát tán các nội dung bất hợp pháp, gây tổn hại hoặc phá hoại.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("4. Quyền sở hữu trí tuệ"),
            const SizedBox(height: 8),
            Text(
              "Tất cả các nội dung, thương hiệu và tài liệu khác trên ứng dụng đều thuộc sở hữu của chúng tôi hoặc bên thứ ba có liên quan. Bạn không được sao chép, tái sử dụng hoặc phân phối bất kỳ nội dung nào mà không có sự cho phép bằng văn bản từ chủ sở hữu.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("5. Miễn trừ trách nhiệm"),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi không chịu trách nhiệm về bất kỳ thiệt hại nào phát sinh từ việc sử dụng ứng dụng, bao gồm nhưng không giới hạn ở việc mất dữ liệu hoặc thiệt hại phần mềm/hệ thống.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Hàm để tạo tiêu đề các phần của điều khoản
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
