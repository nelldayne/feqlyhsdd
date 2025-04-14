import 'package:flutter/material.dart';
import '../../services/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  /// 🛠 **Xử lý đăng ký**
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      var response = await Auth_register_Service().register(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      setState(() => _isLoading = false);
      if(!mounted) return;
      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"]),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Lỗi không xác định!"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối API: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa màu sắc
    const Color primaryWhite = Colors.white;
    const Color accentBlue = Colors.teal; // Màu xanh nước biển nhạt

    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1), // Màu nền trắng
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: const Text(
          "Đăng Ký Tài Khoản",
          style: TextStyle(
            color: primaryWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0, // Loại bỏ bóng dưới AppBar
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trường Tên đăng nhập
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Tên đăng nhập",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: accentBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập tên đăng nhập" : null,
                ),
                const SizedBox(height: 20),

                // Trường Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  ),
                  obscureText: true,
                  validator: (value) =>
                  value!.length < 6 ? "Mật khẩu ít nhất 6 ký tự" : null,
                ),
                const SizedBox(height: 20),

                // Trường Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: accentBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  ),
                  validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(value!)
                      ? "Email không hợp lệ"
                      : null,
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: accentBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                ),
                const SizedBox(height: 20),
                // Nút Đăng ký
                _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentBlue),
                )
                    : ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Nền xanh nước biển
                    foregroundColor: primaryWhite, // Chữ trắng
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // Đổ bóng nhẹ
                  ),
                  child: const Text(
                    "Đăng Ký",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}