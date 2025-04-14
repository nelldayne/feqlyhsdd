import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/data/models/hosodatdai_model.dart';
import 'package:qlyhoso/data/models/nhanvien_model.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import 'package:qlyhoso/services/hosodatdai_serviecs.dart';
import 'package:qlyhoso/services/nhanvien_services.dart';
import 'package:qlyhoso/services/quyhoach_Serviecs.dart';
import 'package:qlyhoso/services/thuadat_Services.dart';
import 'package:url_launcher/url_launcher.dart';


class CreateHoSoDialog extends StatefulWidget {
  final Function(HoSoDatDai) onHoSoAdded;

  const CreateHoSoDialog({super.key, required this.onHoSoAdded});

  @override
  State<CreateHoSoDialog> createState() => _CreateHoSoDialogState();
}

class _CreateHoSoDialogState extends State<CreateHoSoDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  List<Employee> _nhanVienList = [];
  List<ThuaDat> _thuaDatList = [];
  List<ChuSoHuu> _chuSoHuuList = [];
  List<QuyHoach> _quyHoachList = [];
  String? _selectedChuSoHuu;
  String? _selectedHoTen;
  String? _selectedQuyhoach;
  String? _selectedloaiQuyhoach;
  String? _selectedNhanvien;
  String? _selectedHoTenNV;
  String? _selectedThuadat;
  String? _selecteddiaChi;
  String? _selectedFilePath;
  String? selectedTrangThai;

  final TextEditingController maGiaoDichController = TextEditingController();
  final TextEditingController loaiHoSoController = TextEditingController();
  final TextEditingController ngayCapGiayController = TextEditingController();
  final TextEditingController ngayNopHoSoController = TextEditingController();
  final TextEditingController ngayXacThucHoSoController = TextEditingController();
  final TextEditingController ngayDoiPheDuyetController = TextEditingController();
  final TextEditingController tinhTrangHoSoController = TextEditingController();
  final TextEditingController ghiChuController = TextEditingController();
  final TextEditingController trangThaiController = TextEditingController();
  final TextEditingController taiLieuDinhKemController = TextEditingController();
  final TextEditingController chusohuuIDController = TextEditingController();
  final TextEditingController thuadatIDController = TextEditingController();
  final TextEditingController quyhoachIDController = TextEditingController();
  final TextEditingController nhanvienIDController = TextEditingController();
  final TextEditingController ngayTaoController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Tăng thời gian animation để mượt mà hơn
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _selectedNhanvien =  null;
    _selectedThuadat = null;
    _selectedChuSoHuu = null;
    _selectedloaiQuyhoach = null;
    _fetchQuyHoach();
    _fetchChuSoHuu();
    _fetchNhanvien();
    _fetchThuadat();

  }

  @override
  void dispose() {
    _animationController.dispose();
    maGiaoDichController.dispose();
    loaiHoSoController.dispose();
    ngayCapGiayController.dispose();
    ngayNopHoSoController.dispose();
    ngayXacThucHoSoController.dispose();
    ngayDoiPheDuyetController.dispose();
    tinhTrangHoSoController.dispose();
    ghiChuController.dispose();
    trangThaiController.dispose();
    taiLieuDinhKemController.dispose();
    chusohuuIDController.dispose();
    thuadatIDController.dispose();
    quyhoachIDController.dispose();
    nhanvienIDController.dispose();
    ngayTaoController.dispose();
    super.dispose();
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

  Future<void> _addHoSo() async {
    if (!_formKey.currentState!.validate()) return;

    HoSoDatDai newHoSo = HoSoDatDai(
      hosodatdaiID: 0, // Backend sẽ tự sinh ID
      chusohuuID:chusohuuIDController.text.isNotEmpty ? int.tryParse(chusohuuIDController.text) : null,
      thuadatID: thuadatIDController.text.isNotEmpty ? int.tryParse(thuadatIDController.text) : null,
      quyhoachID: quyhoachIDController.text.isNotEmpty ? int.tryParse(quyhoachIDController.text) : null,
      nhanvienID: nhanvienIDController.text.isNotEmpty ? int.tryParse(nhanvienIDController.text) : null,
      maGiaoDich: maGiaoDichController.text,
      loaiHoSo: loaiHoSoController.text,
      ngayCapGiay: DateTime.tryParse(ngayCapGiayController.text) ?? DateTime.now(),
      ngayNopHoSo: DateTime.tryParse(ngayNopHoSoController.text) ?? DateTime.now(),
      ngayXacThucHoSo: DateTime.tryParse(ngayXacThucHoSoController.text) ?? DateTime.now(),
      ngayDoiPheDuyet: DateTime.tryParse(ngayDoiPheDuyetController.text) ?? DateTime.now(),
      tinhTrangHoSo: tinhTrangHoSoController.text,
      ghiChu: ghiChuController.text,
      trangThai: selectedTrangThai ?? trangThaiController.text,
      taiLieuDinhKem: taiLieuDinhKemController.text,
    );

    try {
      bool success = await HoSoDatDaiService().addHoSoDatDai(newHoSo);
      if(!mounted) return;
      if (success) {
        widget.onHoSoAdded(newHoSo);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm hồ sơ đất đai thành công!"),
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
      showCustomDialog(
        context,
        title: "Lỗi",
        message: errorMsg,
        isSuccess: false,
      );
    }
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
      if (mounted) {
        setState(() {
          _quyHoachList = uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
    }
  }

  Future<void> _fetchThuadat() async {
    try {
      List<ThuaDat> list = await ThuaDatService().getListDiaChi();
      Set<int> seenIDs = {};
      List<ThuaDat> uniqueList = list.where((ThuaDat) {
        if (seenIDs.contains(ThuaDat.thuadatID)) {
          return false;
        } else {
          seenIDs.add(ThuaDat.thuadatID);
          return true;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _thuaDatList = uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
    }
  }

  Future<void> _fetchNhanvien() async {
    try {
      List<Employee> list = await EmployeeService().getListHoTenNV();
      Set<int> seenIDs = {};
      List<Employee> uniqueList = list.where((Employee) {
        if (seenIDs.contains(Employee.id)) {
          return false;
        } else {
          seenIDs.add(Employee.id);
          return true;
        }
      }).toList();
      if (mounted) {
        setState(() {
          _nhanVienList  =  uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
    }
  }


  Widget _buildDropdownSearchChuSoHuu() {
    return DropdownSearch<ChuSoHuu>(
      items: _chuSoHuuList,
      itemAsString: (ChuSoHuu chuSoHuu) => chuSoHuu.hoTen,
      selectedItem: null,
      onChanged: (ChuSoHuu? newValue) {
        setState(() {
          _selectedChuSoHuu = newValue?.hoTen;
          chusohuuIDController.text = newValue?.chusohuuID.toString() ?? '';
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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _openFile() async {
    if (_selectedFilePath != null) {
      Uri fileUri = Uri.file(_selectedFilePath!);
      if (!await launchUrl(fileUri)) {
        throw 'Không thể mở file: $_selectedFilePath';
      }
    }
  }

  Widget _buildFilePicker() {
    TextEditingController controller = TextEditingController(
      text: _selectedFilePath != null ? _selectedFilePath!.split('/').last : '',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true, // Ngăn người dùng tự nhập
            enabled: _selectedFilePath != null,
            decoration: InputDecoration(
              labelText: "Tài liệu đã chọn",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          onPressed: _pickFile,
          icon: Icon(Icons.attach_file),
          tooltip: "Chọn tài liệu", // Hiển thị gợi ý khi hover hoặc nhấn giữ
        ),
      ],
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
          quyhoachIDController.text = newValue?.quyhoachID.toString() ?? '';
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

  Widget _buildDropdownSearchThuadat() {
    return DropdownSearch<ThuaDat>(
      items: _thuaDatList,
      itemAsString: (ThuaDat thuaDat) => thuaDat.diaChiThuaDat,
      selectedItem: null,
      onChanged: (ThuaDat? newValue) {
        setState(() {
          _selectedThuadat = newValue?.diaChiThuaDat;
          thuadatIDController.text = newValue?.thuadatID.toString() ?? '';
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Địa chỉ",
          hintText: "Chọn địa chỉ",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Tìm kiếm địa chỉ",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))
            ,
          ),
        ),
      ),
    );
  }


  Widget _buildDropdownSearchNhanvien() {
    return DropdownSearch<Employee>(
      items: _nhanVienList,
      itemAsString: (Employee nhanVien) => nhanVien.hoten,
      selectedItem: null,
      onChanged: (Employee? newValue) {
        setState(() {
          _selectedQuyhoach = newValue?.hoten;
          nhanvienIDController.text = newValue?.id.toString() ?? '';
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Tên nhân viên",
          hintText: "Chọn nhân viên",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Tìm kiếm tên nhân viên",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))
            ,
          ),
        ),
      ),
    );
  }



  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Container(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.black),
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
            validator: (value) {
              if (!isOptional && (value == null || value.trim().isEmpty)) {
                return "Không được để trống";
              }
              if (label == "Email" && value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Email không hợp lệ";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTrangThai() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Trạng thái",
              labelStyle: TextStyle(color: Colors.black, fontSize: MediaQuery.of(context).textScaleFactor * 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
            items: [
              "Chờ phê duyệt",
              "Đang xử lý",
              "Đã hoàn thành",
              "Đã phê duyệt",
              "Hủy bỏ",
            ].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedTrangThai = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng chọn trạng thái";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Container(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            readOnly: true,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Thêm mới hồ sơ đất đai",
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
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                runSpacing: 20,
                children: [
                  _buildTextField("Mã giao dịch", maGiaoDichController),
                  _buildTextField("Loại hồ sơ", loaiHoSoController),
                  _buildDatePickerField("Ngày cấp giấy", ngayCapGiayController),
                  _buildDatePickerField("Ngày nộp hồ sơ", ngayNopHoSoController),
                  _buildDatePickerField("Ngày xác thực hồ sơ", ngayXacThucHoSoController),
                  _buildDatePickerField("Ngày đợi phê duyệt", ngayDoiPheDuyetController),
                  _buildTextField("Tình trạng hồ sơ", tinhTrangHoSoController),
                  _buildTextField("Ghi chú", ghiChuController),
                  _buildDropdownTrangThai(),
                  _buildFilePicker(),
                  _buildDropdownSearchChuSoHuu(),
                  _buildDropdownSearchThuadat(),
                  _buildDropdownSearchLoaiQuyHoach(),
                  _buildDropdownSearchNhanvien(),
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
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.05), // Tạo hiệu ứng scale nhẹ khi hover/touch
              child: ElevatedButton(
                onPressed: _addHoSo,
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
            );
          },
        ),
      ],
    );
  }
}