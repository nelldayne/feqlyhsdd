import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/thuadat_Services.dart'; // Import ThuaDatService

class HopthuaDialog extends StatefulWidget {
  final Function(List<ThuaDat>) onHopThua; // Callback khi hợp thửa thành công

  const HopthuaDialog({
    super.key,
    required this.onHopThua,
  });

  @override
  State<HopthuaDialog> createState() => _HopthuaDialogState();
}

class _HopthuaDialogState extends State<HopthuaDialog> {
  List<ThuaDat> _thuaDatList = []; // Danh sách thửa đất từ API
  List<ThuaDat?> selectedThuaDat = [null, null]; // Danh sách thửa đất được chọn
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchThuadat(); // Gọi hàm lấy danh sách khi khởi tạo
  }

  // Hàm lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Hàm lấy danh sách thửa đất từ ThuaDatService
  Future<void> _fetchThuadat() async {
    try {
      List<ThuaDat> list = await ThuaDatService().fetchThuadatList();
      Set<int> seenIDs = {};
      List<ThuaDat> uniqueList = list.where((thuaDat) {
        if (seenIDs.contains(thuaDat.thuadatID)) {
          return false;
        } else {
          seenIDs.add(thuaDat.thuadatID);
          return true;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _thuaDatList = uniqueList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách thửa đất: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm tạo chuỗi thông tin đầy đủ của một thửa đất
  String _buildThuaDatInfo(ThuaDat thuaDat) {
    return [
      "ID: ${thuaDat.thuadatID}",
      if (thuaDat.diaChiThuaDat.isNotEmpty) "Địa chỉ: ${thuaDat.diaChiThuaDat}",
      if (thuaDat.toBanDo.isNotEmpty)"Tờ bản đồ: ${thuaDat.toBanDo}",
      if (thuaDat.maThuaDat.isNotEmpty)"Mã thửa đất: ${thuaDat.maThuaDat}",

    ].where((line) => line.isNotEmpty).join("\n");
  }

  // Hàm xóa thửa đất đã chọn
  void _removeSelectedThuaDat(int index) {
    setState(() {
      selectedThuaDat[index] = null;
    });
  }

  // Hàm hiển thị dialog tùy chỉnh
  void showCustomDialog(BuildContext context, {required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xử lý hợp thửa
  Future<void> _performHopThua() async {
    if (selectedThuaDat[0] != null && selectedThuaDat[1] != null) {
      if (selectedThuaDat[0] == selectedThuaDat[1]) {
        showCustomDialog(
          context,
          title: "Lỗi",
          message: "Vui lòng chọn hai thửa đất khác nhau",
          isSuccess: false,
        );
        return;
      }

      String? token = await _getToken();
      if (token == null) {
        showCustomDialog(
          context,
          title: "Lỗi",
          message: "Chưa có token, vui lòng đăng nhập lại",
          isSuccess: false,
        );
        return;
      }

      // Tạo danh sách thuadatID từ selectedThuaDat
      List<int> thuadatIDList = [
        selectedThuaDat[0]!.thuadatID,
        selectedThuaDat[1]!.thuadatID,
      ];

      // Gọi service để hợp thửa
      try {
        bool success = await ThuaDatService().hopThua(token, thuadatIDList);
        if (!mounted) return;

        if (success) {
          widget.onHopThua([selectedThuaDat[0]!, selectedThuaDat[1]!]); // Gọi callback
          showCustomDialog(
            context,
            title: "Thành công",
            message: "Hợp thửa thành công!",
            isSuccess: true,
          );
          Navigator.pop(context); // Đóng dialog
        } else {
          showCustomDialog(
            context,
            title: "Lỗi",
            message: "Hợp thửa thất bại!",
            isSuccess: false,
          );
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.contains("Exception:")) {
          errorMsg = errorMsg.replaceFirst("Exception:", "").trim();
        }
        showCustomDialog(
          context,
          title: "Lỗi",
          message: errorMsg,
          isSuccess: false,
        );
      }
    } else {
      showCustomDialog(
        context,
        title: "Lỗi",
        message: "Vui lòng chọn đầy đủ hai thửa đất",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    final double dialogHeight = MediaQuery.of(context).size.height * 0.8;

    return AlertDialog(
      backgroundColor: const Color.fromRGBO(251, 250, 255, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Hợp thửa đất",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<ThuaDat>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(
                    maxHeight: dialogHeight * 0.4,
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Chọn thửa đất thứ nhất",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                items: _thuaDatList,
                itemAsString: (ThuaDat? thuaDat) => thuaDat != null ? _buildThuaDatInfo(thuaDat) : "",
                onChanged: (ThuaDat? value) {
                  setState(() {
                    selectedThuaDat[0] = value;
                  });
                },
                selectedItem: selectedThuaDat[0],
                validator: (value) => value == null ? "Vui lòng chọn thửa đất" : null,
              ),
              const SizedBox(height: 16),

              DropdownSearch<ThuaDat>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(
                    maxHeight: dialogHeight * 0.4,
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Chọn thửa đất thứ hai",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                items: _thuaDatList,
                itemAsString: (ThuaDat? thuaDat) => thuaDat != null ? _buildThuaDatInfo(thuaDat) : "",
                onChanged: (ThuaDat? value) {
                  setState(() {
                    selectedThuaDat[1] = value;
                  });
                },
                selectedItem: selectedThuaDat[1],
                validator: (value) => value == null ? "Vui lòng chọn thửa đất" : null,
              ),

              if (selectedThuaDat[0] != null || selectedThuaDat[1] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  "Thông tin thửa đất đã chọn:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (selectedThuaDat[0] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _buildThuaDatInfo(selectedThuaDat[0]!),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeSelectedThuaDat(0),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (selectedThuaDat[1] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _buildThuaDatInfo(selectedThuaDat[1]!),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeSelectedThuaDat(1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Đóng dialog
          },
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _performHopThua, // Gọi hàm xử lý hợp thửa
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            "Hợp thửa",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}