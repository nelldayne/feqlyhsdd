import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qlyhoso/components/search_bar.dart';
import 'package:qlyhoso/data/models/thuadat_model.dart';
import 'package:qlyhoso/services/map_serviecs.dart';
import 'package:qlyhoso/services/thuadat_Services.dart';
import 'package:url_launcher/url_launcher.dart';
class MapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? thuaDatId;

  const MapScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.thuaDatId,
  });

  @override
  MapScreenState createState() => MapScreenState();
}

enum MapMode { normal, satellite, hybrid }
enum TravelMode { driving, walking, bicycling } // Chế độ di chuyển

class MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late MapController mapController;
  TextEditingController addressController = TextEditingController();
  LatLng currentLocation = LatLng(21.6304358, 105.6412527); // Vị trí ban đầu
  final TextEditingController _searchController = TextEditingController();
  MapMode _mapMode = MapMode.hybrid;
  TravelMode _travelMode = TravelMode.driving; // Chế độ di chuyển mặc định
  bool _isLoading = false;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  bool _isMapReady = false; // Biến kiểm tra bản đồ đã sẵn sàng
  List<ThuaDat> thuaDatList = [];
  List<LatLng> routePoints = []; // Lưu trữ tọa độ đường đi
  List<Map<String, dynamic>> routeSteps = []; // Lưu trữ các bước hướng dẫn
  bool isRouteVisible = false; // Chuyển đổi hiển thị đường đi
  bool showRouteSteps = false; // Chuyển đổi hiển thị danh sách hướng dẫn

  // Khởi tạo RouteService
  final RouteService _routeService = RouteService();

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonFadeAnimation = CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut);
    _buttonSlideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    _buttonAnimationController.forward();
    mapController = MapController();

    if (widget.latitude != null && widget.longitude != null) {
      currentLocation = LatLng(widget.latitude!, widget.longitude!);
    } else {
      _determinePosition();
    }

    _fetchThuaDatList();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    addressController.dispose();
    _searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchThuaDatList() async {
    setState(() => _isLoading = true);
    try {
      final fetchedList = await ThuaDatService().fetchThuadatList();
      setState(() {
        thuaDatList = fetchedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Lỗi khi tải danh sách thửa đất: $e");
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog("GPS chưa được bật!");
      setState(() => _isLoading = false);
      return;
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog("Bạn cần cấp quyền truy cập vị trí!");
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog("Ứng dụng bị chặn quyền truy cập vị trí!");
      setState(() => _isLoading = false);
      return;
    }

    // Lấy vị trí hiện tại
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Di chuyển bản đồ đến vị trí hiện tại
      if (_isMapReady) {
        mapController.move(currentLocation, 16.0);
      }
    } catch (e) {
      _showErrorDialog("Lỗi khi lấy vị trí: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String keyword) async {
    if (keyword.isEmpty) return;
    setState(() => _isLoading = true);
    LatLng? newLocation = await getCoordinatesFromAddress(keyword);

    if (newLocation != null) {
      setState(() {
        currentLocation = newLocation;
        _isLoading = false;
      });
      if (_isMapReady) {
        mapController.move(newLocation, 16.0);
      }
    } else {
      _showErrorDialog("Không tìm thấy vị trí!");
      setState(() => _isLoading = false);
    }
  }

  void _performZoom(double deltaZoom) {
    if (!_isMapReady) return;
    double newZoom = mapController.camera.zoom + deltaZoom;
    if (newZoom >= 2.0 && newZoom <= 24.0) {
      mapController.move(mapController.camera.center, newZoom);
    }
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thông báo"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleMapMode() {
    setState(() {
      _mapMode = _mapMode == MapMode.normal
          ? MapMode.satellite
          : _mapMode == MapMode.satellite
          ? MapMode.hybrid
          : MapMode.normal;
    });
  }

  void _changeTravelMode(TravelMode mode) {
    setState(() {
      _travelMode = mode;
    });
    // Tính lại đường đi nếu đang hiển thị
    if (isRouteVisible && routePoints.isNotEmpty) {
      _showRoute(thuaDatList.firstWhere((thuaDat) => thuaDat.vido == routePoints.last.latitude && thuaDat.kinhdo == routePoints.last.longitude));
    }
  }

  List<Marker> _buildThuaDatMarkers() {
    if (thuaDatList.isEmpty) {
      return [];
    }

    return thuaDatList
        .where((thuaDat) => thuaDat.kinhdo != null && thuaDat.vido != null)
        .map((thuaDat) => Marker(
      point: LatLng(thuaDat.vido!, thuaDat.kinhdo!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          _showThuaDatInfo(thuaDat);
        },
        child: Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 40,
        ),
      ),
    ))
        .toList();
  }

  // Sử dụng RouteService để lấy đường đi
  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    try {
      final routeData = await _routeService.calculateRoute(
        start,
        end,
        _travelMode.toString().split('.').last, // Chuyển đổi TravelMode thành chuỗi
      );

      setState(() {
        routePoints = routeData.routePoints;
        routeSteps = routeData.routeSteps;
        isRouteVisible = true;
        showRouteSteps = true;
      });

      // Kiểm tra nếu routeSteps rỗng
      if (routeSteps.isEmpty) {
        _showErrorDialog("Không có hướng dẫn từng bước. Vui lòng kiểm tra API hoặc dữ liệu trả về.");
      }
    } catch (e) {
      _showErrorDialog("Lỗi khi tính toán đường đi: $e");
    }
  }

  void _showRoute(ThuaDat thuaDat) async {
    if (thuaDat.vido == null || thuaDat.kinhdo == null) {
      _showErrorDialog("Không có tọa độ để chỉ đường!");
      return;
    }

    // Đóng hộp thoại thông tin ngay lập tức
    Navigator.pop(context);

    setState(() {
      _isLoading = true;
      isRouteVisible = false;
      routePoints = [];
      routeSteps = [];
      showRouteSteps = false;
    });

    try {
      await Future.delayed(Duration(seconds: 3));
      await _determinePosition();
      if (!mounted) return;

      LatLng destination = LatLng(thuaDat.vido!, thuaDat.kinhdo!);
      await _calculateRoute(currentLocation, destination);
      if (!mounted) return;

      // Điều chỉnh bản đồ để hiển thị toàn bộ đường đi
      if (_isMapReady && routePoints.isNotEmpty) {
        LatLngBounds bounds = LatLngBounds.fromPoints(routePoints);
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.all(50), // Khoảng cách đệm tương tự như trước
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Lỗi khi tính toán đường đi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearRoute() {
    setState(() {
      isRouteVisible = false;
      routePoints = [];
      routeSteps = [];
      showRouteSteps = false;
    });
  }

  void _toggleRouteSteps() {
    setState(() {
      showRouteSteps = !showRouteSteps;
    });
  }

  void _showRoutePreview(ThuaDat thuaDat) {
    if (thuaDat.vido == null || thuaDat.kinhdo == null) {
      _showErrorDialog("Không có tọa độ để chỉ đường!");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Chỉ đường đến thửa đất",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            thuaDat.diaChiThuaDat,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Thông tin giả lập (có thể thay bằng dữ liệu thực từ API)
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          "Khoảng cách: 5.2 km | Thời gian: 15 phút",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tùy chọn chế độ di chuyển
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTravelModeButton(Icons.directions_car, "Lái xe", TravelMode.driving),
                        _buildTravelModeButton(Icons.directions_walk, "Đi bộ", TravelMode.walking),
                        _buildTravelModeButton(Icons.directions_bike, "Đạp xe", TravelMode.bicycling),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Đóng lớp trung gian
                        _showRoute(thuaDat); // Vào chế độ chỉ đường
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Center(
                        child: Text(
                          "Bắt đầu chỉ đường",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showErrorDialog("Không có số điện thoại để gọi!");
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorDialog("Không thể mở ứng dụng gọi điện!");
    }
  }

// Hàm tạo nút chọn chế độ di chuyển
  Widget _buildTravelModeButton(IconData icon, String label, TravelMode mode) {
    return GestureDetector(
      onTap: () {
        _changeTravelMode(mode);
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: _travelMode == mode ? Colors.blueAccent : Colors.grey,
            size: 30,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _travelMode == mode ? Colors.blueAccent : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }





  void _showThuaDatInfo(ThuaDat thuaDat) {
    final List<String> imageUrls = [
      'https://media.vov.vn/sites/default/files/styles/large_watermark/public/2022-07/bt3_1.jpg',
      'https://th.bing.com/th/id/OIP.oqWtCgSdT0TrNqbrVns7gAHaFj?w=1024&h=768&rs=1&pid=ImgDetMain',
      'https://3.bp.blogspot.com/-CZSipmx4ezQ/XDdimc72r7I/AAAAAAAAItI/tFrAisNmM6Q5bka-HTSfmmhvSY0NhhoYgCKgBGAs/s1600/20170928_123013.jpg',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Thông tin thửa đất",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Địa chỉ",
                      value: thuaDat.diaChiThuaDat,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.square_foot,
                      label: "Diện tích",
                      value: null == thuaDat.dienTich
                          ? "Không có thông tin"
                          : "${thuaDat.dienTich} m²",
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.landscape,
                      label: "Loại đất",
                      value: thuaDat.loaiDat,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.description,
                      label: "Mục đích sử dụng",
                      value: thuaDat.mucDichSuDung,
                    ),
                    const Divider(height: 24),
                    if (thuaDat.hoTen != null)
                      _buildInfoRow(
                        icon: Icons.person,
                        label: "Chủ sở hữu",
                        value: thuaDat.hoTen ?? "Không có thông tin",
                      ),
                    const Divider(height: 24),
                    if (thuaDat.soDienThoai != null)
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: "Số điện thoại",
                        value: thuaDat.soDienThoai ?? "Không có thông tin",
                      ),
                    if (thuaDat.kinhdo != null && thuaDat.vido != null)
                      Column(
                        children: [
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.map,
                            label: "Tọa độ",
                            value: "(${thuaDat.vido}, ${thuaDat.kinhdo})",
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildActionButton(Icons.directions, "Đường đi", () {
                            _showRoutePreview(thuaDat);
                          }),
                          _buildActionButton(Icons.play_arrow, "Bắt đầu", () {
                            _showRoute(thuaDat);
                          }),
                          _buildActionButton(Icons.call, "Gọi", () {
                            _makePhoneCall(thuaDat.soDienThoai);
                          }),
                          _buildActionButton(Icons.bookmark, "Lưu", () {}),
                          _buildActionButton(Icons.share, "Chia sẻ", () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrls[index],
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 32, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blueAccent,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm xác định biểu tượng dựa trên hướng dẫn
  IconData _getDirectionIcon(String instruction) {
    instruction = instruction.toLowerCase();
    if (instruction.contains('turn left') || instruction.contains('rẽ trái')) {
      return Icons.turn_left;
    } else if (instruction.contains('turn right') || instruction.contains('rẽ phải')) {
      return Icons.turn_right;
    } else if (instruction.contains('continue') || instruction.contains('đi thẳng')) {
      return Icons.straight;
    } else if (instruction.contains('destination') || instruction.contains('đích đến')) {
      return Icons.flag;
    } else {
      return Icons.directions; // Biểu tượng mặc định
    }
  }

  // Widget hiển thị chỉ dẫn từng bước giống Google Maps
  Widget _buildRouteSteps() {
    return Positioned(
      top: 80, // Đặt ở phía trên bản đồ
      left: 10,
      right: 10,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 150, // Chiều cao cố định cho panel
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Tiêu đề và nút đóng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hướng dẫn từng bước",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _toggleRouteSteps,
                      icon: Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              // Danh sách các bước
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Cuộn ngang
                  itemCount: routeSteps.length,
                  itemBuilder: (context, index) {
                    final step = routeSteps[index];
                    return Container(
                      width: 200, // Chiều rộng cố định cho mỗi bước
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Biểu tượng hướng dẫn
                          Icon(
                            _getDirectionIcon(step['instruction']),
                            color: Colors.blue,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          // Thông tin hướng dẫn
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  step['instruction'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${step['distance']} - ${step['duration']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Đặt _isMapReady = true khi FlutterMap được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMapReady) {
        setState(() {
          _isMapReady = true;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Bản đồ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 18.0,
              minZoom: 2.0,
              maxZoom: 24.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _mapMode == MapMode.satellite
                    ? 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                    : _mapMode == MapMode.hybrid
                    ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.qlyhoso',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 40,
                    height: 40,
                    child: AnimatedOpacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ),
                  ..._buildThuaDatMarkers(),
                ],
              ),
              if (isRouteVisible && routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5), // Nền mờ
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeWidth: 6, // Tăng độ dày của vòng tròn
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Đang tải...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: screenHeight * 0.02,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            child: isRouteVisible && showRouteSteps && routeSteps.isNotEmpty
                ? _buildRouteSteps()
                : SearchBarWidget(
              controller: _searchController,
              onSearch: _onSearchChanged,
            ),
          ),
          // Column bên trái
          Positioned(
            bottom: screenHeight * 0.02,
            left: screenWidth * 0.03,
            child: FadeTransition(
              opacity: _buttonFadeAnimation,
              child: SlideTransition(
                position: _buttonSlideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRouteVisible)
                        Tooltip(
                          message: "Xóa đường đi",
                          child: FloatingActionButton(
                            heroTag: "clearRoute",
                            onPressed: _clearRoute,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.clear, color: Colors.red),
                          ),
                        ),
                      if (isRouteVisible) SizedBox(height: screenHeight * 0.015),
                      if (isRouteVisible)
                        Tooltip(
                          message: "Hiển thị/Ẩn hướng dẫn",
                          child: FloatingActionButton(
                            heroTag: "toggleSteps",
                            onPressed: _toggleRouteSteps,
                            backgroundColor: Colors.white,
                            child: Icon(showRouteSteps ? Icons.visibility_off : Icons.visibility, color: Colors.blueAccent),
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.015),
                      // Tooltip(
                      //   message: "Chuyển chế độ di chuyển",
                      //   child: FloatingActionButton(
                      //     heroTag: "travelMode",
                      //     onPressed: () {
                      //       showModalBottomSheet(
                      //         context: context,
                      //         builder: (context) => SizedBox(
                      //           height: 200,
                      //           child: Column(
                      //             children: [
                      //               ListTile(
                      //                 leading: Icon(Icons.directions_car),
                      //                 title: Text("Lái xe"),
                      //                 onTap: () {
                      //                   _changeTravelMode(TravelMode.driving);
                      //                   Navigator.pop(context);
                      //                 },
                      //               ),
                      //               ListTile(
                      //                 leading: Icon(Icons.directions_walk),
                      //                 title: Text("Đi bộ"),
                      //                 onTap: () {
                      //                   _changeTravelMode(TravelMode.walking);
                      //                   Navigator.pop(context);
                      //                 },
                      //               ),
                      //               ListTile(
                      //                 leading: Icon(Icons.directions_bike),
                      //                 title: Text("Đạp xe"),
                      //                 onTap: () {
                      //                   _changeTravelMode(TravelMode.bicycling);
                      //                   Navigator.pop(context);
                      //                 },
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //     backgroundColor: Colors.white,
                      //     child: Icon(
                      //       _travelMode == TravelMode.driving
                      //           ? Icons.directions_car
                      //           : _travelMode == TravelMode.walking
                      //           ? Icons.directions_walk
                      //           : Icons.directions_bike,
                      //       color: Colors.blueAccent,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Column bên phải
          Positioned(
            bottom: screenHeight * 0.001,
            right: screenWidth * 0.03,
            child: FadeTransition(
              opacity: _buttonFadeAnimation,
              child: SlideTransition(
                position: _buttonSlideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.002),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRouteVisible) SizedBox(height: screenHeight * 0.015),
                      Tooltip(
                        message: "Chuyển chế độ bản đồ",
                        child: FloatingActionButton(
                          heroTag: "mapMode",
                          onPressed: _toggleMapMode,
                          backgroundColor: Colors.white,
                          child: Icon(
                            _mapMode == MapMode.normal
                                ? Icons.map
                                : _mapMode == MapMode.satellite
                                ? Icons.satellite
                                : Icons.layers,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Tooltip(
                        message: "Phóng to",
                        child: FloatingActionButton(
                          heroTag: "zoomIn",
                          onPressed: () => _performZoom(1.0),
                          backgroundColor: Colors.white,
                          child: Icon(Icons.zoom_in, color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Tooltip(
                        message: "Thu nhỏ",
                        child: FloatingActionButton(
                          heroTag: "zoomOut",
                          onPressed: () => _performZoom(-1.0),
                          backgroundColor: Colors.white,
                          child: Icon(Icons.zoom_out, color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Tooltip(
                        message: "Vị trí hiện tại",
                        child: FloatingActionButton(
                          heroTag: "currentLocation",
                          onPressed: _determinePosition,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.my_location, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}