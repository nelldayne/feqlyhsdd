import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import '../../services/nhanvien_services.dart';

class EmployeeForm extends StatefulWidget {
  final Map<String, dynamic>? employeeData; // Dữ liệu nhân viên khi chỉnh sửa

  const EmployeeForm({super.key, this.employeeData});

  @override
  EmployeeFormState createState() => EmployeeFormState();
}

class EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _service = EmployeeService();

  late TextEditingController _taikhoanidController;
  late TextEditingController _hotenController;
  late TextEditingController _ngaysinhController;
  late TextEditingController _phongbanController;
  late TextEditingController _trangthaiController;
  late TextEditingController _emailController;
  late TextEditingController _sodienthoaiController;
  late TextEditingController _gioitinhController;

  @override
  void initState() {
    super.initState();
    _taikhoanidController = TextEditingController(
        text: widget.employeeData?['taikhoanid']?.toString() ?? '');
    _hotenController =
        TextEditingController(text: widget.employeeData?['hoten'] ?? '');
    _ngaysinhController = TextEditingController(
        text: widget.employeeData?['ngaysinh'] ?? '');
    _gioitinhController =
        TextEditingController(text: widget.employeeData?['gioitinh'] ?? '');
    _phongbanController =
        TextEditingController(text: widget.employeeData?['phongban'] ?? '');
    _sodienthoaiController =
        TextEditingController(text: widget.employeeData?['sodienthoai'] ?? '');
    _emailController =
        TextEditingController(text: widget.employeeData?['email'] ?? '');
    _trangthaiController =
        TextEditingController(text: widget.employeeData?['trangthai'] ?? '');
  }

  @override
  void dispose() {
    _hotenController.dispose();
    _emailController.dispose();
    _sodienthoaiController.dispose();
    _phongbanController.dispose();
    _taikhoanidController.dispose();
    _gioitinhController.dispose();
    _trangthaiController.dispose();
    _ngaysinhController.dispose();
    super.dispose();
  }

  // 🟢 Lưu dữ liệu (Thêm/Sửa)
  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newEmployee = Employee(
          id: widget.employeeData?['id'] ?? 0,
          taikhoanid: int.tryParse(_taikhoanidController.text) ?? 0, // Sửa lỗi kiểu dữ liệu
          email: _emailController.text,
          sodienthoai: _sodienthoaiController.text,
          gioitinh: _gioitinhController.text,
          hoten: _hotenController.text,
          ngaysinh: DateTime.tryParse(_ngaysinhController.text) ?? DateTime.now(), // Sửa lỗi kiểu DateTime
          phongban: _phongbanController.text,
          trangthai: _trangthaiController.text,
        );

        if (widget.employeeData == null) {
          await _service.addEmployee(newEmployee); // Gửi API thêm mới
        } else {
          await _service.updateEmployee(newEmployee); // Gửi API cập nhật
        }
        if(!mounted) return;
        Navigator.pop(context, newEmployee.toJson()); // Trả về dữ liệu sau khi thêm/sửa
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.employeeData == null ? "Thêm Nhân Viên" : "Chỉnh Sửa Nhân Viên"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _hotenController,
                  decoration: InputDecoration(labelText: "Họ và Tên"),
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập tên" : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập email" : null,
                ),
                TextFormField(
                  controller: _sodienthoaiController,
                  decoration: InputDecoration(labelText: "Số Điện Thoại"),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                ),
                TextFormField(
                  controller: _ngaysinhController,
                  decoration: InputDecoration(labelText: "Ngày Sinh (YYYY-MM-DD)"),
                  keyboardType: TextInputType.datetime,
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập ngày sinh" : null,
                ),
                TextFormField(
                  controller: _trangthaiController,
                  decoration: InputDecoration(labelText: "Trạng Thái"),
                  validator: (value) =>
                  value!.isEmpty ? "Vui lòng nhập trạng thái" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveEmployee,
                  child: Text(widget.employeeData == null
                      ? "Thêm Nhân Viên"
                      : "Lưu Thay Đổi"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
