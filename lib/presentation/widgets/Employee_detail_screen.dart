import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String formatNgaysinh(String? ngaySinh) {
    try {
      if (ngaySinh == null || ngaySinh.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngaySinh).toLocal(); // Chuyển sang giờ địa phương
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
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Chi tiết nhân viên",
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("Tài khoản", widget.employee.taikhoanid.toString()),
                _buildDetailRow("Họ tên", widget.employee.hoten),
                _buildDetailRow("Ngày sinh", formatNgaysinh(widget.employee.ngaysinh.toString())),
                _buildDetailRow("Giới tính", widget.employee.gioitinh ?? 'Không có thông tin'),
                _buildDetailRow("Phòng ban", widget.employee.phongban ?? 'Không có'),
                _buildDetailRow("Số điện thoại", widget.employee.sodienthoai ?? 'Không có thông tin'),
                _buildDetailRow("Email", widget.employee.email ?? 'Không có thông tin'),
                _buildDetailRow("Trạng thái", widget.employee.trangthai ?? 'Không có'),
              ],
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Đóng",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              softWrap: true, // Cho phép xuống dòng tự động
              overflow: TextOverflow.visible, // Hiển thị toàn bộ text, không cắt
              textAlign: TextAlign.left, // Căn trái để text dễ đọc hơn
            ),
          ),
        ],
      ),
    );
  }
}