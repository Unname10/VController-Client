import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vcontroller/src/services/controller_client.dart';

import 'package:vcontroller/src/layouts/widgets.dart';
import 'package:vcontroller/src/widgets/settings_dialog.dart';

// Thông số tùy chỉnh
const double minHeight = 350;
const double minWidth = 800;
const double paddingVertical = 12;
const double paddingHorizontal = 20;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ép màn hình xoay ngang
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Ẩn thanh trạng thái
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(Controller());
}

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  late final AppLifecycleListener _lifecycleListener;
  final TextEditingController _targetController = TextEditingController();

  Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String savedTarget = prefs.getString('target_server') ?? '192.168.1.2:5005';

    setState(() {
      _targetController.text = savedTarget;
      print("[*] Đã cập nhật địa chỉ server sang địa chỉ đã lưu!");
    });
  }

  Future<void> initialize() async {
    // Nạp cấu hình
    await loadSavedSettings();

    // Khởi tạo Socket và kết nối với Server
    await VControllerClient().connect(
      ip: _targetController.text.split(":")[0],
      port: int.parse(_targetController.text.split(":")[1]),
    );

    // Khởi tạo đối tượng lắng nghe sự kiện ẩn/hiện app
    // Để đóng/kết nối lại với server (Tiết kiệm pin và giảm nghẽn băng thông)
    _lifecycleListener = AppLifecycleListener(
      onPause: () {
        print("App vừa bị ẩn, đang đóng socket...");
        VControllerClient().disconnect();
      },
      onResume: () async {
        print("App vừa trở lại, mở lại socket...");
        final prefs = await SharedPreferences.getInstance();
        String savedTarget =
            prefs.getString('target_server') ?? '192.168.1.2:5005';
        VControllerClient().connect(
          ip: savedTarget.split(":")[0],
          port: int.parse(savedTarget.split(":")[1]),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    initialize();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _targetController.dispose();
    VControllerClient().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra tính hợp lệ của các padding (không hợp lệ = bỏ)
    final double computedPaddingVertical =
        MediaQuery.of(context).size.height - 2 * paddingVertical - minHeight > 0
        ? paddingVertical
        : 0;
    final double computedPaddingHorizontal =
        MediaQuery.of(context).size.width - 2 * paddingHorizontal - minWidth > 0
        ? paddingVertical
        : 0;

    return MaterialApp(
      // Scaffold cung cấp cấu trúc màn hình cơ bản (nền trắng, app bar, v.v.)
      home: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: Padding(
              padding: .only(
                right: computedPaddingHorizontal,
                left: computedPaddingHorizontal,
                top: computedPaddingVertical,
                bottom: computedPaddingVertical,
              ),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    Align(
                      alignment: .bottomLeft,
                      child: SizedBox(height: minHeight, child: LeftPanel()),
                    ),
                    Align(alignment: .topCenter, child: CenterPanel()),
                    Align(
                      alignment: .bottomRight,
                      child: SizedBox(height: minHeight, child: RightPanel()),
                    ),
                    Align(
                      alignment: .topCenter,
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          showSettingsDialog(context, _targetController);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
