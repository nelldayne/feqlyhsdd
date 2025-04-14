import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';

class HoSoDetailDialog extends StatefulWidget {
  final HoSoDatDai hoSoDatDai;

  const HoSoDetailDialog({super.key, required this.hoSoDatDai});

  @override
  _HoSoDetailDialogState createState() => _HoSoDetailDialogState();
}

class _HoSoDetailDialogState extends State<HoSoDetailDialog> with SingleTickerProviderStateMixin {
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
        "Chi tiết Hồ Sơ Đất Đai",
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
                _buildDetailRow("Mã giao dịch", widget.hoSoDatDai.maGiaoDich ?? 'Không có'),
                _buildDetailRow("Loại hồ sơ", widget.hoSoDatDai.loaiHoSo ?? 'Không có'),
                _buildDetailRow("Chủ sở hữu", widget.hoSoDatDai.tenChuSoHuu ?? 'Không có'),
                _buildDetailRow("Quy hoạch", widget.hoSoDatDai.tenQuyHoach ?? 'Không có'),
                _buildDetailRow("Ngày cấp giấy", formatNgay(widget.hoSoDatDai.ngayCapGiay.toString())),
                _buildDetailRow("Ngày nộp hồ sơ", formatNgay(widget.hoSoDatDai.ngayNopHoSo.toString())),
                _buildDetailRow("Ngày xác thực hồ sơ", formatNgay(widget.hoSoDatDai.ngayXacThucHoSo.toString())),
                _buildDetailRow("Ngày đợi phê duyệt", formatNgay(widget.hoSoDatDai.ngayDoiPheDuyet.toString())),
                _buildDetailRow("Tình trạng hồ sơ", widget.hoSoDatDai.tinhTrangHoSo ?? 'Không có'),
                _buildDetailRow("Ghi chú", widget.hoSoDatDai.ghiChu ?? 'Không có'),
                _buildDetailRow("Trạng thái", widget.hoSoDatDai.trangThai ?? 'Không có'),
                _buildDetailRow("Ngày tạo", formatNgay(widget.hoSoDatDai.ngayTao.toString())),
                _buildDetailRow("Tài liệu đính kèm", widget.hoSoDatDai.taiLieuDinhKem ?? 'Không có'),
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