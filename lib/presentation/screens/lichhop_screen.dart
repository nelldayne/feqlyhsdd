import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/lichhop_Model.dart';
import 'package:qlyhoso/presentation/widgets/lichhop_card.dart';
import 'package:qlyhoso/presentation/widgets/lichhop_detail_Dialog.dart';
import 'package:qlyhoso/services/lichhop_Serviecs.dart';

class LichHopScreen extends StatefulWidget {
  const LichHopScreen({super.key});

  @override
  LichHopScreenState createState() => LichHopScreenState();
}

class LichHopScreenState extends State<LichHopScreen> {
  List<LichHop> _dsLichHop = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLichHopList();
  }

  Future<void> _loadLichHopList() async {
    setState(() => _isLoading = true);
    try {
      final lichHopService = LichHopService();
      final list = await lichHopService.getLichHopList();
      if (mounted) {
        setState(() {
          _dsLichHop = list;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Lịch Họp",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
            : _dsLichHop.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Không có cuộc họp nào",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        )
            : ListView.builder(
          itemCount: _dsLichHop.length,
          itemBuilder: (context, index) {
            return LichHopCard(
              lichHop: _dsLichHop[index],
              onTap: () {
                _showLichHopDetailDialog(_dsLichHop[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: "Tạo lịch họp mới",
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLichHopDetailDialog(LichHop lichHop) {
    showDialog(
      context: context,
      builder: (context) => LichHopDetailDialog(lichHop: lichHop),
    );
  }
}
