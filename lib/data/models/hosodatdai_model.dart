class HoSoDatDai {
  final int hosodatdaiID;
  final int? chusohuuID;
  final int? thuadatID;
  final int? quyhoachID;
  final DateTime? ngayCapGiay;
  final DateTime? ngayNopHoSo;
  final DateTime? ngayXacThucHoSo;
  final DateTime? ngayDoiPheDuyet;
  final String? tinhTrangHoSo;
  final String? maGiaoDich;
  final String? loaiHoSo;
  final String? ghiChu;
  final String? trangThai;
  final int? nhanvienID;
  final DateTime? ngayTao;
  final String? taiLieuDinhKem;
  final String? tenNhanVien;
  final String? tenChuSoHuu;
  final String? tenQuyHoach;
  final String? maThuaDat;

  HoSoDatDai({
    required this.hosodatdaiID,
    this.chusohuuID,
    this.thuadatID,
    this.quyhoachID,
    this.ngayCapGiay,
    this.ngayNopHoSo,
    this.ngayXacThucHoSo,
    this.ngayDoiPheDuyet,
    this.tinhTrangHoSo,
    this.maGiaoDich,
    this.loaiHoSo,
    this.ghiChu,
    this.trangThai,
    this.ngayTao,
    this.nhanvienID,
    this.taiLieuDinhKem,
    this.tenNhanVien,
    this.tenChuSoHuu,
    this.tenQuyHoach,
    this.maThuaDat,
  });

  factory HoSoDatDai.fromJson(Map<String, dynamic> json) {
    return HoSoDatDai(
      hosodatdaiID: json['HosodatdaiID'],
      chusohuuID: json['ChusohuuID'],
      thuadatID: json['ThuadatID'],
      quyhoachID: json['QuyhoachID'],
      ngayCapGiay: json['NgayCapGiay'] != null
          ? DateTime.parse(json['NgayCapGiay'])
          : null,
      ngayNopHoSo: json['NgayNopHoSo'] != null
          ? DateTime.parse(json['NgayNopHoSo'])
          : null,
      ngayDoiPheDuyet: json['NgayDoiPheDuyet'] != null
          ? DateTime.parse(json['NgayDoiPheDuyet'])
          : null,
      ngayXacThucHoSo: json['NgayXacThucHoSo'] != null
          ? DateTime.parse(json['NgayXacThucHoSo'])
          : null,
      tinhTrangHoSo: json['TinhTrangHoSo'],
      maGiaoDich: json['MaGiaoDich'],
      loaiHoSo: json['LoaiHoSo'],
      ghiChu: json['GhiChu'],
      trangThai: json['TrangThai'],
      ngayTao:json['NgayTao'] != null
          ? DateTime.parse(json['NgayTao'])
          : null,
      nhanvienID: json['NhanvienID'],
      taiLieuDinhKem:json['TaiLieuDinhKem'],
      tenNhanVien: json['TenNhanVien'],
      tenChuSoHuu: json['TenChuSoHuu'],
      tenQuyHoach: json['TenQuyhoach'],
      maThuaDat: json['MaThuaDat'],

    );

  }

  Map<String, dynamic> toJson() {
    return {
      'HosodatdaiID': hosodatdaiID,
      'ChusohuuID': chusohuuID,
      'ThuadatID': thuadatID,
      'QuyhoachID': quyhoachID,
      'NgayCapGiay': ngayCapGiay?.toIso8601String(),
      'NgayNopHoSo': ngayNopHoSo?.toIso8601String(),
      'NgayXacThucHoSo': ngayXacThucHoSo?.toIso8601String(),
      'NgayDoiPheDuyet': ngayDoiPheDuyet?.toIso8601String(),
      'TinhTrangHoSo': tinhTrangHoSo,
      'MaGiaoDich': maGiaoDich,
      'LoaiHoSo': loaiHoSo,
      'GhiChu': ghiChu,
      'TrangThai': trangThai,
      'NhanvienID': nhanvienID,
      'NgayTao': ngayTao?.toIso8601String(),
      'TaiLieuDinhKem': taiLieuDinhKem,
    };
  }
}
