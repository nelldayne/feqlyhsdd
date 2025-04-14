import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/hotro_model.dart';

class HoTroCard extends StatelessWidget {
  final HoTro hoTro;
  final VoidCallback onTap;

  const HoTroCard({
    super.key,
    required this.hoTro,
    required this.onTap,
  });

  String formatNgay(DateTime? ngay) {
    if (ngay == null) return 'Không có thông tin';
    return "${ngay.year}-${ngay.month.toString().padLeft(2, '0')}-${ngay.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yêu cầu #${hoTro.hoTroID ?? 'Không có thông tin'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Nội dung: ${hoTro.noiDungHoTro ?? 'Không có thông tin'}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                "Trạng thái: ${hoTro.trangThaiHoTro ?? 'Không có thông tin'}",
                style: TextStyle(
                  fontSize: 14,
                  color: hoTro.trangThaiHoTro == 'Đang xử lý'
                      ? Colors.blueAccent
                      : hoTro.trangThaiHoTro == 'Hoàn thành'
                      ? Colors.green
                      : hoTro.trangThaiHoTro == 'Đã hủy'
                      ? Colors.orange
                      : Colors.black, // Mặc định nếu null
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ngày tạo: ${formatNgay(hoTro.ngayTao)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ngày hoàn thành: ${formatNgay(hoTro.ngayHoanThanh)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
