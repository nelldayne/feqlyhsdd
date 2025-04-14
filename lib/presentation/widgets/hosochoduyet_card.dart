import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:qlyhoso/presentation/widgets/hoso_detail_Dialog.dart';


class HoSoPheDuyetCard extends StatefulWidget {
  final HoSoDatDai hoSoDatDai;
  final VoidCallback onPheduyet;

  const HoSoPheDuyetCard({
    super.key,
    required this.hoSoDatDai,
    required this.onPheduyet,
  });

  @override
  _HoSoPheDuyetCardState createState() => _HoSoPheDuyetCardState();
}

class _HoSoPheDuyetCardState extends State<HoSoPheDuyetCard> {
  late Timer _timer;
  String? _remainingTime;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }



  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = calculateRemainingTime(_getNgayDoiPheDuyetDateTime());
        });
      }
    });
  }

  DateTime? _getNgayDoiPheDuyetDateTime() {
    return widget.hoSoDatDai.ngayDoiPheDuyet; // Nếu ngayDoiPheDuyet là DateTime?
  }

  String formatNgay(String? ngay) {
    try {
      if (ngay == null || ngay.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngay).toLocal(); // Chuyển sang giờ địa phương
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không có thông tin'; // Nếu lỗi, trả về thông báo lỗi
    }
  }

  String calculateRemainingTime(DateTime? ngayDoiPheDuyet) {
    if (ngayDoiPheDuyet == null) return 'Không có thông tin';


    DateTime localNgayDoiPheDuyet = ngayDoiPheDuyet.toLocal();
    DateTime expirationDate = localNgayDoiPheDuyet.add(Duration());
    DateTime now = DateTime.now();
    Duration difference = expirationDate.difference(now);

    if (difference.isNegative) {
      return 'Hết hạn'; // Nếu quá thời gian
    }

    int daysLeft = difference.inDays;
    int hoursLeft = difference.inHours.remainder(24);
    int minutesLeft = difference.inMinutes.remainder(60);
    int secondsLeft = difference.inSeconds.remainder(60);

    if (daysLeft > 0) {
      return 'Còn $daysLeft ngày ${hoursLeft > 0 ? '$hoursLeft giờ' : ''}';
    } else if (hoursLeft > 0) {
      return 'Còn $hoursLeft giờ ${minutesLeft > 0 ? '$minutesLeft phút' : ''}';
    } else if (minutesLeft > 0) {
      return 'Còn $minutesLeft phút ${secondsLeft > 0 ? '$secondsLeft giây' : ''}';
    } else {
      return 'Còn $secondsLeft giây';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: GestureDetector(
        onTap: () {
          // Hiển thị dialog chi tiết hồ sơ
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return HoSoDetailDialog(hoSoDatDai: widget.hoSoDatDai);
            },
          );
        },
        child: Stack(
          children: [
            ListTile(
              title: Text(
                "Mã giao dịch: ${widget.hoSoDatDai.maGiaoDich}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ngày đợi phê duyệt: ${formatNgay(_getNgayDoiPheDuyetDateTime().toString())}"),
                  Text("Trạng thái: ${widget.hoSoDatDai.trangThai}"),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'edit') {
                    // Mở màn hình chi tiết để sửa
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.blue),
                      title: Text("Sửa"),
                    ),
                  ),
                ],
              ),
            ),
            // Thêm bộ đếm ngược ở góc phải dưới của Card
            Positioned(
              bottom: 1,
              right:1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8), // Màu nền cho đếm ngược
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _remainingTime ?? calculateRemainingTime(_getNgayDoiPheDuyetDateTime()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}