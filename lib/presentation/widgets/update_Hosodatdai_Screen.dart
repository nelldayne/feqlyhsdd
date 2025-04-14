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

class UpdateHoSoDialog extends StatefulWidget {
  final HoSoDatDai hoSoDatDai;
  final VoidCallback onUpdatehoSo;
  const UpdateHoSoDialog({super.key, required this.hoSoDatDai, required this.onUpdatehoSo, });

  @override
  State<UpdateHoSoDialog> createState() => _UpdateHoSoDialogState();
}

class _UpdateHoSoDialogState extends State<UpdateHoSoDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? selectedTrangThai;

  List<Employee> _nhanVienList = [];
  List<ThuaDat> _thuaDatList = [];
  List<ChuSoHuu> _chuSoHuuList = [];
  List<QuyHoach> _quyHoachList = [];

  ChuSoHuu? _currentSelectedChuSoHuu;
  QuyHoach? _currentSelectedQuyHoach;
  ThuaDat? _currentSelectedThuaDat;
  Employee? _currentSelectedNhanVien;
  String? _selectedFilePath;
  late TextEditingController maGiaoDichController;
  late TextEditingController loaiHoSoController;
  late TextEditingController ngayCapGiayController;
  late TextEditingController ngayNopHoSoController;
  late TextEditingController ngayXacThucHoSoController;
  late TextEditingController ngayDoiPheDuyetHoSoController;
  late TextEditingController tinhTrangHoSoController;
  late TextEditingController ghiChuController;
  late TextEditingController trangThaiController;
  late TextEditingController nhanvienIDController;
  late TextEditingController chusohuuIDController;
  late TextEditingController thuadatIDController;
  late TextEditingController quyhoachIDController;
  late TextEditingController ngayTaoController;
  late TextEditingController taiLieuDinhKemController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String formatNgay(String? ngay) {
    try {
      if (ngay == null || ngay.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngay).toLocal(); // Chuyển sang giờ địa phương
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Không có thông tin'; // Nếu lỗi, trả về thông báo lỗi
    }
  }

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
    selectedTrangThai = widget.hoSoDatDai.trangThai;
    maGiaoDichController = TextEditingController(text: widget.hoSoDatDai.maGiaoDich);
    loaiHoSoController = TextEditingController(text: widget.hoSoDatDai.loaiHoSo);
    ngayCapGiayController = TextEditingController(text: formatNgay(widget.hoSoDatDai.ngayCapGiay.toString()));
    ngayNopHoSoController = TextEditingController(text: formatNgay(widget.hoSoDatDai.ngayNopHoSo.toString()));
    ngayXacThucHoSoController = TextEditingController(text: formatNgay(widget.hoSoDatDai.ngayXacThucHoSo.toString()));
    ngayDoiPheDuyetHoSoController = TextEditingController(text: formatNgay(widget.hoSoDatDai.ngayDoiPheDuyet.toString()));
    tinhTrangHoSoController = TextEditingController(text: widget.hoSoDatDai.tinhTrangHoSo);
    ghiChuController = TextEditingController(text: widget.hoSoDatDai.ghiChu);
    trangThaiController = TextEditingController(text: widget.hoSoDatDai.trangThai);
    nhanvienIDController = TextEditingController(text: widget.hoSoDatDai.nhanvienID?.toString() ?? '');
    chusohuuIDController = TextEditingController(text: widget.hoSoDatDai.chusohuuID?.toString() ?? '');
    thuadatIDController = TextEditingController(text: widget.hoSoDatDai.thuadatID?.toString() ?? '');
    quyhoachIDController = TextEditingController(text: widget.hoSoDatDai.quyhoachID?.toString() ?? '');
    ngayTaoController = TextEditingController(text: formatNgay(widget.hoSoDatDai.ngayTao.toString()));
    taiLieuDinhKemController = TextEditingController(text: widget.hoSoDatDai.taiLieuDinhKem);


    _fetchAllData();


  }

  @override
  void dispose() {
    _animationController.dispose();
    maGiaoDichController.dispose();
    loaiHoSoController.dispose();
    ngayCapGiayController.dispose();
    ngayNopHoSoController.dispose();
    ngayXacThucHoSoController.dispose();
    ngayDoiPheDuyetHoSoController.dispose();
    tinhTrangHoSoController.dispose();
    ghiChuController.dispose();
    trangThaiController.dispose();
    nhanvienIDController.dispose();
    chusohuuIDController.dispose();
    thuadatIDController.dispose();
    quyhoachIDController.dispose();
    ngayTaoController.dispose();
    taiLieuDinhKemController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchChuSoHuu(),
      _fetchQuyHoach(),
      _fetchThuadat(),
      _fetchNhanvien(),
    ]);

    if (mounted) {
      setState(() {
        // Nếu widget.hoSoDatDai.chusohuuID có giá trị và chưa có lựa chọn, gán _currentSelectedChuSoHuu
        if (widget.hoSoDatDai.chusohuuID != null && _currentSelectedChuSoHuu == null) {
          _currentSelectedChuSoHuu = _chuSoHuuList.firstWhere(
                (chuSoHuu) => chuSoHuu.chusohuuID == widget.hoSoDatDai.chusohuuID,
            orElse: () => ChuSoHuu(
              chusohuuID: -1,
              hoTen: 'Không xác định',
              diaChiThuongTru: 'Không có thông tin',
              ngayCap: DateTime.now(),
              ngaySinh: DateTime.now(),
              soCMND_CCCD: 'Không có thông tin',
              email: 'Không có thông tin',
              diaChiLienHe: 'Không có thông tin',
              gioiTinh: 'Không có thông tin',
              noiCap: 'Không có thông tin',
              soDienThoai: 'Không có thông tin',
            ),
          );
        }
        // Nếu widget.hoSoDatDai.quyhoachID có giá trị và chưa có lựa chọn
        if (widget.hoSoDatDai.quyhoachID != null && _currentSelectedQuyHoach == null) {
          _currentSelectedQuyHoach = _quyHoachList.firstWhere(
                (quyHoach) => quyHoach.quyhoachID == widget.hoSoDatDai.quyhoachID,
            orElse: () => QuyHoach(
              quyhoachID: -1,
              loaiQuyHoach: 'Không có thông tin',
              moTa: 'Không có thông tin',
              thoiGianBatDau: DateTime.now(),
              thoiGianKetThuc: DateTime.now(),
              trangThai: 'Không có thông tin',
            ),
          );
        }
        // Nếu widget.hoSoDatDai.thuadatID có giá trị và chưa có lựa chọn
        if (widget.hoSoDatDai.thuadatID != null && _currentSelectedThuaDat == null) {
          _currentSelectedThuaDat = _thuaDatList.firstWhere(
                (thuaDat) => thuaDat.thuadatID == widget.hoSoDatDai.thuadatID,
            orElse: () => ThuaDat(
              thuadatID: -1,
              maThuaDat: 'Không xác định',
              toBanDo: 'Không xác định',
              diaChiThuaDat: 'Không xác định',
              dienTich: 0.0,
              loaiDat: 'Không xác định',
              ranhgioi: 'Không xác định',
              mucDichSuDung: 'Không xác định',
              tinhTrangPhapLy: 'Không xác định',
              trangThaiSuDung: 'Không xác định',
            ),
          );
        }
        // Nếu widget.hoSoDatDai.nhanvienID có giá trị và chưa có lựa chọn
        if (widget.hoSoDatDai.nhanvienID != null && _currentSelectedNhanVien == null) {
          _currentSelectedNhanVien = _nhanVienList.firstWhere(
                (nhanVien) => nhanVien.id == widget.hoSoDatDai.nhanvienID,
            orElse: () => Employee(
              id: -1,
              hoten: 'Không xác định',
              taikhoanid: -1,
              email: 'Không có thông tin',
              trangthai: 'Không có thông tin',
              sodienthoai: 'Không có thông tin',
              phongban: 'Không có thông tin',
              gioitinh: 'Không có thông tin',
              ngaysinh: DateTime.now(),
            ),
          );
        }
      });
    }
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

  void _removeFile() {
    setState(() {
      taiLieuDinhKemController.clear();
      _selectedFilePath = null;
    });
  }


  Widget _buildFilePicker() {
    String? filePath = taiLieuDinhKemController.text.isNotEmpty
        ? taiLieuDinhKemController.text
        : _selectedFilePath;

    TextEditingController _controller = TextEditingController(
      text: filePath != null ? filePath.split('/').last : '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          readOnly: true,
          enabled: filePath != null,
          decoration: InputDecoration(
            labelText: "Tài liệu đã chọn",
            hintText: "Chưa có tài liệu nào",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
            suffixIcon: filePath != null
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.green),
                  onPressed: () => _openFile(),
                  tooltip: "Mở tài liệu",
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: _removeFile,
                  tooltip: "Xóa tài liệu",
                ),
              ],
            )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file),
          label: const Text("Chọn tài liệu"),
        ),
      ],
    );
  }



  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // 1% chiều cao màn hình
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey, fontSize: MediaQuery.of(context).textScaleFactor * 16), // Tùy chỉnh font size
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
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
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01), // 1% chiều cao màn hình
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.blueGrey, fontSize: MediaQuery.of(context).textScaleFactor * 16), // Tùy chỉnh font size
              hintText: controller.text.isEmpty ? 'Chọn ngày' : null,
              suffixIcon: Icon(Icons.calendar_today, size: MediaQuery.of(context).size.width * 0.06, color: Colors.blueAccent), // 6% chiều rộng cho icon
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // 2% chiều rộng cho bo tròn
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            readOnly: true,
            onTap: () async {
              if (mounted) {
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

                if (mounted) {
                  setState(() {
                    controller.text = pickedDate != null
                        ? pickedDate.toIso8601String().split('T').first // Định dạng yyyy-MM-dd
                        : ''; // Trả về chuỗi rỗng nếu không chọn ngày
                  });
                }
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Vui lòng chọn ngày";
              }
              return null;
            },
          ),
        ),
      ),
    );
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
      debugPrint("🚨 Lỗi khi lấy danh sách Quy Hoạch: $e");
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
      debugPrint("🚨 Lỗi khi lấy danh sách Thửa Đất: $e");
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
          _nhanVienList = uniqueList;
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Nhân Viên: $e");
    }
  }

  Widget _buildDropdownSearchChuSoHuu() {
    return DropdownSearch<ChuSoHuu>(
      items: _chuSoHuuList,
      itemAsString: (ChuSoHuu chuSoHuu) => chuSoHuu.hoTen,
      selectedItem: _currentSelectedChuSoHuu,
      onChanged: (ChuSoHuu? newValue) {
        setState(() {
          _currentSelectedChuSoHuu = newValue;
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSearchLoaiQuyHoach() {
    return DropdownSearch<QuyHoach>(
      items: _quyHoachList,
      itemAsString: (QuyHoach quyHoach) => quyHoach.loaiQuyHoach ?? 'Không xác định',
      selectedItem: _currentSelectedQuyHoach,
      onChanged: (QuyHoach? newValue) {
        setState(() {
          _currentSelectedQuyHoach = newValue;
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }


  Widget _buildDropdownSearchThuadat() {
    return DropdownSearch<ThuaDat>(
      items: _thuaDatList,
      itemAsString: (ThuaDat thuaDat) => thuaDat.diaChiThuaDat,
      selectedItem: _currentSelectedThuaDat,
      onChanged: (ThuaDat? newValue) {
        setState(() {
          _currentSelectedThuaDat = newValue;
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }


  Widget _buildDropdownSearchNhanvien() {
    return DropdownSearch<Employee>(
      items: _nhanVienList,
      itemAsString: (Employee nhanVien) => nhanVien.hoten,
      selectedItem: _currentSelectedNhanVien,
      onChanged: (Employee? newValue) {
        setState(() {
          _currentSelectedNhanVien = newValue;
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            value: selectedTrangThai ?? widget.hoSoDatDai.trangThai, // Đảm bảo hiển thị trạng thái ban đầu
            decoration: InputDecoration(
              labelText: "Trạng thái",
              labelStyle: TextStyle(color: Colors.blueGrey, fontSize: MediaQuery.of(context).textScaleFactor * 16),
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

  Future<void> _updateHoSo() async {
    if (!_formKey.currentState!.validate()) return;

    HoSoDatDai updatedHoSo = HoSoDatDai(
      hosodatdaiID: widget.hoSoDatDai.hosodatdaiID,
      chusohuuID: chusohuuIDController.text.isNotEmpty ? int.tryParse(chusohuuIDController.text) : null,
      thuadatID: thuadatIDController.text.isNotEmpty ? int.tryParse(thuadatIDController.text) : null,
      quyhoachID: quyhoachIDController.text.isNotEmpty ? int.tryParse(quyhoachIDController.text) : null,
      nhanvienID: nhanvienIDController.text.isNotEmpty ? int.tryParse(nhanvienIDController.text) : null,
      maGiaoDich: maGiaoDichController.text,
      loaiHoSo: loaiHoSoController.text,
      ngayCapGiay: DateTime.tryParse(ngayCapGiayController.text),
      ngayNopHoSo: DateTime.tryParse(ngayNopHoSoController.text),
      ngayXacThucHoSo: DateTime.tryParse(ngayXacThucHoSoController.text),
      ngayDoiPheDuyet: DateTime.tryParse(ngayDoiPheDuyetHoSoController.text),
      tinhTrangHoSo: tinhTrangHoSoController.text,
      ghiChu: ghiChuController.text,
      trangThai: selectedTrangThai ?? widget.hoSoDatDai.trangThai,
      ngayTao: DateTime.tryParse(ngayTaoController.text),
      taiLieuDinhKem: taiLieuDinhKemController.text,
    );

    try {
      bool success = await HoSoDatDaiService().updateHoSoDatDai(updatedHoSo);
      if (success) {
        // Hiển thị thông báo thành công với nút "Xác nhận" và reload trang khi nhấn
        showCustomDialog(
          context,
          title: "Thành công",
          message: "Cập nhật thành công!",
          isSuccess: true,
          onConfirm: () {
            if (mounted) {
              Navigator.of(context).pop();;
              widget.onUpdatehoSo.call();
            }
          },
        );
      } else {
        throw Exception("Lỗi không xác định!");
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
        onConfirm: () => Navigator.of(context).pop(), // Đóng dialog lỗi
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chỉnh sửa hồ sơ đất đai",
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // 5% chiều rộng màn hình cho tiêu đề
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: screenWidth * 0.05, color: Colors.blueAccent), // 5% chiều rộng cho icon
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SizedBox(
            width: screenWidth * 0.9, // 90% chiều rộng màn hình
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.02), // 2% chiều rộng cho padding
                physics: const ClampingScrollPhysics(), // Tối ưu cuộn
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("Mã giao dịch", maGiaoDichController),
                    _buildTextField("Loại hồ sơ", loaiHoSoController),
                    _buildDatePickerField("Ngày cấp giấy", ngayCapGiayController),
                    _buildDatePickerField("Ngày nộp hồ sơ", ngayNopHoSoController),
                    _buildDatePickerField("Ngày xác thực hồ sơ", ngayXacThucHoSoController),
                    _buildDatePickerField("Ngày tạo", ngayTaoController),
                    _buildDatePickerField("Ngày đợi phê duyệt", ngayDoiPheDuyetHoSoController),
                    _buildTextField("Tình trạng hồ sơ", tinhTrangHoSoController),
                    _buildTextField("Ghi chú", ghiChuController),
                    _buildDropdownTrangThai(),
                    SizedBox(height: 20,),
                    _buildDropdownSearchChuSoHuu(),
                    SizedBox(height: 20,),
                    _buildDropdownSearchThuadat(),
                    SizedBox(height: 20,),
                    _buildDropdownSearchLoaiQuyHoach(),
                    SizedBox(height: 20,),
                    _buildDropdownSearchNhanvien(),
                    SizedBox(height: 20,),
                    _buildFilePicker(),
                    SizedBox(height: screenHeight * 0.02), // 2% chiều cao màn hình
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ElevatedButton(
                          onPressed: () {
                            if (mounted) _updateHoSo();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015, // 1.5% chiều cao màn hình
                              horizontal: screenWidth * 0.06, // 6% chiều rộng màn hình
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.015), // 1.5% chiều rộng cho bo tròn
                            ),
                          ),
                          child: Text(
                            "Lưu",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // 4% chiều rộng màn hình
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.015), // 1.5% chiều rộng cho bo tròn
      ),
      elevation: 8,
      backgroundColor: Colors.white,
    );
  }
}