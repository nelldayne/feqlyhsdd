class ThuaDat {
  final int thuadatID;
  final String maThuaDat;
  final String toBanDo;
  final String diaChiThuaDat;
  final double dienTich; // Giả định "DienTich" là số thực (double)
  final String loaiDat;
  final String ranhgioi;
  final String mucDichSuDung;
  final String tinhTrangPhapLy;
  final String trangThaiSuDung;
  final DateTime? ngayCapGiayChungNhan; // Có thể null, dạng DateTime
  final int? chusohuuID; // Có thể null, dạng số nguyên
  final int? quyhoachID; // Có thể null, dạng số nguyên
  final double? kinhdo;
  final double? vido;
  final String? ghichu; // Có thể null, dạng chuỗi
  final String? hoTen; // Có thể null, dạng chuỗi
  final String? loaiQuyhoach; // Có thể null, dạng chuỗi
  final String? soDienThoai;

  ThuaDat({
    required this.thuadatID,
    required this.maThuaDat,
    required this.toBanDo,
    required this.diaChiThuaDat,
    required this.dienTich,
    required this.loaiDat,
    required this.ranhgioi,
    required this.mucDichSuDung,
    required this.tinhTrangPhapLy,
    required this.trangThaiSuDung,
    this.ngayCapGiayChungNhan,
    this.chusohuuID,
    this.quyhoachID,
    this.kinhdo,
    this.vido,
    this.ghichu,
    this.hoTen,
    this.loaiQuyhoach,
    this.soDienThoai
  });

  // Factory method để tạo từ JSON (phân tích dữ liệu từ API)
  factory ThuaDat.fromJson(Map<String, dynamic> json) {
    return ThuaDat(
      thuadatID: json['ThuadatID'] as int,
      maThuaDat: json['MaThuaDat'] as String,
      toBanDo: json['ToBanDo'] as String,
      diaChiThuaDat: json['DiaChiThuaDat'] as String,
      dienTich: (json['DienTich'] is num) ? (json['DienTich'] as num).toDouble() : 0.0,
      loaiDat: json['LoaiDat'] as String,
      ranhgioi: json['Ranhgioi'] as String,
      mucDichSuDung: json['MucDichSuDung'] as String,
      tinhTrangPhapLy: json['TinhTrangPhapLy'] as String,
      trangThaiSuDung: json['TrangThaiSuDung'] as String,
      ngayCapGiayChungNhan: json['NgayCapGiayChungNhan'] != null
          ? DateTime.parse(json['NgayCapGiayChungNhan'] as String)
          : null,
      chusohuuID: json['ChusohuuID'] as int?,
      quyhoachID: json['QuyhoachID'] as int?,
      kinhdo: (json['kinhdo'] is num) ? (json['kinhdo'] as num).toDouble() : null,
      vido: (json['vido'] is num) ? (json['vido'] as num).toDouble() : null,
      ghichu: json['Ghichu'] as String?,
      hoTen: json['HoTen'] as String?,
      loaiQuyhoach: json['LoaiQuyhoach'] as String?,
      soDienThoai: json['SoDienThoai'],
    );
  }

  factory ThuaDat.fromMiniJson(Map<String, dynamic> json) {
    return ThuaDat(
      thuadatID: json['ThuadatID'] is int ? json['ThuadatID'] as int : 0,
      maThuaDat: json['MaThuaDat'] is String ? json['MaThuaDat'] as String : "Không xác định",
      toBanDo: json['ToBanDo'] is String ? json['ToBanDo'] as String : "Không xác định",
      diaChiThuaDat: json['DiaChiThuaDat'] is String ? json['DiaChiThuaDat'] as String : "Không xác định",
      dienTich: (json['DienTich'] is num)
          ? (json['DienTich'] as num).toDouble()
          : 0.0,
      loaiDat: json['LoaiDat'] is String ? json['LoaiDat'] as String : "Không xác định",
      ranhgioi: json['Ranhgioi'] is String ? json['Ranhgioi'] as String : "Không xác định",
      mucDichSuDung: json['MucDichSuDung'] is String ? json['MucDichSuDung'] as String : "Chưa cấp chứng nhận",
      tinhTrangPhapLy: json['TinhTrangPhapLy'] is String ? json['TinhTrangPhapLy'] as String : "Không xác định",
      trangThaiSuDung: json['TrangThaiSuDung'] is String ? json['TrangThaiSuDung'] as String : "Không xác định",
      ngayCapGiayChungNhan: json['NgayCapGiayChungNhan'] != null
          ? DateTime.tryParse(json['NgayCapGiayChungNhan'] as String)
          : null,
      chusohuuID: json['ChusohuuID'] is int ? json['ChusohuuID'] as int : null,
      quyhoachID: json['QuyhoachID'] is int ? json['QuyhoachID'] as int : null,
      kinhdo: (json['kinhdo'] is num)
          ? (json['kinhdo'] as num).toDouble()
          : null,
      vido: (json['vido'] is num)
          ? (json['vido'] as num).toDouble()
          : null,
      ghichu: json['Ghichu'] is String ? json['Ghichu'] as String : null,
      hoTen: json['HoTen'] is String ? json['HoTen'] as String : null,
      loaiQuyhoach: json['LoaiQuyhoach'] is String ? json['LoaiQuyhoach'] as String : null,
      soDienThoai: json['SoDienThoai'] is String ? json['SoDienThoai'] as String : null,
    );
  }

  // Phương thức chuyển đổi thành JSON (dùng khi gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'ThuadatID': thuadatID,
      'MaThuaDat': maThuaDat,
      'ToBanDo': toBanDo,
      'DiaChiThuaDat': diaChiThuaDat,
      'DienTich': dienTich.toString(),
      'LoaiDat': loaiDat,
      'Ranhgioi': ranhgioi,
      'MucDichSuDung': mucDichSuDung,
      'TinhTrangPhapLy': tinhTrangPhapLy,
      'TrangThaiSuDung': trangThaiSuDung,
      'NgayCapGiayChungNhan': ngayCapGiayChungNhan?.toIso8601String(),
      'ChusohuuID': chusohuuID,
      'QuyhoachID': quyhoachID,
      'kinhdo': kinhdo.toString(),
      'vido': vido.toString(),
      'Ghichu': ghichu,
    };
  }
}