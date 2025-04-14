import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/quyhoach_Serviecs.dart';

class CreateQuyhoachDialog extends StatefulWidget {
  final Function(QuyHoach) onQuyhoachAdded;

  const CreateQuyhoachDialog({super.key, required this.onQuyhoachAdded});

  @override
  State<CreateQuyhoachDialog> createState() => _CreateQuyhoachDialogState();
}

class _CreateQuyhoachDialogState extends State<CreateQuyhoachDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController loaiQuyhoachController = TextEditingController();
  final TextEditingController thoiGianBatDauController = TextEditingController();
  final TextEditingController thoiGianKetThucController = TextEditingController();
  final TextEditingController moTaController = TextEditingController();
  final TextEditingController trangThaiController = TextEditingController();
  final TextEditingController dienTichController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    loaiQuyhoachController.dispose();
    thoiGianBatDauController.dispose();
    thoiGianKetThucController.dispose();
    moTaController.dispose();
    trangThaiController.dispose();
    dienTichController.dispose();
    super.dispose();
  }

  Future<void> _addQuyhoach() async {
    if (!_formKey.currentState!.validate()) return;

    QuyHoach newQuyhoach = QuyHoach(
      quyhoachID: 0,
      loaiQuyHoach: loaiQuyhoachController.text,
      thoiGianBatDau: DateTime.tryParse(thoiGianBatDauController.text) ?? DateTime.now(),
      thoiGianKetThuc: DateTime.tryParse(thoiGianKetThucController.text) ?? DateTime.now(),
      moTa: moTaController.text,
      trangThai: trangThaiController.text,
      dienTich: double.tryParse(dienTichController.text) ?? 0.0,
    );

    try {
      bool success = await QuyHoachService().addQuyhoach(newQuyhoach);
      if (success) {
        widget.onQuyhoachAdded(newQuyhoach);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm quy hoạch thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Lỗi khi thêm mới!");
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
                      ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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
    return AlertDialog(
      title: const Text(
        "Thêm mới quy hoạch",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField("Loại quy hoạch", loaiQuyhoachController),
                  _buildTextField("Diện tích", dienTichController),
                  _buildDatePickerField("Thời gian bắt đầu", thoiGianBatDauController),
                  _buildDatePickerField("Thời gian kết thúc", thoiGianKetThucController),
                  _buildTextField("Mô tả", moTaController),
                  _buildTextField("Trạng thái", trangThaiController),
                ],
              ),
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
              child: ElevatedButton(
                onPressed: _addQuyhoach,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}