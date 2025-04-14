class QuanLy {
  final int quanlyID;
  final int taikhoanID;
  final String hoTen;
  final String phongBan;
  final String soDienThoai;
  final String email;

  QuanLy({
    required this.quanlyID,
    required this.taikhoanID,
    required this.hoTen,
    required this.phongBan,
    required this.soDienThoai,
    required this.email,
  });

  factory QuanLy.fromJson(Map<String, dynamic> json) {
    return QuanLy(
      quanlyID: json['QuanlyID'] as int,
      taikhoanID: json['TaikhoanID'] as int,
      hoTen: json['HoTen'] as String,
      phongBan: json['PhongBan'] as String,
      soDienThoai: json['SoDienThoai'] as String,
      email: json['Email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'QuanlyID': quanlyID,
      'TaikhoanID': taikhoanID,
      'HoTen': hoTen,
      'PhongBan': phongBan,
      'SoDienThoai': soDienThoai,
      'Email': email,
    };
  }
}class Quanly{

}