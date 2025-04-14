import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qlyhoso/data/models/lichhop_Model.dart';

class LichHopCard extends StatelessWidget {
  final LichHop lichHop;
  final VoidCallback onTap;

  const LichHopCard({
    super.key,
    required this.lichHop,
    required this.onTap,
  });

  // Xác định trạng thái cuộc họp
  String _getMeetingStatus(DateTime meetingTime) {
    final now = DateTime.now();
    final difference = meetingTime.difference(now);
    if (difference.inMinutes < 0) {
      return "Đã diễn ra";
    } else if (difference.inMinutes <= 30) {
      return "Đang diễn ra";
    } else {
      return "Sắp diễn ra";
    }
  }

  // Màu sắc dựa trên trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case "Đã diễn ra":
        return Colors.grey;
      case "Đang diễn ra":
        return Colors.green;
      case "Sắp diễn ra":
        return Colors.blue;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingStatus = _getMeetingStatus(lichHop.thoiGianHop);
    final statusColor = _getStatusColor(meetingStatus);

    return AnimatedCard(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor.withOpacity(0.2)), // Viền mỏng dựa trên trạng thái
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(
              meetingStatus == "Đã diễn ra"
                  ? Icons.event_busy
                  : meetingStatus == "Đang diễn ra"
                  ? Icons.event_available
                  : Icons.event,
              color: statusColor,
              size: 28,
            ),
          ),
          title: Text(
            lichHop.tenCuocHop ?? "Không có tiêu đề",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(lichHop.thoiGianHop),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lichHop.diaDiemHop ?? "Chưa xác định",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    meetingStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: statusColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Custom Animated Card for interaction
class AnimatedCard extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const AnimatedCard({required this.onTap, required this.child});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}