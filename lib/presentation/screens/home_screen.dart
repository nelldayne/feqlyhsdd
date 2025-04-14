import 'package:flutter/material.dart';
import 'dart:async';
import 'package:qlyhoso/constrain/images_path.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:qlyhoso/data/models/lichhop_Model.dart';
import 'package:qlyhoso/presentation/widgets/banglichhop_detail_Dialog.dart';
import 'package:qlyhoso/presentation/widgets/hosochoduyet_card.dart';
import 'package:qlyhoso/services/hosodatdai_serviecs.dart';
import 'package:qlyhoso/services/lichhop_serviecs.dart';
import 'package:qlyhoso/services/thongkeServiecs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomePage> {
  int totalThuadat = 0;
  int totalHoso = 0;
  int weekOffset = 0;
  List<HoSoDatDai> _dsHoSo = [];
  List<HoSoDatDai> _filteredHoSo = [];
  List<LichHop> _dsLichHop = [];
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _fetchData();
    _filteredHoSo = _dsHoSo;
    _startAutoSlide();
    _loadHoSo();
    _loadLichHop();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stopAutoSlide();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      int? sltd = await ThongkeServiecs().slthuadat();
      int? slhs = await ThongkeServiecs().slhoso();
      if (mounted) {
        setState(() {
          totalThuadat = sltd; // Fallback to 0 if null
          totalHoso = slhs; // Fallback to 0 if null
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          totalThuadat = 0;
          totalHoso = 0;
        });
      }
    }
  }

  Future<void> _loadHoSo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      Map<String, dynamic> response = await HoSoDatDaiService().getHoSoDatDaiByNgayPheDuyet();
      if (!mounted) return;
      setState(() {
        if (response.containsKey("data") && response["data"] is List) {
          _dsHoSo = (response["data"] as List).map((e) => e as HoSoDatDai).toList();
          _filteredHoSo = _dsHoSo;
        } else {
          _dsHoSo = [];
          _filteredHoSo = [];
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Lỗi khi tải hồ sơ: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLichHop() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _dsLichHop = await LichHopService().getLichHopList(); // Sửa tên phương thức cho khớp với service
    } catch (e) {
      _errorMessage = 'Lỗi khi tải lịch họp: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 4; // 4 slide: lịch họp + 3 slide hình
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  void _resumeAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            ImagesPath.logo,
            height: 32,
          ),
        ),
        title: const Text(
          "Huyện Đại Từ",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Badge(
              child: Icon(
                Icons.notifications,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: GestureDetector(
                onTapDown: (_) {
                  _stopAutoSlide();
                },
                onTapUp: (_) {
                  _resumeAutoSlide();
                },
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        _currentPage = index;
                      });
                    }
                  },
                  children: [
                    _buildScheduleTable(),
                    _buildImageSlide(
                      "https://th.bing.com/th/id/OIP.3FjekWbKhdyPscVeBn3etwHaFj?rs=1&pid=ImgDetMain",
                      "Hồ Sơ Giao Dịch",
                      "Số lượng hồ sơ giao dịch đã được xử lý.",
                    ),
                    _buildImageSlide(
                      "https://cdn.thuvienphapluat.vn/uploads/tintuc/2024/01/18/luat-dat-dai-2024.jpg",
                      "Chủ Sở Hữu",
                      "Tổng số chủ sở hữu đã đăng ký.",
                    ),
                    _buildImageSlide(
                      "https://cdn.thuvienphapluat.vn/uploads/tintuc/2024/01/18/luat-dat-dai-2024.jpg",
                      "Quy Hoạch",
                      "Thông tin về quy hoạch đất đai.",
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            const Text("Thửa Đất", style: TextStyle(color: Colors.white, fontSize: 18)),
                            Text("$totalThuadat",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            const Text("Hồ Sơ Đất Đai",
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                            Text("$totalHoso",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Hồ Sơ Cần Xử Lý", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))
            else if (_filteredHoSo.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Không có dữ liệu",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _filteredHoSo.length,
                    itemBuilder: (context, index) {
                      final hoso = _filteredHoSo[index];
                      return HoSoPheDuyetCard(
                        hoSoDatDai: hoso,
                        onPheduyet: () {},
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1 + (weekOffset * 7)));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    Map<String, Map<String, String>> scheduleData = {
      "Sáng": {"T2": "", "T3": "", "T4": "", "T5": "", "T6": "", "T7": ""},
      "Chiều": {"T2": "", "T3": "", "T4": "", "T5": "", "T6": "", "T7": ""}
    };

    List<LichHop> weekMeetings = _dsLichHop.where((meeting) {
      DateTime meetingDate = meeting.thoiGianHop;
      return meetingDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          meetingDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();

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
      scheduleData[timeSlot]![dayKey] = meeting.tenCuocHop;
    }

    List<String> weekdays = [
      "T2 ${startOfWeek.day}/${startOfWeek.month}",
      "T3 ${startOfWeek.add(Duration(days: 1)).day}/${startOfWeek.month}",
      "T4 ${startOfWeek.add(Duration(days: 2)).day}/${startOfWeek.month}",
      "T5 ${startOfWeek.add(Duration(days: 3)).day}/${startOfWeek.month}",
      "T6 ${startOfWeek.add(Duration(days: 4)).day}/${startOfWeek.month}",
      "T7 ${startOfWeek.add(Duration(days: 5)).day}/${startOfWeek.month}",
    ];

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DetailedScheduleDialog(
            startOfWeek: startOfWeek,
            endOfWeek: endOfWeek,
            weekMeetings: weekMeetings,
            weekdays: weekdays,
            weekOffset: weekOffset,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Lịch họp tuần ${weekOffset == 0 ? "này" : (weekOffset > 0 ? "sau $weekOffset" : "trước ${-weekOffset}")}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                columnWidths: const {
                  0: FixedColumnWidth(60),
                },
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue[50]),
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("", style: TextStyle(fontWeight: FontWeight.bold)),
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                scheduleData[timeSlot]![day]!,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
  Widget _buildImageSlide(String imageUrl, String title, String description) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}