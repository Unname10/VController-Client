import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/joystick.dart';

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

  VControllerClient client = VControllerClient(
    serverIp: serverIp,
    serverPort: serverPort,
  );
  await client.connect();

  runApp(Controller(client: client));
}

class Controller extends StatefulWidget {
  final VControllerClient client;
  const Controller({super.key, required this.client});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onPause: () {
        print("App vừa bị ẩn, đang đóng socket...");
        widget.client.disconnect();
      },
      onResume: () {
        print("App vừa trở lại, mở lại socket...");
        widget.client.connect();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    widget.client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Scaffold cung cấp cấu trúc màn hình cơ bản (nền trắng, app bar, v.v.)
      home: Scaffold(
        appBar: AppBar(
          title: Text("VController"),
          backgroundColor: Colors.lightBlue,
        ),
        // Đưa Container của bạn vào thuộc tính body
        body: Column(
          mainAxisAlignment: .center,
          children: [
            Row(
              mainAxisAlignment: .center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(150),
                  child: VirtualJoystick(
                    onJoystickChanged: (double x, double y) {
                      widget.client.updateLeftJoystick(x, y);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(150),
                  child: VirtualJoystick(
                    onJoystickChanged: (double x, double y) {
                      print("X: $x, Y: $y");
                      widget.client.updateRightJoystick(x, y);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
