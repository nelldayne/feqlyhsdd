import 'package:flutter/material.dart';
import 'package:qlyhoso/services/thuadat_Services.dart';

class DialogTachThua extends StatefulWidget {
  final int thuadatID; // ID của thửa đất gốc
  final double dienTichBanDau; // Diện tích ban đầu của thửa đất
  final Function(Map<String, dynamic>) onTachThuaAdded;

  const DialogTachThua({
    super.key,
    required this.thuadatID,
    required this.dienTichBanDau,
    required this.onTachThuaAdded,
  });

  @override
  _DialogTachThuaState createState() => _DialogTachThuaState();
}

class _DialogTachThuaState extends State<DialogTachThua> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dienTichController = TextEditingController();
  final TextEditingController bacController = TextEditingController();
  final TextEditingController namController = TextEditingController();
  final TextEditingController dongController = TextEditingController();
  final TextEditingController tayController = TextEditingController();
  final ThuaDatService _thuaDatService = ThuaDatService();

  @override
  void dispose() {
    dienTichController.dispose();
    bacController.dispose();
    namController.dispose();
    dongController.dispose();
    tayController.dispose();
    super.dispose();
  }

  Future<void> _saveTachThua() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      // Có thể thêm trạng thái loading nếu cần
    });

    String ranhGioi =
        "Bắc: ${bacController.text}m, Nam: ${namController.text}m, Đông: ${dongController.text}m, Tây: ${tayController.text}m";
    Map<String, dynamic> newThuaDat = {
      "DienTich": double.tryParse(dienTichController.text) ?? 0.0,
      "Ranhgioi": ranhGioi,
    };

    Map<String, dynamic> tachThuaData = {
      "ThuadatID": widget.thuadatID,
      "DienTichBanDau": widget.dienTichBanDau, // Giữ nguyên diện tích ban đầu
      "newThuadatList": [newThuaDat],
    };

    try {
      bool success = await _thuaDatService.addTachThua(tachThuaData);
      if (success) {
        widget.onTachThuaAdded(tachThuaData);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tách thửa thành công!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi khi tách thửa!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xảy ra lỗi: $e")),
        );
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Không được để trống";
          }
          if (isNumber && double.tryParse(value) == null) {
            return "Vui lòng nhập số hợp lệ";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Tách thửa đất"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hiển thị diện tích ban đầu
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Diện tích ban đầu: ${widget.dienTichBanDau} m²",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                _buildTextField("Diện tích mới (m²)", dienTichController, isNumber: true),
                _buildTextField("Ranh giới Bắc (m)", bacController, isNumber: true),
                _buildTextField("Ranh giới Nam (m)", namController, isNumber: true),
                _buildTextField("Ranh giới Đông (m)", dongController, isNumber: true),
                _buildTextField("Ranh giới Tây (m)", tayController, isNumber: true),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: _saveTachThua,
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}