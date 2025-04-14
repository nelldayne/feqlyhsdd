class Employee {
  final int id;
  final int taikhoanid; // Sửa lại kiểu dữ liệu từ String -> int
  final String email;
  final String hoten;
  final DateTime ngaysinh; // Sửa lại kiểu dữ liệu từ String -> DateTime
  final String gioitinh;
  final String phongban;
  final String sodienthoai;
  final String trangthai;

  Employee({
    required this.id,
    required this.taikhoanid,
    required this.email,
    required this.hoten,
    required this.ngaysinh,
    required this.gioitinh,
    required this.phongban,
    required this.sodienthoai,
    required this.trangthai,
  });

  // Chuyển đổi từ JSON sang Object
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['NhanvienID'] as int,
      taikhoanid: json['TaikhoanID'] as int,
      hoten: json['HoTen'] ?? "Không có tên",
      ngaysinh: DateTime.parse(json['NgaySinh']), // Chuyển đổi String -> DateTime
      gioitinh: json['GioiTinh'] ?? "Không rõ",
      phongban: json['PhongBan'] ?? "Không có phòng ban",
      sodienthoai: json['SoDienThoai'] ?? "Chưa có số điện thoại",
      email: json['Email'] ?? "Không có email",
      trangthai: json['TrangThai'] ?? "Không rõ",
    );
  }

  // Chuyển đổi từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'NhanvienID': id,
      'TaikhoanID': taikhoanid,
      'HoTen': hoten,
      'NgaySinh': ngaysinh.toIso8601String(), // Chuyển DateTime -> String
      'GioiTinh': gioitinh,
      'PhongBan': phongban,
      'SoDienThoai': sodienthoai,
      'Email': email,
      'TrangThai': trangthai,
    };
  }
  factory Employee.fromMiniJson(Map<String, dynamic> json) {
    return Employee(
      id: json['NhanvienID'] as int,
      taikhoanid: 0, // Gán mặc định vì không có thông tin
      email: "", // Gán mặc định
      hoten: json['HoTen'] as String? ?? "Không có tên",
      ngaysinh: DateTime(1970, 1, 1), // Giá trị mặc định vì không có thông tin
      gioitinh: "",
      phongban: "",
      sodienthoai: "",
      trangthai: "",
    );
  }
}
