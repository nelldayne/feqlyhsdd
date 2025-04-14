import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:qlyhoso/presentation/widgets/hoso_detail_Dialog.dart';
class HoSoCard extends StatelessWidget {
  final HoSoDatDai hoSoDatDai;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onExportPDF;

  const HoSoCard({
    super.key,
    required this.hoSoDatDai,
    required this.onDelete,
    required this.onUpdate,
    required this.onExportPDF,
  });

  String formatNgay(String? ngay) {
    try {
      if (ngay == null || ngay.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngay).toLocal();
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không có thông tin';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa hồ sơ ${hoSoDatDai.hosodatdaiID} không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return HoSoDetailDialog(hoSoDatDai: hoSoDatDai);
            },
          ).then((_) {
            // Thêm animation khi đóng dialog (nếu cần)
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biểu tượng hoặc avatar (tùy chọn)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.description,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mã giao dịch: ${hoSoDatDai.maGiaoDich}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Chủ sở hữu: ${hoSoDatDai.tenChuSoHuu ?? 'Không xác định'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Loại hồ sơ: ${hoSoDatDai.loaiHoSo ?? 'Không xác định'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Trạng thái: ${hoSoDatDai.trangThai}",
                      style: TextStyle(
                        fontSize: 14,
                        color: hoSoDatDai.trangThai == 'Hoàn thành'
                            ? Colors.green
                            : Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày tạo: ${formatNgay(hoSoDatDai.ngayTao.toString())}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.blueAccent),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onUpdate();
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  } else if (value == 'export') {
                    onExportPDF();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Sửa", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Xóa", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.filePdf, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Xuất PDF", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}