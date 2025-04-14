import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/quyhoach_Serviecs.dart';

class updateQuyhoachScreen extends StatefulWidget {
  final QuyHoach quyHoach;

  const updateQuyhoachScreen({super.key, required this.quyHoach});

  @override
  State<updateQuyhoachScreen> createState() => _UpdateQuyhoachScreenState();
}

class _UpdateQuyhoachScreenState extends State<updateQuyhoachScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController loaiQuyhoachController;
  late TextEditingController thoiGianBatDauController;
  late TextEditingController thoiGianKetThucController;
  late TextEditingController moTaController;
  late TextEditingController trangThaiController;
  late TextEditingController dienTichController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String formatNgay(String? ngay) {
    try {
      if (ngay == null || ngay.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngay).toLocal(); // Chuyển sang giờ địa phương
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không có thông tin'; // Nếu lỗi, trả về thông báo lỗi
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Tăng thời gian animation để mượt mà hơn
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    loaiQuyhoachController = TextEditingController(text: widget.quyHoach.loaiQuyHoach);
    thoiGianBatDauController = TextEditingController(text: formatNgay(widget.quyHoach.thoiGianBatDau?.toIso8601String()));
    thoiGianKetThucController = TextEditingController(text: formatNgay(widget.quyHoach.thoiGianKetThuc.toString()));
    moTaController = TextEditingController(text: widget.quyHoach.moTa);
    trangThaiController = TextEditingController(text: widget.quyHoach.trangThai);
    dienTichController = TextEditingController(text: widget.quyHoach.dienTich.toString());
  }

  @override
  void dispose() {
    _animationController.dispose();
    loaiQuyhoachController.dispose();
    thoiGianBatDauController.dispose();
    thoiGianKetThucController.dispose();
    dienTichController.dispose();
    moTaController.dispose();
    trangThaiController.dispose();
    super.dispose();
  }

  Future<void> _updateQuyhoach() async {
    if (!_formKey.currentState!.validate()) return;

    QuyHoach updatedQuyhoach = QuyHoach(
      quyhoachID: widget.quyHoach.quyhoachID,
      loaiQuyHoach: loaiQuyhoachController.text,
      thoiGianBatDau: DateTime.tryParse(thoiGianBatDauController.text) ?? DateTime.now(),
      thoiGianKetThuc: DateTime.tryParse(thoiGianKetThucController.text) ?? DateTime.now(),
      moTa: moTaController.text,
      trangThai: trangThaiController.text,
      dienTich: double.tryParse(dienTichController.text) ?? 0.0,
    );

    try {
      bool success = await QuyHoachService().updateQuyhoach(updatedQuyhoach);

      if (success) {
        showCustomDialog(context, title: "Thành công", message: "Cập nhật thành công!", isSuccess: true);
      } else {
        throw Exception("Lỗi không xác định!");
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains("Exception:")) {
        errorMsg = errorMsg.replaceFirst("Exception:", "").trim();
      }
      showCustomDialog(
        context,
        title: "Lỗi",
        message: errorMsg,
        isSuccess: false,
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return "Không được để trống";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey),
              hintText: controller.text.isEmpty ? 'Chọn ngày' : null,
              suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blueAccent,
                        onPrimary: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setState(() {
                  controller.text = pickedDate.toIso8601String().split('T').first; // Định dạng yyyy-MM-dd
                });
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Không được để trống";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa quy hoạch",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField("Loại quy hoạch", loaiQuyhoachController),
                _buildTextField("Diện tích", dienTichController),
                _buildDatePickerField("Thời gian bắt đầu", thoiGianBatDauController),
                _buildDatePickerField("Thời gian kết thúc", thoiGianKetThucController),
                _buildTextField("Mô tả", moTaController),
                _buildTextField("Trạng thái", trangThaiController),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
                      child: ElevatedButton(
                        onPressed: _updateQuyhoach,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Lưu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}