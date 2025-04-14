class ThongKeThuaDat {
  final String xa;
  final int soLuongThuaDat;

  ThongKeThuaDat({required this.xa, required this.soLuongThuaDat});

  factory ThongKeThuaDat.fromJson(Map<String, dynamic> json) {
    return ThongKeThuaDat(
      xa: json['Xa'] ?? 'Không xác định',
      soLuongThuaDat: json['SoLuongThuaDat'] ?? 0,
    );
  }
}
