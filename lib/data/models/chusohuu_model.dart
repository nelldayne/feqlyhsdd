class ChuSoHuu {
  final int chusohuuID;
  final String hoTen;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? soCMND_CCCD;
  final DateTime? ngayCap;
  final String? noiCap;
  final String? diaChiThuongTru;
  final String? diaChiLienHe;
  final String? soDienThoai;
  final String? email;
  final int? taikhoanID;
  ChuSoHuu({
    required this.chusohuuID,
    required this.hoTen,
    required this.ngaySinh,
    this.gioiTinh,
    required this.soCMND_CCCD,
    required this.ngayCap,
    this.noiCap,
    required this.diaChiThuongTru,
    this.diaChiLienHe,
    this.soDienThoai,
    this.email,
    this.taikhoanID
  });

  // 📥 Chuyển từ JSON -> Object
  factory ChuSoHuu.fromJson(Map<String, dynamic> json) {
    return ChuSoHuu(
      chusohuuID: json['ChusohuuID'],
      hoTen: json['HoTen'],
      ngaySinh: DateTime.parse(json['NgaySinh']),
      gioiTinh: json['GioiTinh'],
      soCMND_CCCD: json['SoCMND_CCCD'],
      ngayCap: DateTime.parse(json['NgayCap']),
      noiCap: json['NoiCap'],
      diaChiThuongTru: json['DiaChiThuongTru'],
      diaChiLienHe: json['DiaChiLienHe'],
      soDienThoai: json['SoDienThoai'],
      email: json['Email'],
      taikhoanID:  json['TaikhoanID']
    );
  }
  factory ChuSoHuu.fromMinimalJson(Map<String, dynamic> json) {
    return ChuSoHuu(
      chusohuuID: json['ChusohuuID'] ?? 0,
      hoTen: json['HoTen'] ?? 'Không xác định',
      ngaySinh: null,
      gioiTinh: null,
      soCMND_CCCD: null,
      ngayCap: null,
      noiCap: null,
      diaChiThuongTru: null,
      diaChiLienHe: null,
      soDienThoai: null,
      email: null,
      taikhoanID: null
    );
  }



  // 📤 Chuyển từ Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ChusohuuID': chusohuuID,
      'HoTen': hoTen,
      'NgaySinh': ngaySinh?.toIso8601String(),
      'GioiTinh': gioiTinh,
      'SoCMND_CCCD': soCMND_CCCD,
      'NgayCap': ngayCap?.toIso8601String(),
      'NoiCap': noiCap,
      'DiaChiThuongTru': diaChiThuongTru,
      'DiaChiLienHe': diaChiLienHe,
      'SoDienThoai': soDienThoai,
      'Email': email,
      'TaikhoanID': taikhoanID
    };
  }
}
