import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlyhoso/data/models/taikhoan_model.dart';
import 'package:qlyhoso/presentation/widgets/taikhoan_detail_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/update_taikhoan_screen.dart';


class TaiKhoanCard extends StatelessWidget {
  final TaiKhoan taiKhoan;
  final VoidCallback onDelete;

  const TaiKhoanCard({
    super.key,
    required this.taiKhoan,
    required this.onDelete,
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
          content: Text("Bạn có chắc chắn muốn xóa tài khoản ${taiKhoan.tenDangNhap} không?"),
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
              return TaikhoanDetailDialog(taiKhoan: taiKhoan);
            },
          ).then((_) {
            // Ẩn SnackBar nếu có khi đóng dialog (nếu cần)
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biểu tượng hoặc avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.account_circle,
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
                      "Tên tài khoản: ${taiKhoan.tenDangNhap}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Trạng thái: ${taiKhoan.trangThai}",
                      style: TextStyle(
                        fontSize: 14,
                        color: taiKhoan.trangThai == 'Hoạt động'
                            ? Colors.green
                            : Colors.blueAccent,
                      ),
                    ),
                    Text(
                      "Thời gian tạo: ${formatNgay(taiKhoan.ngayTao.toString())}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => updateTaikhoanScreen(taiKhoan: taiKhoan),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Sửa", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Xóa", style: TextStyle(fontSize: 16)),
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