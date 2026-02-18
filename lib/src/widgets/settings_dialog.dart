import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcontroller/src/services/controller_client.dart';

Future<void> _saveSetting(String target) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('target_server', target);
}

void showSettingsDialog(
  BuildContext context,
  TextEditingController targetController,
) {
  showDialog(
    context: context,
    // Thuộc tính này giúp người dùng không thể bấm ra ngoài để đóng hộp thoại (Bắt buộc phải bấm Hủy hoặc Lưu)
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor:
            Colors.grey[900], // Màu nền tối cho hợp phong cách Gamepad
        title: const Text(
          'Cài đặt Máy chủ',
          style: TextStyle(color: Colors.white),
        ),

        // Nội dung chính: Cột chứa 2 ô nhập liệu
        content: Column(
          mainAxisSize:
              MainAxisSize.min, // Quan trọng: Ép Column co lại cho vừa nội dung
          children: [
            TextField(
              controller: targetController,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: '[Server Ip]:[Port]',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),

        // Các nút hành động ở dưới cùng
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(); // Bấm Hủy -> Đóng Dialog, không làm gì cả
            },
            child: const Text('Hủy', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              // Lấy dữ liệu người dùng vừa nhập
              List<String> newTarget = targetController.text.split(":");
              String newIp = newTarget[0];
              int newPort = int.parse(newTarget[1]);

              try {
                VControllerClient().updateServerAddress(
                  ip: newIp,
                  port: newPort,
                );
                _saveSetting(targetController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã lưu & kết nối tới ${targetController.text}',
                      ),
                    ),
                  );
                }
              } catch (e) {
                throw Exception(e);
              }

              Navigator.of(context).pop(); // Xử lý xong thì đóng Dialog
            },
            child: const Text('Lưu & Kết nối'),
          ),
        ],
      );
    },
  );
}
