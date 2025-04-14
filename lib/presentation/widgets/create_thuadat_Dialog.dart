import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import 'package:qlyhoso/services/quyhoach_Serviecs.dart';
import '../../services/thuadat_Services.dart';
import 'package:dropdown_search/dropdown_search.dart';

class createDialogThuaDat extends StatefulWidget {
  final Function(ThuaDat) onThuaDatAdded;

  const createDialogThuaDat({super.key, required this.onThuaDatAdded});

  @override
  _DialogThuaDatState createState() => _DialogThuaDatState();
}

class _DialogThuaDatState extends State<createDialogThuaDat> with SingleTickerProviderStateMixin {
  List<ChuSoHuu> _chuSoHuuList = [];
  List<QuyHoach> _quyHoachList = [];
  String? _selectedChuSoHuu;
  String? _selectedHoTen;
  String? _selectedQuyhoach;
  String? _selectedloaiQuyhoach;
  final _formKey = GlobalKey<FormState>();

  // 🎯 Tạo các controller để nhập dữ liệu
  final TextEditingController maThuaDatController = TextEditingController();
  final TextEditingController toBanDoController = TextEditingController();
  final TextEditingController diaChiController = TextEditingController();
  final TextEditingController dienTichController = TextEditingController();
  final TextEditingController loaiDatController = TextEditingController();
  final TextEditingController ranhGioiController = TextEditingController();
  final TextEditingController mucDichSuDungController = TextEditingController();
  final TextEditingController tinhTrangPhapLyController = TextEditingController();
  final TextEditingController quyHoachController = TextEditingController();
  final TextEditingController kinhdoController = TextEditingController();
  final TextEditingController vidoController = TextEditingController();
  final TextEditingController trangThaiController = TextEditingController();
  final TextEditingController ngayCapGCNController = TextEditingController();
  final TextEditingController chuSoHuuController = TextEditingController();
  final TextEditingController ghiChuController = TextEditingController(); // Thêm mới
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _selectedChuSoHuu = null;
    _selectedloaiQuyhoach = null;
    _fetchQuyHoach();
    _fetchChuSoHuu();
  }

  @override
  void dispose() {
    _animationController.dispose();
    maThuaDatController.dispose();
    toBanDoController.dispose();
    diaChiController.dispose();
    dienTichController.dispose();
    loaiDatController.dispose();
    ranhGioiController.dispose();
    mucDichSuDungController.dispose();
    tinhTrangPhapLyController.dispose();
    quyHoachController.dispose();
    kinhdoController.dispose();
    vidoController.dispose();
    trangThaiController.dispose();
    ngayCapGCNController.dispose();
    chuSoHuuController.dispose();
    ghiChuController.dispose();
    super.dispose();
  }


  Future<void> _fetchChuSoHuu() async {
    try {
      List<ChuSoHuu> list = await ChuSoHuuService().getListHoTenChuSoHuu();
      Set<int> seenIDs = {};
      List<ChuSoHuu> uniqueList = list.where((chuSoHuu) {
        if (seenIDs.contains(chuSoHuu.chusohuuID)) {
          return false;
        } else {
          seenIDs.add(chuSoHuu.chusohuuID);
          return true;
        }
      }).toList();

      // 🔄 Cập nhật danh sách sau khi lọc trùng
      if (mounted) {
        setState(() {
          _chuSoHuuList = uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
    }
  }

  Future<void> _fetchQuyHoach() async {
    try {
      List<QuyHoach> list = await QuyHoachService().getListLoaiQuyHoach();
      Set<int> seenIDs = {};
      List<QuyHoach> uniqueList = list.where((QuyHoach) {
        if (seenIDs.contains(QuyHoach.quyhoachID)) {
          return false;
        } else {
          seenIDs.add(QuyHoach.quyhoachID);
          return true;
        }
      }).toList();

      // 🔄 Cập nhật danh sách sau khi lọc trùng
      if (mounted) {
        setState(() {
          _quyHoachList = uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
    }
  }



  Future<void> _addThuaDat() async {
    if (!_formKey.currentState!.validate()) return;

    ThuaDat newThuaDat = ThuaDat(
      thuadatID: 0, // Backend sẽ tự sinh ID
      maThuaDat: maThuaDatController.text,
      toBanDo: toBanDoController.text,
      diaChiThuaDat: diaChiController.text,
      dienTich: double.tryParse(dienTichController.text) ?? 0.0,
      loaiDat: loaiDatController.text,
      ranhgioi: ranhGioiController.text,
      mucDichSuDung: mucDichSuDungController.text,
      tinhTrangPhapLy: tinhTrangPhapLyController.text,
      quyhoachID: quyHoachController.text.isNotEmpty ? int.tryParse(quyHoachController.text) : null,
      trangThaiSuDung: trangThaiController.text,
      ngayCapGiayChungNhan: DateTime.tryParse(ngayCapGCNController.text) ?? DateTime.now(),
      chusohuuID: chuSoHuuController.text.isNotEmpty ? int.tryParse(chuSoHuuController.text) : null,
      ghichu: ghiChuController.text.isNotEmpty ? ghiChuController.text : null, // Thêm trường mới
      kinhdo: double.tryParse(kinhdoController.text) ?? 0.0,
      vido: double.tryParse(vidoController.text) ?? 0.0,
    );

    try {
      bool success = await ThuaDatService().addThuaDat(newThuaDat);
      if (success) {
        widget.onThuaDatAdded(newThuaDat);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm mới thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Lỗi khi thêm mới!");
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains("Exception:")) {
        errorMsg = errorMsg.replaceFirst("Exception:", "").trim();
      }
      // Hiển thị thông báo lỗi với nút "Xác nhận" và đóng dialog khi nhấn
      showCustomDialog(
        context,
        title: "Lỗi",
        message: errorMsg,
        isSuccess: false,
        onConfirm: () => Navigator.of(context).pop(), // Đóng dialog lỗi
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return "Không được để trống";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownSearchChuSoHuu() {
    return DropdownSearch<ChuSoHuu>(
      items: _chuSoHuuList,
      itemAsString: (ChuSoHuu chuSoHuu) => chuSoHuu.hoTen ?? 'Không xác định',
      selectedItem: null,
      onChanged: (ChuSoHuu? newValue) {
        setState(() {
          _selectedChuSoHuu = newValue?.hoTen;
          chuSoHuuController.text = newValue?.chusohuuID.toString() ?? '';
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Chủ sở hữu",
          hintText: "Chọn chủ sở hữu",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Tìm kiếm chủ sở hữu",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))
            ,
          ),
        ),
      ),
    );
  }



  Widget _buildDropdownSearchLoaiQuyHoach() {
    return DropdownSearch<QuyHoach>(
      items: _quyHoachList,
      itemAsString: (QuyHoach quyHoach) => quyHoach.loaiQuyHoach ?? 'Không xác định',
      selectedItem: null,
      onChanged: (QuyHoach? newValue) {
        setState(() {
          _selectedQuyhoach = newValue?.loaiQuyHoach;
          quyHoachController.text = newValue?.quyhoachID.toString() ?? '';
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Loại quy hoạch",
          hintText: "Chọn loại quy hoạch",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Tìm kiếm loại quy hoạch",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))
            ,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          hintText: controller.text.isEmpty ? 'Chọn ngày' : null,
          suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toIso8601String().split('T').first; // Định dạng yyyy-MM-dd
            });
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Không được để trống";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Thêm mới thửa đất",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField("Mã Thửa Đất", maThuaDatController),
                  _buildTextField("Số hiệu tờ bản đồ", toBanDoController),
                  _buildTextField("Địa chỉ", diaChiController),
                  _buildTextField("Diện tích", dienTichController, isNumber: true),
                  _buildTextField("Kinh độ", kinhdoController, isNumber: true,  isOptional: true),
                  _buildTextField("Vĩ độ", vidoController, isNumber: true,  isOptional: true),
                  _buildTextField("Loại đất", loaiDatController),
                  _buildTextField("Ranh giới", ranhGioiController),
                  _buildTextField("Mục đích sử dụng", mucDichSuDungController),
                  _buildTextField("Tình trạng pháp lý", tinhTrangPhapLyController),
                  _buildTextField("Trạng thái sử dụng", trangThaiController),
                  _buildDatePickerField("Ngày cấp giấy chứng nhận", ngayCapGCNController),
                  SizedBox(height: 12,),
                  _buildDropdownSearchChuSoHuu(),
                  SizedBox(height: 24,),
                  _buildDropdownSearchLoaiQuyHoach(),
                  SizedBox(height: 12,),
                  _buildTextField("Ghi chú", ghiChuController, isOptional: true),
                ],
              ),
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addThuaDat,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Lưu",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}