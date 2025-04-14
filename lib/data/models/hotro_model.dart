class HoTro {
  final int? hoTroID;
  final int? chusohuuID;
  final String? noiDungHoTro;
  final String? trangThaiHoTro;
  final DateTime? ngayTao;
  final DateTime? ngayHoanThanh;
  final int? nhanvienID;
  final String? ghiChu;
  final String? soDienThoai;
  final DateTime? ngayCapNhat;
  HoTro({
    required this.hoTroID,
    required this.chusohuuID,
    required this.noiDungHoTro,
    required this.trangThaiHoTro,
    required this.ngayTao,
    this.ngayHoanThanh,
    this.nhanvienID,
    this.ghiChu,
    required this.soDienThoai,
    this.ngayCapNhat
  });

  factory HoTro.fromJson(Map<String, dynamic> json) {
    return HoTro(
      hoTroID: json['HoTroID'] as int?,
      chusohuuID: json['ChusohuuID'] as int?,
      noiDungHoTro: json['NoiDungHoTro']?.toString(),
      trangThaiHoTro: json['TrangThaiHoTro']?.toString(),
      ngayTao: json['NgayTao'] != null ? DateTime.tryParse(json['NgayTao']) : null,
      ngayHoanThanh: json['NgayHoanThanh'] != null ? DateTime.tryParse(json['NgayHoanThanh']) : null,
      nhanvienID: json['NhanvienID'] as int?,
      ghiChu: json['GhiChu']?.toString(),
      soDienThoai: json['SoDienThoai'].toString(),
      ngayCapNhat: json['NgayCapNhat'] != null ? DateTime.tryParse(json['NgayCapNhat']) : null,

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'HoTroID': hoTroID,
      'ChusohuuID': chusohuuID,
      'NoiDungHoTro': noiDungHoTro,
      'TrangThaiHoTro': trangThaiHoTro,
      'NgayTao': ngayTao?.toIso8601String(),
      'NgayHoanThanh': ngayHoanThanh?.toIso8601String(),
      'NhanvienID': nhanvienID,
      'GhiChu': ghiChu,
      'SoDienThoai': soDienThoai,
      'NgayCapNhat': ngayCapNhat?.toIso8601String(),
    };
  }

}
