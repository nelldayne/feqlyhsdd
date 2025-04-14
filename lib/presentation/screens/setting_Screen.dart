import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget { // Chuyển sang Stateful để quản lý trạng thái
  const SettingScreen({super.key});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  bool _isDarkMode = false; // Biến để lưu trạng thái Dark Mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text("Cài đặt chung",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tùy chỉnh",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SwitchListTile( // Chuyển đổi Dark Mode
                  title: const Text("Chế độ tối", style: TextStyle(fontSize: 18)),
                  value: _isDarkMode,
                  activeColor: Colors.lightBlue,
                  onChanged: (bool value) {
                    setState(() {
                      _isDarkMode = value; // Cập nhật trạng thái
                    });
                    // Thêm logic để thay đổi theme nếu cần
                  },
                ),
                const Divider(), // Đường phân cách

                /// 🔹 **Cài đặt ngôn ngữ**
                ListTile(
                  title: const Text("Ngôn ngữ", style: TextStyle(fontSize: 18)),
                  subtitle: const Text("Tiếng Việt"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Thêm logic để mở màn hình chọn ngôn ngữ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chức năng chọn ngôn ngữ đang phát triển!")),
                    );
                  },
                ),
                const Divider(),

                /// 🔹 **Nút hành động**
                const SizedBox(height: 20),
                /// 🔹 **Thông tin hệ thống**
                const SizedBox(height: 20),
                const Text(
                  "Hệ Thống Quản Lý Hồ Sơ",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("Phiên bản: 1.0.0", style: TextStyle(fontSize: 18)),
                const Text("Nhà phát triển: Nell Nguyen", style: TextStyle(fontSize: 18)),
                const Text("Liên hệ: ansernell52@gmail.com", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}