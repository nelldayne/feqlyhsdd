import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "Làm thế nào để đăng nhập vào ứng dụng?",
      "answer":
      "Để đăng nhập, bạn chỉ cần nhập tên đăng nhập và mật khẩu đã đăng ký vào các trường tương ứng trên màn hình đăng nhập."
    },
    {
      "question": "Tôi quên mật khẩu, phải làm sao?",
      "answer":
      "Bạn có thể sử dụng chức năng 'Quên mật khẩu' trên màn hình đăng nhập để lấy lại mật khẩu của mình."
    },
    {
      "question": "Làm cách nào để thay đổi thông tin cá nhân?",
      "answer":
      "Để thay đổi thông tin cá nhân, vào mục 'Hồ sơ' trong tài khoản của bạn và chọn 'Chỉnh sửa thông tin'."
    },
    {
      "question": "Làm sao để liên hệ với bộ phận hỗ trợ?",
      "answer":
      "Bạn có thể liên hệ với bộ phận hỗ trợ qua email hoặc số điện thoại có trong phần 'Hỗ trợ'."
    },
  ];

  FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Câu hỏi thường gặp (FAQ)"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              title: Text(
                faqs[index]["question"]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    faqs[index]["answer"]!,
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
