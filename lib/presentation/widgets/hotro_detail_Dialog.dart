import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/hotro_model.dart';

class HoTroDetailDialog extends StatelessWidget {
  final HoTro hoTro;

  const HoTroDetailDialog({super.key, required this.hoTro});

  String formatNgay(DateTime? ngay) {
    if (ngay == null) return 'Không có thông tin';
    return "${ngay.year}-${ngay.month.toString().padLeft(2, '0')}-${ngay.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromRGBO(251, 250, 255, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiêu đề
              Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Yêu cầu Hỗ Trợ #${hoTro.hoTroID ?? 'Không có'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Nội dung (được nâng cấp)
              _buildInfoTile(
                icon: Icons.description,
                title: "Nội dung",
                content: hoTro.noiDungHoTro?.isNotEmpty == true
                    ? hoTro.noiDungHoTro!
                    : 'Không có thông tin',
                isContentExpanded: true,
              ),

              // Trạng thái
              _buildInfoTile(
                icon: Icons.info,
                title: "Trạng thái",
                content: hoTro.trangThaiHoTro ?? 'Không có thông tin',
                contentColor: hoTro.trangThaiHoTro == 'Đang xử lý'
                    ? Colors.blueAccent
                    : hoTro.trangThaiHoTro == 'Hoàn thành'
                    ? Colors.green
                    : hoTro.trangThaiHoTro == 'Đã hủy'
                    ? Colors.orange
                    : Colors.black,
              ),

              // Ngày tạo
              _buildInfoTile(
                icon: Icons.calendar_today,
                title: "Ngày tạo",
                content: formatNgay(hoTro.ngayTao),
              ),

              // Ngày cập nhật
              _buildInfoTile(
                icon: Icons.update,
                title: "Ngày cập nhật",
                content: formatNgay(hoTro.ngayCapNhat),
              ),

              // Ngày hoàn thành
              _buildInfoTile(
                icon: Icons.check_circle,
                title: "Ngày hoàn thành",
                content: formatNgay(hoTro.ngayHoanThanh),
              ),

              // Chủ sở hữu ID
              _buildInfoTile(
                icon: Icons.person,
                title: "Chủ sở hữu ID",
                content: hoTro.chusohuuID?.toString() ?? 'Không có thông tin',
              ),

              // Nhân viên xử lý
              _buildInfoTile(
                icon: Icons.support,
                title: "Nhân viên xử lý",
                content: hoTro.nhanvienID?.toString() ?? 'Không có thông tin',
              ),

              // Ghi chú (nếu có)
              if (hoTro.ghiChu?.isNotEmpty == true) ...[
                _buildInfoTile(
                  icon: Icons.note,
                  title: "Ghi chú",
                  content: hoTro.ghiChu!,
                ),
              ],

              const SizedBox(height: 16),

              // Nút hành động
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Đóng"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hỗ trợ hiển thị thông tin với icon và tiêu đề
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
    bool isContentExpanded = false, // Thêm tham số để xử lý nội dung giãn rộng
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity, // Giãn rộng toàn bộ chiều ngang
                  padding: isContentExpanded
                      ? const EdgeInsets.all(8.0)
                      : null, // Thêm padding cho nội dung mở rộng
                  decoration: isContentExpanded
                      ? BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  )
                      : null, // Thêm nền và viền cho nội dung
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: isContentExpanded ? 16 : 16, // Giữ cỡ chữ
                      color: contentColor ?? Colors.black87,
                    ),
                    softWrap: true, // Cho phép xuống dòng tự nhiên
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}