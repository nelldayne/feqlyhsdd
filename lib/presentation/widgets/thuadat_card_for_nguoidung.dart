import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/screens/map_screen.dart';
import 'package:qlyhoso/presentation/widgets/thuadat_detail_Dialog.dart';

class ThuaDatCardKH extends StatelessWidget {
  final ThuaDat thuaDat;

  const ThuaDatCardKH({
    super.key,
    required this.thuaDat,
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
                      if(value == 'xemvitri') {
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
