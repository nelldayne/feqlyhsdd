class LichHop {
  final int? lichhopID;
  final String tenCuocHop;
  final DateTime thoiGianHop;
  final String diaDiemHop;
  final String? noiDung;
  final String? nguoiChuTri;
  final String? trangThai;
  final String? thu;
  LichHop({
    this.lichhopID,
    required this.tenCuocHop,
    required this.thoiGianHop,
    required this.diaDiemHop,
    this.noiDung,
    this.nguoiChuTri,
    this.trangThai,
    this.thu
  });

  // Chuyển từ JSON sang Object
  factory LichHop.fromJson(Map<String, dynamic> json) {
    return LichHop(
      lichhopID: json['LichhopID'],
      tenCuocHop: json['TenCuocHop'],
      thoiGianHop: DateTime.parse(json['ThoiGianHop']),
      diaDiemHop: json['DiaDiemHop'],
      noiDung: json['NoiDung'],
      nguoiChuTri: json['NguoiChuTri'],
      trangThai: json['TrangThai'] ?? 'Dự kiến',
      thu: json['Thu'],
    );
  }

  // Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'LichhopID': lichhopID,
      'TenCuocHop': tenCuocHop,
      'ThoiGianHop': thoiGianHop.toIso8601String(),
      'DiaDiemHop': diaDiemHop,
      'NoiDung': noiDung,
      'NguoiChuTri': nguoiChuTri,
      'TrangThai': trangThai,
    };
  }
}
