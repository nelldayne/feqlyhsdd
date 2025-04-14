import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
class ThuaDatDetailDialog extends StatelessWidget {
  final ThuaDat thuaDat;

  const ThuaDatDetailDialog({super.key, required this.thuaDat});

  String formatNgayCap(String? ngayCap) {
    try {
      if (ngayCap == null || ngayCap.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngayCap).toLocal(); // Chuyển sang giờ địa phương
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Chưa cấp giấy chứng nhận';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Chi tiết thửa đất",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("Mã thửa đất", thuaDat.maThuaDat),
              _buildDetailRow("Số hiệu tờ bản đồ", thuaDat.toBanDo),
              _buildDetailRow("Địa chỉ", thuaDat.diaChiThuaDat),
              _buildDetailRow("Diện tích", "${thuaDat.dienTich} m²"),
              _buildDetailRow("Vĩ độ", (thuaDat.vido ?? "Không có thông tin").toString()),
              _buildDetailRow("Kinh độ", (thuaDat.kinhdo ?? "Không có thông tin").toString()),
              _buildDetailRow("Loại đất", thuaDat.loaiDat),
              _buildDetailRow("Ranh giới", thuaDat.ranhgioi),
              _buildDetailRow("Mục đích sử dụng", thuaDat.mucDichSuDung),
              _buildDetailRow("Tình trạng pháp lý", thuaDat.tinhTrangPhapLy),
              _buildDetailRow("Trạng thái sử dụng", thuaDat.trangThaiSuDung),
              _buildDetailRow("Ngày cấp GCN", formatNgayCap(thuaDat.ngayCapGiayChungNhan.toString())),
              _buildDetailRow("Chủ sở hữu", thuaDat.hoTen ?? 'Không có thông tin'),
              _buildDetailRow("Số điện thoại", thuaDat.soDienThoai ?? 'Không có thông tin'),
              _buildDetailRow("Loại quy hoạch", thuaDat.loaiQuyhoach ?? 'Không có thông tin'),
              _buildDetailRow("Ghi chú", thuaDat.ghichu ?? 'Không có thông tin'),
            ],
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