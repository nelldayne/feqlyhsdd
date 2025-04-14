import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:qlyhoso/data/models/chusohuu_model.dart';
import 'package:qlyhoso/data/models/quyhoach_model.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/presentation/widgets/thongbao_Dialog.dart';
import 'package:qlyhoso/services/chusohuu_serviecs.dart';
import 'package:qlyhoso/services/quyhoach_Serviecs.dart';
import '../../services/thuadat_Services.dart';

class updateThuaDatDetailDialog extends StatefulWidget {
  final ThuaDat thuaDat;
  final VoidCallback? onThuaDatUpdated;
  const updateThuaDatDetailDialog({super.key, required this.thuaDat, this.onThuaDatUpdated});

  @override
  ThuaDatDetailDialogState createState() => ThuaDatDetailDialogState();
}

class ThuaDatDetailDialogState extends State<updateThuaDatDetailDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<ChuSoHuu> _chuSoHuuList = [];
  List<QuyHoach> _quyHoachList = [];
  ChuSoHuu? _selectedChuSoHuu;
  QuyHoach? _selectedQuyHoach;
  String? _selectedQuyhoach;
  String? _selectedloaiQuyhoach;


  late TextEditingController maThuaDatController;
  late TextEditingController toBanDoController;
  late TextEditingController diaChiController;
  late TextEditingController dienTichController;
  late TextEditingController loaiDatController;
  late TextEditingController ranhGioiController;
  late TextEditingController mucDichSuDungController;
  late TextEditingController tinhTrangPhapLyController;
  late TextEditingController quyHoachController;
  late TextEditingController trangThaiController;
  late TextEditingController ngayCapGCNController;
  late TextEditingController chuSoHuuController;
  late TextEditingController ghiChuController;
  late TextEditingController kinhdoController;
  late TextEditingController vidoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String formatNgayCap(String? ngayCap) {
    try {
      if (ngayCap == null || ngayCap.isEmpty) return 'Không có thông tin';
      DateTime parsedDate = DateTime.parse(ngayCap).toLocal(); // Chuyển sang giờ địa phương
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

    maThuaDatController = TextEditingController(text: widget.thuaDat.maThuaDat);
    toBanDoController = TextEditingController(text: widget.thuaDat.toBanDo);
    diaChiController = TextEditingController(text: widget.thuaDat.diaChiThuaDat);
    dienTichController = TextEditingController(text: widget.thuaDat.dienTich.toString());
    loaiDatController = TextEditingController(text: widget.thuaDat.loaiDat);
    ranhGioiController = TextEditingController(text: widget.thuaDat.ranhgioi);
    mucDichSuDungController = TextEditingController(text: widget.thuaDat.mucDichSuDung);

    kinhdoController = TextEditingController(text: widget.thuaDat.kinhdo.toString());
    vidoController = TextEditingController(text: widget.thuaDat.vido.toString());

    tinhTrangPhapLyController = TextEditingController(text: widget.thuaDat.tinhTrangPhapLy);
    quyHoachController = TextEditingController(text: widget.thuaDat.quyhoachID?.toString() ?? "");
    trangThaiController = TextEditingController(text: widget.thuaDat.trangThaiSuDung);
    ngayCapGCNController = TextEditingController(text: formatNgayCap(widget.thuaDat.ngayCapGiayChungNhan.toString()));
    chuSoHuuController = TextEditingController(text: widget.thuaDat.chusohuuID?.toString() ?? "");
    ghiChuController = TextEditingController(text: widget.thuaDat.ghichu ?? "");
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
    trangThaiController.dispose();
    ngayCapGCNController.dispose();
    chuSoHuuController.dispose();
    ghiChuController.dispose();
    kinhdoController.dispose();
    vidoController.dispose();
    super.dispose();
  }




  Future<void> _updateThuaDat() async {
    if (!_formKey.currentState!.validate()) return;
    ThuaDat updatedThuaDat = ThuaDat(
      thuadatID: widget.thuaDat.thuadatID,
      maThuaDat: maThuaDatController.text,
      toBanDo: toBanDoController.text,
      diaChiThuaDat: diaChiController.text,
      dienTich: double.tryParse(dienTichController.text) ?? 0.0,
      kinhdo: double.tryParse(kinhdoController.text) ?? 0.0,
      vido: double.tryParse(vidoController.text) ?? 0.0,
      loaiDat: loaiDatController.text,
      ranhgioi: ranhGioiController.text,
      mucDichSuDung: mucDichSuDungController.text,
      tinhTrangPhapLy: tinhTrangPhapLyController.text,
      trangThaiSuDung: trangThaiController.text,
      ngayCapGiayChungNhan: ngayCapGCNController.text.isNotEmpty
          ? DateTime.tryParse(ngayCapGCNController.text)
          : null,
      chusohuuID: chuSoHuuController.text.isNotEmpty ? int.parse(chuSoHuuController.text) : null,
      quyhoachID: quyHoachController.text.isNotEmpty ? int.parse(quyHoachController.text) : null,
      ghichu: ghiChuController.text.isNotEmpty ? ghiChuController.text : null,
    );

    try {
      bool success = await ThuaDatService().updateThuaDat(updatedThuaDat);
      if(!mounted) return;
      if (success) {
        // Hiển thị thông báo thành công với nút "Xác nhận" và quay lại khi nhấn
        showCustomDialog(
          context,
          title: "Thành công",
          message: "Cập nhật thành công!",
          isSuccess: true,
          onConfirm: () {
            if (mounted) {
              Navigator.of(context).pop(); // Đóng dialog chi tiết
              widget.onThuaDatUpdated?.call();
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


  Future<void> _fetchChuSoHuu() async {
    try {
      List<ChuSoHuu> list = await ChuSoHuuService().getListHoTenChuSoHuu();

      if (mounted) {
        setState(() {
          _chuSoHuuList = list;
          if (widget.thuaDat.chusohuuID != null) {
            _selectedChuSoHuu = list.firstWhere((chuSoHuu) => chuSoHuu.chusohuuID == widget.thuaDat.chusohuuID,
              orElse: () => ChuSoHuu(
                chusohuuID: 0,
                hoTen: 'Không xác định',
                ngaySinh: null,
                gioiTinh: null,
                soCMND_CCCD: null,
                ngayCap: null,
                noiCap: null,
                diaChiThuongTru: null,
                diaChiLienHe: null,
                soDienThoai: null,
                email: null,
              ),
            );
          } else {
            _selectedChuSoHuu = null;
          }
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
      if (mounted) {
        setState(() {
          _chuSoHuuList = [];
          _selectedChuSoHuu = null;
        });
      }
    }
  }

  Future<void> _fetchQuyHoach() async {
    try {
      List<QuyHoach> list = await QuyHoachService().getListLoaiQuyHoach();
      if (mounted) {
        setState(() {
          _quyHoachList = list;
          if (widget.thuaDat.quyhoachID != null) {
            _selectedQuyHoach = list.firstWhere((quyHoach) => quyHoach.quyhoachID == widget.thuaDat.quyhoachID,
              orElse: () => QuyHoach(
                quyhoachID: -1,
                loaiQuyHoach: 'Không có thông tin',
                moTa: 'Không có thông tin',
                thoiGianBatDau: DateTime.now(),
                thoiGianKetThuc: DateTime.now(),
                trangThai: 'Không có thông tin',
              ),
            );
          } else {
            _selectedQuyHoach = null;
          }
        });
      }
    } catch (e) {
      debugPrint("🚨 Lỗi khi lấy danh sách Chủ Sở Hữu: $e");
      if (mounted) {
        setState(() {
          _quyHoachList = [];
          _selectedQuyHoach= null;
        });
      }
    }
  }


  Widget _buildDropdownSearchChuSoHuu() {
    return DropdownSearch<ChuSoHuu>(
      items: _chuSoHuuList,
      itemAsString: (ChuSoHuu chuSoHuu) => chuSoHuu.hoTen,
      selectedItem: _chuSoHuuList.firstWhere(
            (chuSoHuu) => chuSoHuu.chusohuuID == widget.thuaDat.chusohuuID,
        orElse: () => ChuSoHuu(
          chusohuuID: 0,
          hoTen: 'Không xác định',
          ngaySinh: null,
          gioiTinh: null,
          soCMND_CCCD: null,
          ngayCap: null,
          noiCap: null,
          diaChiThuongTru: null,
          diaChiLienHe: null,
          soDienThoai: null,
          email: null,
        ),
      ),

      onChanged: (ChuSoHuu? newValue) {
        setState(() {
          chuSoHuuController.text = newValue?.chusohuuID.toString() ?? '';
        });
      },

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Tên chủ sở hữu",
          hintText: "Chọn chủ sơ hữu",
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
      selectedItem: _quyHoachList.firstWhere(
            (quyHoach) => quyHoach.quyhoachID == widget.thuaDat.quyhoachID,
        orElse: () => QuyHoach(
          quyhoachID: -1,
          loaiQuyHoach: 'Không có thông tin',
          moTa: 'Không có thông tin',
          thoiGianBatDau: DateTime.now(),
          thoiGianKetThuc: DateTime.now(),
          trangThai: 'Không có thông tin',
        ),
      ),

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
                "Chỉnh Sửa Thửa Đất",
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
                    _buildTextField("Mã thửa đất", maThuaDatController),
                    _buildTextField("Số hiệu tờ bản đồ", toBanDoController),
                    _buildTextField("Địa chỉ", diaChiController),
                    _buildTextField("Diện tích", dienTichController, isNumber: true, isOptional: true),
                    _buildTextField("Vĩ độ", vidoController, isNumber: true,  isOptional: true),
                    _buildTextField("Kinh độ", kinhdoController, isNumber: true,  isOptional: true),
                    _buildTextField("Loại đất", loaiDatController),
                    _buildTextField("Ranh giới", ranhGioiController),
                    _buildTextField("Mục đích sử dụng", mucDichSuDungController),
                    _buildTextField("Tình trạng pháp lý", tinhTrangPhapLyController),
                    _buildTextField("Trạng thái sử dụng", trangThaiController),
                    _buildDatePickerField("Ngày cấp GCN", ngayCapGCNController),
                    SizedBox(height: 5,),
                    _buildDropdownSearchChuSoHuu(),
                    SizedBox(height: 15,),
                    _buildDropdownSearchLoaiQuyHoach(),
                    SizedBox(height: 15,),
                    _buildTextField("Ghi chú", ghiChuController, isOptional: true),
                    SizedBox(height: screenHeight * 0.02), // 2% chiều cao màn hình
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ElevatedButton(
                          onPressed: () {
                            if (mounted) _updateThuaDat();
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