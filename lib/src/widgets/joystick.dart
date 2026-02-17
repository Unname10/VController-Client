import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final Function(double x, double y) onJoystickChanged;
  const VirtualJoystick({super.key, required this.onJoystickChanged});

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  final double baseSize = 150;
  final double stickSize = 60.0;

  // 1. VŨ KHÍ BÍ MẬT: ValueNotifier
  // Gói tọa độ vào một hộp chứa có khả năng tự phát tín hiệu khi thay đổi
  final ValueNotifier<Offset> _stickOffset = ValueNotifier(Offset.zero);
  Offset? _touchStartLocalPosition;
  Offset _stickOffsetAtStart = Offset.zero;

  // 1. KHI VỪA CHẠM NGÓN TAY VÀO (Không gửi tín hiệu chạy ngay)
  void _onPanStart(DragStartDetails details) {
    // Lưu lại "tọa độ gốc" của ngón tay
    _touchStartLocalPosition = details.localPosition;
    // Lưu lại vị trí hiện tại của cục Stick (thường là 0,0 nếu nó đang ở giữa)
    _stickOffsetAtStart = _stickOffset.value;
  }

  // 2. KHI BẮT ĐẦU RÊ NGÓN TAY
  void _onPanUpdate(DragUpdateDetails details) {
    if (_touchStartLocalPosition == null) return;

    // Tính toán quãng đường ngón tay đã rê đi so với lúc vừa chạm
    Offset dragDelta = details.localPosition - _touchStartLocalPosition!;

    // Vị trí mới của Stick = Vị trí lúc bắt đầu chạm + Quãng đường rê
    Offset newStickPosition = _stickOffsetAtStart + dragDelta;

    // Ràng buộc toán học: Vẫn không cho phép Stick bay ra khỏi vòng Base
    double distance = newStickPosition.distance;
    double maxRadius = (baseSize - stickSize) / 2;

    if (distance > maxRadius) {
      double ratio = maxRadius / distance;
      newStickPosition = Offset(
        newStickPosition.dx * ratio,
        newStickPosition.dy * ratio,
      );
    }

    // Cập nhật UI thật mượt
    _stickOffset.value = newStickPosition;

    // Bắn tín hiệu chuẩn xác ra ngoài cho VController
    widget.onJoystickChanged(
      newStickPosition.dx / maxRadius,
      (newStickPosition.dy / maxRadius) * -1,
    );
  }

  // 3. KHI NHẤC NGÓN TAY LÊN
  void _onPanEnd(DragEndDetails details) {
    // Xóa điểm neo
    _touchStartLocalPosition = null;

    // Đưa Stick về tâm
    _stickOffset.value = Offset.zero;
    widget.onJoystickChanged(0.0, 0.0);
  }

  @override
  void dispose() {
    // 3. QUAN TRỌNG: Phải hủy ValueNotifier khi đóng màn hình để chống tràn RAM
    _stickOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LỚP NỀN: Phần này giờ đây hoàn toàn tĩnh, framework vẽ 1 lần rồi bỏ qua luôn
          Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: .all(color: Colors.white),
            ),
          ),

          // LỚP STICK: Chỉ duy nhất Widget này được phép lắng nghe và vẽ lại
          ValueListenableBuilder<Offset>(
            valueListenable: _stickOffset,
            builder: (context, currentOffset, child) {
              return Transform.translate(
                offset: currentOffset,
                child: child, // Sử dụng lại child tĩnh để tối đa hóa hiệu năng
              );
            },

            // Cục Stick giao diện được tách ra tĩnh, chỉ bị Transform dời đi chứ không phải vẽ lại màu sắc/đổ bóng
            child: Container(
              width: stickSize,
              height: stickSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
