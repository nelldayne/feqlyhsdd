import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';

class ChuSoHuuDetailDialog extends StatefulWidget {
  final ChuSoHuu chuSoHuu;

  const ChuSoHuuDetailDialog({super.key, required this.chuSoHuu});

  @override
  _ChuSoHuuDetailDialogState createState() => _ChuSoHuuDetailDialogState();
}

class _ChuSoHuuDetailDialogState extends State<ChuSoHuuDetailDialog> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Chi tiết Chủ Sở Hữu",
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
                _buildDetailRow("Tên chủ hộ", widget.chuSoHuu.hoTen),
                _buildDetailRow("Số điện thoại", widget.chuSoHuu.soDienThoai ?? 'Không có thông tin'),
                _buildDetailRow("Email", widget.chuSoHuu.email ?? 'Không có thông tin'),
                _buildDetailRow("Giới tính", widget.chuSoHuu.gioiTinh ?? 'Không có thông tin'),
                _buildDetailRow("Ngày sinh", formatNgay(widget.chuSoHuu.ngaySinh.toString())),
                _buildDetailRow("Số CMND/CCCD", widget.chuSoHuu.soCMND_CCCD ?? ''),
                _buildDetailRow("Ngày cấp", formatNgay(widget.chuSoHuu.ngayCap.toString())),
                _buildDetailRow("Nơi cấp", widget.chuSoHuu.noiCap ?? 'Không có thông tin'),
                _buildDetailRow("Địa chỉ", widget.chuSoHuu.diaChiThuongTru ?? ''),
                _buildDetailRow("Tình trạng pháp lý", widget.chuSoHuu.diaChiLienHe ?? 'Không có thông tin'),
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