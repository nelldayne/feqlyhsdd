import 'package:flutter/material.dart';
import '../../data/models/lichhop_Model.dart';

class DetailedScheduleDialog extends StatelessWidget {
  final DateTime startOfWeek;
  final DateTime endOfWeek;
  final List<LichHop> weekMeetings;
  final List<String> weekdays;
  final int weekOffset;

  const DetailedScheduleDialog({
    super.key,
    required this.startOfWeek,
    required this.endOfWeek,
    required this.weekMeetings,
    required this.weekdays,
    required this.weekOffset,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, String>> detailedScheduleData = {
      "Sáng": {"T2": "", "T3": "", "T4": "", "T5": "", "T6": "", "T7": ""},
      "Chiều": {"T2": "", "T3": "", "T4": "", "T5": "", "T6": "", "T7": ""}
    };

    // Điền thông tin chi tiết vào bảng
    for (var meeting in weekMeetings) {
      String dayKey = '';
      if (meeting.thu != null) {
        List<String> parts = meeting.thu!.split(" ");
        if (parts.length > 1) {
          String day = parts[1];
          Map<String, String> dayMap = {
            'Hai': '2',
            'Ba': '3',
            'Tư': '4',
            'Năm': '5',
            'Sáu': '6',
            'Bảy': '7',
          };
          if (dayMap.containsKey(day)) {
            dayKey = 'T${dayMap[day]}';
          }
        }
      }

      if (!["T2", "T3", "T4", "T5", "T6", "T7"].contains(dayKey)) continue;
      String timeSlot = meeting.thoiGianHop.hour < 12 ? "Sáng" : "Chiều";

      // Tạo chuỗi chi tiết với tất cả thông tin
      String detailedText = "";
      if (meeting.tenCuocHop.isNotEmpty) {
        detailedText += "Tên: ${meeting.tenCuocHop}\n";
      }
      detailedText += "Thời gian: ${meeting.thoiGianHop.hour}:${meeting.thoiGianHop.minute.toString().padLeft(2, '0')}";
      if (meeting.thu != null && meeting.thu!.isNotEmpty) {
        detailedText += "\nThứ: ${meeting.thu}";
      }
      if (meeting.diaDiemHop.isNotEmpty) {
        detailedText += "\nPhòng họp: ${meeting.diaDiemHop}";
      }
      if (meeting.noiDung != null && meeting.noiDung!.isNotEmpty) {
        detailedText += "\nMô tả: ${meeting.noiDung}";
      }
      if (meeting.nguoiChuTri != null && meeting.nguoiChuTri!.isNotEmpty) {
        detailedText += "\nNgười chủ trì: ${meeting.nguoiChuTri}";
      }
      if (meeting.trangThai != null && meeting.trangThai!.isNotEmpty) {
        detailedText += "\nTrạng thái: ${meeting.trangThai}";
      }



      detailedScheduleData[timeSlot]![dayKey] = detailedText;
    }

    return Dialog(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, // Tăng lên 95% chiều rộng màn hình
        height: MediaQuery.of(context).size.height * 0.8, // Tăng lên 80% chiều cao màn hình
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Lịch họp tuần ${weekOffset == 0 ? "này" : (weekOffset > 0 ? "sau $weekOffset" : "trước ${-weekOffset}")} (Chi tiết)",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                    columnWidths: {
                      0: FixedColumnWidth(100), // Cột "Sáng/Chiều" rộng hơn
                      // Các cột ngày sẽ tự động điều chỉnh theo nội dung
                    },
                    defaultColumnWidth: const FixedColumnWidth(200), // Tăng chiều rộng cột ngày để chứa toàn bộ nội dung
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.blue[50]),
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Thời gian",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ...weekdays.map(
                                (day) => TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  day,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...["Sáng", "Chiều"].map(
                            (timeSlot) => TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  timeSlot,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            ...["T2", "T3", "T4", "T5", "T6", "T7"].map(
                                  (day) => TableCell(
                                verticalAlignment: TableCellVerticalAlignment.top, // Căn nội dung lên trên
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    detailedScheduleData[timeSlot]![day]!,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng", style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}