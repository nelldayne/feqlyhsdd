import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qlyhoso/services/thongkeServiecs.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  // Data variables
  int totalThuadat = 0;
  int totalHoso = 0;
  int totalChuSoHuu = 0;
  int totalQuyHoach = 0;
  List<Map<String, dynamic>> dataThuadatTheoXa = [];
  
  String _selectedChartType = "Bar";
  String _selectedOption = "Dữ liệu tổng quát";
  bool _isLoading = false;
  String? _errorMessage;

  // Chart data
  List<BarChartGroupData> barChartData = [];

  final List<String> _options = [
    "Dữ liệu tổng quát",
    "Dữ liệu thửa đất theo xã",
    "Dữ liệu hồ sơ giao dịch",
    "Dữ liệu chủ sở hữu",
  ];
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchtotal(); // Fetch initial data
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchtotal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // Reset data to avoid stale values
      totalThuadat = 0;
      totalHoso = 0;
      totalChuSoHuu = 0;
      totalQuyHoach = 0;
      dataThuadatTheoXa = [];
    });

    try {
      int? sltd = await ThongkeServiecs().slthuadat();
      int? slhs = await ThongkeServiecs().slhoso();
      int? slch = await ThongkeServiecs().slchuho();
      int? slqh = await ThongkeServiecs().slquyhoach();

      if (mounted) {
        setState(() {
          totalThuadat = sltd;
          totalHoso = slhs;
          totalChuSoHuu = slch;
          totalQuyHoach = slqh;
          _updateBarChartData();
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = "Lỗi khi tải dữ liệu: $error";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchThuadatTheoXa() async {
    try {
      List<Map<String, dynamic>> data = await ThongkeServiecs().slThuadatTheoXa();
      setState(() {
        dataThuadatTheoXa = data;
      });
    } catch (error) {
      if (kDebugMode) {
        print("Lỗi lấy dữ liệu thửa đất theo xã: $error");
      }
    }
  }

  void _updateBarChartData() {
    barChartData = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: totalThuadat.toDouble(),
            color: Colors.blueAccent,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: totalHoso.toDouble(),
            color: Colors.green,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: totalChuSoHuu.toDouble(),
            color: Colors.orange,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: totalQuyHoach.toDouble(),
            color: Colors.purple,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 150,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thống Kê",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tổng quan thống kê",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard("Thửa Đất", totalThuadat, Colors.blueAccent),
                  _buildStatCard("Hồ Sơ", totalHoso, Colors.green),
                  _buildStatCard("Chủ Sở Hữu", totalChuSoHuu, Colors.orange),
                  _buildStatCard("Quy Hoạch", totalQuyHoach, Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Conditionally show the chart type selection
            if (_selectedOption != "Dữ liệu thửa đất theo xã")
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn loại biểu đồ:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  ToggleButtons(
                    isSelected: [
                      _selectedChartType == "Bar",
                      _selectedChartType == "Line",
                      _selectedChartType == "Pie",
                    ],
                    onPressed: (index) {
                      setState(() {
                        _selectedChartType = ["Bar", "Line", "Pie"][index];
                      });
                    },
                    color: Colors.grey,
                    selectedColor: Colors.blueAccent,
                    fillColor: Colors.blueAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Bar"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Line"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Pie"),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Chọn dữ liệu thống kê:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                      });
                      if (_selectedOption == "Dữ liệu thửa đất theo xã") {
                        _fetchThuadatTheoXa();
                      } else {
                        _fetchtotal();
                      }
                    },
                    items: _options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildSelectedChart(),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend(Icons.square, Colors.blueAccent, "Thửa Đất"),
                _buildLegend(Icons.square, Colors.green, "Hồ Sơ"),
                _buildLegend(Icons.square, Colors.orange, "Chủ Sở Hữu"),
                _buildLegend(Icons.square, Colors.purple, "Quy Hoạch"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    if (_selectedOption == "Dữ liệu thửa đất theo xã" && dataThuadatTheoXa.isNotEmpty) {
      return _buildBarChartThuadatTheoXa();
    }
    switch (_selectedChartType) {
      case "Line":
        return _buildLineChart();
      case "Pie":
        return _buildPieChart();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChartThuadatTheoXa() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 300,
          width: dataThuadatTheoXa.length * 80.0,
          padding: const EdgeInsets.all(16),
          decoration: _chartContainerDecoration(),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: dataThuadatTheoXa
                  .map((e) => e['SoLuongThuaDat'])
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() +
                  10,
              barGroups: dataThuadatTheoXa.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data['SoLuongThuaDat'].toDouble(),
                      color: Colors.blueAccent,
                      width: 30,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Transform.rotate(
                        angle: -0.2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dataThuadatTheoXa[value.toInt()]['Xa'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: _chartContainerDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 150,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY}\n${['Thửa Đất', 'Hồ Sơ', 'Chủ Sở Hữu', 'Quy Hoạch'][groupIndex]}',
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                );
              },
              tooltipMargin: 8,
              tooltipPadding: const EdgeInsets.all(8),
            ),
          ),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          barGroups: barChartData,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: _chartContainerDecoration(),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withValues(alpha: 0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y}\n${['Thửa Đất', 'Hồ Sơ', 'Chủ Sở Hữu', 'Quy Hoạch'][spot.x.toInt()]}',
                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
              tooltipMargin: 8,
              tooltipPadding: const EdgeInsets.all(8),
            ),
          ),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1);
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, totalThuadat.toDouble()),
                FlSpot(1, totalHoso.toDouble()),
                FlSpot(2, totalChuSoHuu.toDouble()),
                FlSpot(3, totalQuyHoach.toDouble()),
              ],
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: _chartContainerDecoration(),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: totalThuadat.toDouble(),
              color: Colors.blueAccent,
              title: 'Thửa Đất\n$totalThuadat',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalHoso.toDouble(),
              color: Colors.green,
              title: 'Hồ Sơ\n$totalHoso',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalChuSoHuu.toDouble(),
              color: Colors.orange,
              title: 'Chủ Sở Hữu\n$totalChuSoHuu',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalQuyHoach.toDouble(),
              color: Colors.purple,
              title: 'Quy Hoạch\n$totalQuyHoach',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
          sectionsSpace: 2,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                return;
              }
              setState(() {
                // Add logic to highlight section if needed
              });
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _chartContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            switch (value.toInt()) {
              case 0:
                return const Text('Thửa Đất');
              case 1:
                return const Text('Hồ Sơ');
              case 2:
                return const Text('Chủ Sở Hữu');
              case 3:
                return const Text('Quy Hoạch');
              default:
                return const Text('');
            }
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(value.toInt().toString());
          },
          interval: 30,
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildLegend(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}