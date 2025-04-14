import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/screens/map_screen.dart';

import 'package:qlyhoso/presentation/widgets/tachthua_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/thuadat_detail_Dialog.dart';

class ThuaDatCard extends StatelessWidget {
  final ThuaDat thuaDat;
  final VoidCallback onDelete;
  final VoidCallback tachThua;
  final VoidCallback onUpdate;
  final VoidCallback onExportPDF;
  final int stt;

  const ThuaDatCard({
    super.key,
    required this.thuaDat,
    required this.onDelete,
    required this.onUpdate,
    required this.onExportPDF,
    required this.stt,
    required this.tachThua,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // Hiển thị dialog chi tiết thửa đất
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ThuaDatDetailDialog(thuaDat: thuaDat);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 🌿 Hình minh họa nhỏ (có thể thay bằng hình ảnh đất)
                  Container(
                    width: 70,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/OIP (1).png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 📋 Thông tin chi tiết
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${thuaDat.maThuaDat} - ${thuaDat.diaChiThuaDat}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Diện tích: ${thuaDat.dienTich.toDouble()} m²",
                          style: TextStyle(
                              color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Loại đất: ${thuaDat.loaiDat}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ☰ Menu tùy chọn
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.blue),
                    onSelected: (String value) {
                      if (value == 'edit') {
                        onUpdate();
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      } else if (value == 'export') {
                        onExportPDF();
                      } else if (value == 'tach') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogTachThua(
                              thuadatID: thuaDat.thuadatID,
                              dienTichBanDau: thuaDat.dienTich,
                              onTachThuaAdded: (tachThuaData) {},
                            );
                          },
                        );
                      }else if(value == 'xemvitri') {
                        _viewLocation(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'xemvitri',
                        child: ListTile(
                          leading: Icon(Icons.location_on, color: Colors.purple),
                          title: Text("Xem vị trí"),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'tach',
                        child: ListTile(
                          leading: Icon(Icons.design_services, color: Colors.orangeAccent),
                          title: Text("Tách thửa"),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text("Sửa"),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text("Xóa"),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.filePdf, color: Colors.green),
                          title: Text("Xuất PDF"),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          // 🔢 Hiển thị STT trong vòng tròn nhỏ
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              '$stt',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🗑 Hộp thoại xác nhận xóa
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa thửa đất ${thuaDat.maThuaDat} không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
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

  void _viewLocation(BuildContext context) {
    if (thuaDat.kinhdo != null && thuaDat.vido != null &&
        thuaDat.kinhdo != 0 && thuaDat.vido != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            latitude: thuaDat.vido!,
            longitude: thuaDat.kinhdo!,
            thuaDatId: thuaDat.thuadatID,
          ),
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa cập nhật!')),
      );
    }
  }
}
