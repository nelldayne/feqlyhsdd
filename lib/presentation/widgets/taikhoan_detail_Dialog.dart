import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';

class TaikhoanDetailDialog extends StatefulWidget {
  final TaiKhoan taiKhoan;

  const TaikhoanDetailDialog({super.key, required this.taiKhoan});

  @override
  _TaikhoanDetailDialogState createState() => _TaikhoanDetailDialogState();
}

class _TaikhoanDetailDialogState extends State<TaikhoanDetailDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  String getFormattedVaiTro(String vaiTro) {
    switch (vaiTro.toLowerCase()) {
      case 'admin':
        return 'Quản trị viên (Quyền quản lý toàn hệ thống)';
      case 'employee':
        return 'Nhân viên (Quyền truy cập cơ bản)';
      case 'manager':
        return 'Điều hành viên (Quyền kiểm duyệt nội dung)';
      case 'user':
        return 'Chủ hộ (Khách hàng)';
      default:
        return 'Vai trò không xác định: $vaiTro';
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Chi tiết tài khoản",
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
                _buildDetailRow("Tên đăng nhập", widget.taiKhoan.tenDangNhap),
                _buildDetailRow("Email", widget.taiKhoan.email),
                _buildDetailRow("Số điện thoại", widget.taiKhoan.soDienThoai ?? 'Không có thông tin'),
                _buildEnhancedVaiTroRow(),
                _buildDetailRow("Trạng thái", widget.taiKhoan.trangThai),
                _buildDetailRow("Ngày tạo", formatNgay(widget.taiKhoan.ngayTao.toString())),
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
  Widget _buildEnhancedVaiTroRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final formattedVaiTro = getFormattedVaiTro(widget.taiKhoan.vaiTro);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02), // 2% chiều rộng màn hình
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Vai trò:",
              style: TextStyle(
                fontSize: screenWidth * 0.04, // 4% chiều rộng màn hình
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getVaiTroIcon(widget.taiKhoan.vaiTro), // Thêm icon cho vai trò
                  size: screenWidth * 0.04, // 4% chiều rộng cho icon
                  color: _getVaiTroColor(widget.taiKhoan.vaiTro), // Màu sắc theo vai trò
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formattedVaiTro,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // 4% chiều rộng màn hình
                      color: Colors.black87,
                      fontWeight: FontWeight.bold, // Đậm hơn để nổi bật
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Trả về icon phù hợp với vai trò
  IconData _getVaiTroIcon(String vaiTro) {
    switch (vaiTro.toLowerCase()) {
      case 'admin':
        return Icons.security; // Icon cho Quản trị viên
      case 'employee':
        return Icons.person; // Icon cho Người dùng
      case 'manager':
        return Icons.verified_user; // Icon cho Điều hành viên
      case 'user':
        return Icons.person; // Icon cho Điều hành viên
      default:
        return Icons.person_outline; // Icon mặc định
    }
  }

  // Trả về màu sắc phù hợp với vai trò
  Color _getVaiTroColor(String vaiTro) {
    switch (vaiTro.toLowerCase()) {
      case 'admin':
        return Colors.redAccent; // Màu đỏ cho Quản trị viên
      case 'employee':
        return Colors.blueAccent; // Màu xanh cho Người dùng
      case 'manager':
        return Colors.greenAccent; // Màu xanh lá cho Điều hành viên
      case 'user':
        return Colors.pinkAccent;
      default:
        return Colors.grey; // Màu xám cho vai trò không xác định
    }
  }
}
