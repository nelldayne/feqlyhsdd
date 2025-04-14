import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qlyhoso/data/models/hotro_model.dart';
import 'package:qlyhoso/presentation/widgets/chat_bot_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/hotro_card_nguoidung.dart';
import 'package:qlyhoso/presentation/widgets/hotro_detail_Dialog.dart';
import 'package:qlyhoso/services/hotro_serviecs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


class SupportRequestScreen extends StatefulWidget {
  const SupportRequestScreen({super.key});

  @override
  SupportRequestScreenState createState() => SupportRequestScreenState();
}

class SupportRequestScreenState extends State<SupportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> requests = [];
  List<HoTro> _dsHoTro = [];
  int? _taiKhoanId;
  bool _showChatLabel = true;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<int?> getTaiKhoanId(BuildContext context, Future<String?> Function() getToken) async {
    String? token = await getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy token")),
      );
      return null;
    }

    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final dynamic taiKhoanIdRaw = decodedToken['taikhoanId'];

      int? taiKhoanId;
      if (taiKhoanIdRaw is int) {
        taiKhoanId = taiKhoanIdRaw;
      } else if (taiKhoanIdRaw is String) {
        taiKhoanId = int.tryParse(taiKhoanIdRaw);
      }

      if (taiKhoanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể xác định taiKhoanId")),
        );
      }

      return taiKhoanId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi giải mã token: $e")),
      );
      return null;
    }
  }

  void _submitRequest() async {
    _taiKhoanId = (await getTaiKhoanId(context, _getToken))!;
    if (_formKey.currentState!.validate()) {
      bool success = await HoTroService().createHoTro(
        _messageController.text,
        _taiKhoanId!,
        _phoneController.text,
      );

      if (success) {
        setState(() {
          requests.add({
            "phone": _phoneController.text,
            "message": _messageController.text,
          });
        });
        _phoneController.clear();
        _messageController.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Yêu cầu hỗ trợ đã được gửi!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gửi yêu cầu thất bại, vui lòng thử lại. Bạn cần thêm đầy đủ thông tin"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openChatbot() {
    setState(() {
      _showChatLabel = false; // Hiển thị dòng chữ
    });

    // Ẩn dòng chữ sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showChatLabel = false;
        });
      }
    });

    // Mở chatbot
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotScreen(),
    );
  }
  void _initializeData() async {
    _taiKhoanId = (await getTaiKhoanId(context, _getToken))!;
    if (_taiKhoanId != null) {
      _loaddsHoTro();
    }
  }

  Future<void> _loaddsHoTro() async {
    setState(() {
    });

    try {
      String? token = await _getToken();
      if (token == null) throw Exception("Chưa có token, vui lòng đăng nhập lại.");
      Map<String, dynamic> response = await HoTroService().fetchHoTroByTaikhoanID(_taiKhoanId!);
      if (!mounted) return;

      setState(() {
        _dsHoTro = response['data'];
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
      });
    } finally {
      if (!mounted) return;

      setState(() {
      });
    }
  }

  void _showHoTroDetailDialog(HoTro hoTro) {
    showDialog(
      context: context,
      builder: (context) => HoTroDetailDialog(hoTro: hoTro),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        elevation: 0,
        centerTitle: true,
        actions: [
          Row(
            children: [
              // Dòng chữ hiển thị tạm thời khi nhấn
              if (_showChatLabel)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    "Chat với Bot hỗ trợ",
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingActionButton(
                  onPressed: _openChatbot, // Gọi hàm hiển thị chữ và mở chatbot
                  backgroundColor: const Color(0xFF2196F3),
                  mini: true,
                  child: const Icon(Icons.chat, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_phoneController, "Số điện thoại", Icons.phone),
                      const SizedBox(height: 10),
                      _buildTextField(_messageController, "Nội dung yêu cầu", Icons.message, maxLines: 3),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.send, size: 20),
                        label: const Text("Gửi yêu cầu", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            _dsHoTro.isEmpty
                ? const Center(
              child: Text(
                "Chưa có yêu cầu nào!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dsHoTro.length,
              itemBuilder: (context, index) {
                final hoTro = _dsHoTro[index];
                return HoTroCardND(
                  hoTro: hoTro,
                  onTap: () {
                    _showHoTroDetailDialog(hoTro);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
      ),
    );
  }
}