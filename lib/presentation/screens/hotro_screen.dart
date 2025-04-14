import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/hotro_model.dart';
import 'package:qlyhoso/presentation/widgets/hotro_card.dart';
import 'package:qlyhoso/presentation/widgets/hotro_detail_Dialog.dart';
import '../../services/hotro_serviecs.dart'; // File chứa getHoTroList

class HoTroScreen extends StatefulWidget {
  const HoTroScreen({super.key});

  @override
  HoTroScreenState createState() => HoTroScreenState();
}

class HoTroScreenState extends State<HoTroScreen> {
  List<HoTro> _dsHoTro = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHoTroList();
  }

  Future<void> _loadHoTroList() async {
    setState(() => _isLoading = true);
    try {
      final hoTroService = HoTroService();
      final list = await hoTroService.getHoTroList();
      if (mounted) {
        setState(() {
          _dsHoTro = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phân loại danh sách hỗ trợ thành 2 nhóm
    List<HoTro> hoTroChuaXuLy = _dsHoTro.where((hoTro) => hoTro.trangThaiHoTro == "Đang xử lý" ||hoTro.trangThaiHoTro == "Chờ tiếp nhận" ).toList();
    List<HoTro> hoTroDaXuLy = _dsHoTro.where((hoTro) => hoTro.trangThaiHoTro == "Hoàn thành").toList();

    return DefaultTabController(
      length: 2, // 2 Tabs
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
        appBar: AppBar(
          title: const Text(
            "Hỗ Trợ",
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
          bottom: const TabBar(
            dividerColor: Colors.green,
            dividerHeight: 2,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Chưa xử lý"),
              Tab(text: "Đã xử lý"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
            : TabBarView(
          children: [
            _buildHoTroList(hoTroChuaXuLy),
            _buildHoTroList(hoTroDaXuLy),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateHoTroDialog(context);
          },
          tooltip: "Tạo yêu cầu hỗ trợ",
          child: Center(
            child: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị danh sách hỗ trợ
  Widget _buildHoTroList(List<HoTro> hoTroList) {
    return hoTroList.isEmpty
        ? const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Không có yêu cầu hỗ trợ",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hoTroList.length,
      itemBuilder: (context, index) {
        return HoTroCard(
          hoTro: hoTroList[index],
          onTap: () {
            _showHoTroDetailDialog(hoTroList[index]);
          },
        );
      },
    );
  }

  void _showHoTroDetailDialog(HoTro hoTro) {
    showDialog(
      context: context,
      builder: (context) => HoTroDetailDialog(hoTro: hoTro),
    );
  }

  void _showCreateHoTroDialog(BuildContext context) {
    // Logic để tạo dialog nhập thông tin yêu cầu hỗ trợ mới (giả định)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo Yêu Cầu Hỗ Trợ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Nội dung hỗ trợ"),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: "Chủ sở hữu ID"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              // Giả định lấy dữ liệu từ TextField
              String noiDungHoTro = (context.findAncestorWidgetOfExactType<TextField>()?.controller?.text ?? "").toString();
              int? chusohuuID = int.tryParse(context.findAncestorWidgetOfExactType<TextField>()?.controller?.text ?? "0");
              String soDienThoai = (context.findAncestorWidgetOfExactType<TextField>()?.controller?.text ?? "").toString();

              if (noiDungHoTro.isNotEmpty && chusohuuID != null) {
                final hoTroService = HoTroService();
                try {
                  // Gọi API để tạo yêu cầu hỗ trợ (giả định)
                  await hoTroService.createHoTro(noiDungHoTro, chusohuuID, soDienThoai);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Yêu cầu hỗ trợ đã được tạo")),
                  );
                  _loadHoTroList(); // Tải lại danh sách sau khi tạo
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi tạo yêu cầu: $e")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                );
              }
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }
}
