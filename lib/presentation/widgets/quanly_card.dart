import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/quanly_model.dart';

class QuanLyCard extends StatelessWidget {
  final QuanLy quanly;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuanLyCard({
    super.key,
    required this.quanly,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quanly.hoTen,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Email: ${quanly.email}'),
            Text('Phòng ban: ${quanly.phongBan}'),
            Text('Số điện thoại: ${quanly.soDienThoai}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}