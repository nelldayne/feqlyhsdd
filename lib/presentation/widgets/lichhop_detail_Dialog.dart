import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/lichhop_Model.dart';


class LichHopDetailDialog extends StatelessWidget {
  final LichHop lichHop;

  const LichHopDetailDialog({Key? key, required this.lichHop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Chi Tiết Lịch Họp",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Tên cuộc họp:", lichHop.tenCuocHop),
          _buildInfoRow("Thời gian:", _formatDateTime(lichHop.thoiGianHop)),
          _buildInfoRow("Địa điểm:", lichHop.diaDiemHop),
          _buildInfoRow("Nội dung:", lichHop.noiDung ?? "Không có thông tin"),
          _buildInfoRow("Người chủ trì:", lichHop.nguoiChuTri ?? "Không có thông tin"),
          _buildInfoRow("Trạng thái:", lichHop.trangThai ?? "Không có thông tin"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  /// Hàm tạo một dòng thông tin trong dialog
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  /// Định dạng ngày giờ cho dễ đọc
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
