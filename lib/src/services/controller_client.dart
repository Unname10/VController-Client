import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

/// Định nghĩa các Bitmask cho nút bấm (Khớp với Server Python)
class ControllerButtons {
  static const int UP = 1; // 2^0
  static const int RIGHT = 2; // 2^1
  static const int DOWN = 4; // 2^2
  static const int LEFT = 8; // 2^3
  static const int A = 16; // 2^4
  static const int B = 32; // 2^5
  static const int X = 64; // 2^6
  static const int Y = 128; // 2^7
  static const int LT = 256; // 2^8
  static const int LB = 512; // 2^9
  static const int RB = 1024; // 2^10
  static const int RT = 2048; // 2^11
  static const int BACK = 4096; // 2^12
  static const int START = 8192; // 2^13
  static const int L3 = 16384; // 2^14
  static const int R3 = 32768; // 2^15
}

class VControllerClient {
  static final VControllerClient _instance = VControllerClient._internal();

  VControllerClient._internal();

  factory VControllerClient() {
    return _instance;
  }

  RawDatagramSocket? _socket;
  Timer? _loopTimer;
  InternetAddress? _targetAddress;
  int? serverPort;

  // --- TRẠNG THÁI HIỆN TẠI CỦA TAY CẦM ---
  int _buttons = 0; // Chứa trạng thái của tất cả các nút (13-bit/16-bit)
  double _lx = 0; // Joystick Trái X (-127 đến 127)
  double _ly = 0; // Joystick Trái Y
  double _rx = 0; // Joystick Phải X
  double _ry = 0; // Joystick Phải Y

  // VControllerClient({required this.serverIp, required this.serverPort});

  /// Khởi tạo kết nối UDP và vòng lặp Game Loop
  Future<void> connect({required String ip, required int port}) async {
    try {
      // Khởi tạo đối tượng cũng như kiểm tra tính hợp lệ của server ip
      _targetAddress = InternetAddress(ip);
      // Kiểm tra tính hợp lệ của server port
      if (port < 0 || port > 65535) {
        throw Exception("Invalid server's port number!");
      }
      serverPort = port;

      // Mở socket UDP ở bất kỳ IP khả dụng nào trên máy, port tự động (Port 0)
      _socket = await .bind(InternetAddress.anyIPv4, 0);
      // Bắt đầu vòng lặp gửi dữ liệu liên tục 30 FPS (~33ms/lần)
      // Vòng lặp này cực kỳ quan trọng để giữ chuyển động mượt mà cho Joystick
      _loopTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
        _sendPacket();
      });

      print("[*] Đã thiết lập vòng lặp gửi gói tin!");
      print('[*] Đã mở UDP Socket tại port: ${_socket?.port}');
    } catch (e) {
      print('[!] Lỗi khởi tạo UDP: $e');
    }
  }

  // Dừng gửi và đóng Socket (Nên gọi khi thoát App)
  void disconnect() {
    _loopTimer?.cancel();
    _socket?.close();
    print('[*] Đã đóng UDP Socket');
  }

  void updateServerAddress({required String ip, required int port}) {
    try {
      // Gán lại địa chỉ đối tượng cũng như kiểm tra tính hợp lệ của server ip
      _targetAddress = InternetAddress(ip);
      // Gán lại cổng và kiểm tra tính hợp lệ của server port
      if (port > 0 && port < 65535) {
        serverPort = port;
      } else {
        throw Exception("Invalid server's port number!");
      }

      print("[*] Đã thay đổi địa chỉ server sang: $ip:$port");
    } catch (e) {
      print("[!] Lỗi thay đổi địa chỉ Server: $e");
      throw Exception(e);
    }
  }

  /// Hàm cốt lõi: Đóng gói và gửi đúng 6 bytes sang Server
  void _sendPacket() {
    if (_socket == null || _targetAddress == null) return;

    // Khởi tạo bộ đệm chính xác 6 Bytes
    var data = ByteData(6);

    // Byte 0 - 1: Lưu trạng thái Nút Bấm (Unsigned Short 16-bit, Big Endian)
    data.setUint16(0, _buttons, Endian.big);

    // Byte 2 - 5: Lưu tọa độ Joystick (Signed Int 8-bit)
    // Dùng hàm clamp(-127, 127) để đảm bảo giá trị không bị tràn bộ nhớ (Overflow)
    data.setInt8(2, _lx.round().clamp(-127, 127));
    data.setInt8(3, _ly.round().clamp(-127, 127));
    data.setInt8(4, _rx.round().clamp(-127, 127));
    data.setInt8(5, _ry.round().clamp(-127, 127));

    // Bắn gói tin đi qua UDP
    _socket?.send(data.buffer.asUint8List(), _targetAddress!, serverPort!);
  }

  // =========================================================
  // CÁC HÀM API ĐỂ GIAO DIỆN (UI) TƯƠNG TÁC
  // =========================================================

  /// Cập nhật trạng thái một nút bấm (Nhấn xuống hoặc Nhả ra)
  void updateButton(int bitmask, bool isPressed) {
    if (isPressed) {
      _buttons |= bitmask; // Phép OR: Bật bit lên 1
    } else {
      _buttons &= ~bitmask; // Phép AND + NOT: Tắt bit về 0
    }

    // RẤT QUAN TRỌNG: Gửi gói tin đi ngay lập tức khi có sự kiện bấm nút
    // Điều này giúp loại bỏ hoàn toàn độ trễ (delay) của vòng lặp 16ms
    _sendPacket();
  }

  /// Cập nhật tọa độ Joystick Trái (Dùng cho Di chuyển - WASD)
  /// x, y truyền vào nên nằm trong khoảng -127 đến 127
  void updateLeftJoystick(double x, double y) {
    _lx = x;
    _ly = y;
    // Không cần ép gửi ngay vì vòng lặp 30FPS sẽ tự động lấy giá trị mới nhất này
  }

  /// Cập nhật tọa độ Joystick Phải (Dùng cho Camera / Chuột)
  void updateRightJoystick(double x, double y) {
    _rx = x;
    _ry = y;
  }
}
