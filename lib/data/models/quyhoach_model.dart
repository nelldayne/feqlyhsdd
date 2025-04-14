class QuyHoach {
  final int quyhoachID;
  final String? loaiQuyHoach;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final String? moTa;
  final String? trangThai;
  final double? dienTich;
  QuyHoach({
    required this.quyhoachID,
    required this.loaiQuyHoach,
    required this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.moTa,
    required this.trangThai,
    this.dienTich
  });

  // Chuyển từ JSON thành đối tượng QuyHoach
  factory QuyHoach.fromJson(Map<String, dynamic> json) {
    return QuyHoach(
      quyhoachID: json['QuyhoachID'],
      loaiQuyHoach: json['LoaiQuyhoach'],
      thoiGianBatDau: DateTime.parse(json['ThoiGianBatDau']),
      thoiGianKetThuc: json['ThoiGianKetThuc'] != null ? DateTime.parse(json['ThoiGianKetThuc']) : null,
      moTa: json['MoTa'],
      trangThai: json['TrangThai'],
      dienTich: (json['DienTich'] as num ).toDouble()
    );
  }
  factory QuyHoach.fromminiJson(Map<String, dynamic> json) {
    return QuyHoach(
      quyhoachID: json['QuyhoachID'],
      loaiQuyHoach: json['LoaiQuyHoach'],
      thoiGianBatDau: null,
      trangThai: null,
      moTa: null,
      thoiGianKetThuc: null,
      dienTich: null
    );
    }

  // Chuyển từ đối tượng QuyHoach sang JSON
  Map<String, dynamic> toJson() {
    return {
      'QuyhoachID': quyhoachID,
      'LoaiQuyhoach': loaiQuyHoach,
      'ThoiGianBatDau': thoiGianBatDau?.toIso8601String() ,
      'ThoiGianKetThuc': thoiGianKetThuc != null ? thoiGianKetThuc!.toIso8601String() : null,
      'MoTa': moTa,
      'TrangThai': trangThai,
      'DienTich': dienTich
    };
  }
}
