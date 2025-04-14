import 'package:flutter/material.dart';
import 'package:qlyhoso/presentation/screens/home.dart';
import 'package:qlyhoso/presentation/screens/homeuser.dart';
import 'package:qlyhoso/presentation/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      var response = await Auth_login_Service().login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (response["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString("token") ?? "";
        String vaiTro = prefs.getString("vaiTro") ?? "";
        if(!mounted) return;
        if (token.isNotEmpty && vaiTro.isNotEmpty) {
          Widget nextScreen = (vaiTro == "user") ? UserHome() : Home();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lỗi: Không lấy được thông tin đăng nhập!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đăng nhập: ${e.toString().replaceAll('Exception:', '').trim()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  "Đăng Nhập Hệ Thống",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 2,),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                  Icons.person, color: Colors.blueAccent),
                              labelText: 'Tên đăng nhập',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) =>
                            value!.isEmpty
                                ? "Vui lòng nhập tên đăng nhập"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                  Icons.lock, color: Colors.blueAccent),
                              labelText: 'Mật khẩu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) =>
                            value!.isEmpty
                                ? "Vui lòng nhập mật khẩu"
                                : null,
                          ),
                          const SizedBox(height: 30),
                          _isLoading
                              ? CircularProgressIndicator(
                              color: Colors.blueAccent)
                              : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Đăng Nhập",
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Đăng nhập với",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/vn1-1686496502327408255654.jpg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đăng nhập với VNeID",
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()), // Điều hướng đến màn hình đăng ký
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Chưa có tài khoản? ",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Đăng ký ngay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
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