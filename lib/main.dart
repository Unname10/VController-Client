import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vcontroller/src/services/controller_client.dart';

import 'package:vcontroller/src/layouts/widgets.dart';
import 'package:vcontroller/src/widgets/fn_button.dart';

const String serverIp = "192.168.1.179";
const int serverPort = 5005;

// Thông số tùy chỉnh
const double minHeight = 350;
const double minWidth = 800;
const double paddingVertical = 10;
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
  late final VControllerClient client;

  @override
  void initState() {
    super.initState();

    // Khởi tạo Socket và kết nối với Server
    client = VControllerClient(serverIp: serverIp, serverPort: serverPort);
    client.connect();

    // Khởi tạo đối tượng lắng nghe sự kiện ẩn/hiện app
    // Để đóng/kết nối lại với server (Tiết kiệm pin và giảm nghẽn băng thông)
    _lifecycleListener = AppLifecycleListener(
      onPause: () {
        print("App vừa bị ẩn, đang đóng socket...");
        client.disconnect();
      },
      onResume: () {
        print("App vừa trở lại, mở lại socket...");
        client.connect();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    client.disconnect();
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
      home: Scaffold(
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
                  child: SizedBox(
                    height: minHeight,
                    child: LeftPanel(client: client),
                  ),
                ),
                Align(
                  alignment: .topCenter,
                  child: CenterPanel(client: client),
                ),
                Align(
                  alignment: .bottomRight,
                  child: SizedBox(
                    height: minHeight,
                    child: RightPanel(client: client),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
