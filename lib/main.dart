import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vcontroller/src/services/controller_client.dart';

import 'package:vcontroller/src/layouts/widgets.dart';

const String serverIp = "192.168.1.179";
const int serverPort = 5005;

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
    return MaterialApp(
      // Scaffold cung cấp cấu trúc màn hình cơ bản (nền trắng, app bar, v.v.)
      home: Scaffold(
        // Đưa Container của bạn vào thuộc tính body
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              LeftPanel(client: client),
              CenterPanel(client: client),
              RightPanel(client: client),
            ],
          ),
        ),
      ),
    );
  }
}
