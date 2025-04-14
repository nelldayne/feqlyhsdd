import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ThongkeScreen extends StatefulWidget {
  const ThongkeScreen({super.key});

  @override
  State<ThongkeScreen> createState() => _ThongkeScreenState();
}

class _ThongkeScreenState extends State<ThongkeScreen> {
  String _selectedFilter = 'Tháng';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Thống Kê Hệ Thống"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Hiển thị theo: "),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: ['Tháng', 'Năm']
                        .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ],
              ),
              _buildStatisticCard("Tổng số thửa đất", "1500", Icons.landscape, Colors.green),
              _buildStatisticCard("Tổng hồ sơ giao dịch", "3200", Icons.file_copy, Colors.blue),
              SizedBox(height: 20),
              Text(
                "Biểu đồ giao dịch",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 300, child: _buildTransactionChart()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTransactionChart() {
    final isMonthly = _selectedFilter == 'Tháng';
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (isMonthly) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Jan');
                    case 1:
                      return Text('Feb');
                    case 2:
                      return Text('Mar');
                    case 3:
                      return Text('Apr');
                    case 4:
                      return Text('May');
                    default:
                      return Text('');
                  }
                } else {
                  return Text('${2020 + value.toInt()}');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: isMonthly
            ? [
          _buildBarGroup(0, 30),
          _buildBarGroup(1, 50),
          _buildBarGroup(2, 80),
          _buildBarGroup(3, 40),
          _buildBarGroup(4, 70),
        ]
            : [
          _buildBarGroup(0, 200),
          _buildBarGroup(1, 180),
          _buildBarGroup(2, 220),
          _buildBarGroup(3, 190),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: Colors.blueAccent, width: 16),
      ],
    );
  }
}
