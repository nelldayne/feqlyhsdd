import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/presentation/widgets/chusohuu_detail_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/update_chusohuu_Screen.dart';

class ChuSoHuuCard extends StatelessWidget {
  final ChuSoHuu chuSoHuu;
  final VoidCallback onDelete;
  final VoidCallback onExportPDF;
  final int stt; // Số thứ tự

  const ChuSoHuuCard({
    super.key,
    required this.chuSoHuu,
    required this.onDelete,
    required this.onExportPDF,
    required this.stt,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa chủ sở hữu ${chuSoHuu.chusohuuID} không?"),
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
              return ChuSoHuuDetailDialog(chuSoHuu: chuSoHuu);
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
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.person,
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
                      "${chuSoHuu.hoTen}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Địa chỉ: ${chuSoHuu.diaChiThuongTru ?? 'Không xác định'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "SĐT: ${chuSoHuu.soDienThoai ?? 'Không xác định'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Email: ${chuSoHuu.email ?? 'Không xác định'}",
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateChuSoHuuScreen(chuSoHuu: chuSoHuu),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  } else if (value == 'export') {
                    onExportPDF();
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
                  const PopupMenuItem<String>(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    value: 'export',
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