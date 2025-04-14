class TaiKhoan{
  final int taikhoanID;
  final String tenDangNhap;
  final String matKhau;
  final String email;
  final String? soDienThoai;
  final String vaiTro;
  final DateTime ngayTao;
  final String trangThai;
  TaiKhoan({
    required this.taikhoanID,
    required this.tenDangNhap,
    required this.matKhau,
    required this.email,
    this.soDienThoai,
    required this.vaiTro,
    required this.ngayTao,
    required this.trangThai
  });
  factory TaiKhoan.fromJson(Map<String, dynamic> json){
    return TaiKhoan(
      taikhoanID: json["TaikhoanID"],
      tenDangNhap: json["TenDangNhap"],
      matKhau: json["MatKhau"],
      email: json["Email"],
      soDienThoai: json["SoDienThoai"],
      vaiTro: json["VaiTro"],
      ngayTao: DateTime.parse(json["NgayTao"]),
      trangThai: json["TrangThai"],
    );
  }
  Map<String,dynamic> toJson(){
    return{
      "TaikhoanID": taikhoanID,
      "TenDangNhap": tenDangNhap,
      "MatKhau": matKhau,
      "Email": email,
      "SoDienThoai": soDienThoai,
      "VaiTro": vaiTro,
      "TrangThai": trangThai,

  };
}

}