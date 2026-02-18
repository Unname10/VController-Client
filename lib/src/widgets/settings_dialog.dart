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
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 5.0,
          vertical: 5.0,
        ),

        content: SizedBox(
          width: 500, // Độ rộng mong muốn (đủ để chứa cả Text và Nút)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên cùng
            children: [
              // --- CỘT TRÁI: Ô NHẬP LIỆU (Chiếm hết phần trống) ---
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: targetController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ Server',
                        prefixIcon: Icon(Icons.computer, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15), // Khoảng hở giữa 2 cột
              // --- HÀNG RÀO NGĂN CÁCH (Tùy chọn cho đẹp) ---
              Container(width: 1, height: 60, color: Colors.white24),
              const SizedBox(width: 15),

              // --- CỘT PHẢI: CÁC NÚT BẤM (Xếp dọc) ---
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa chiều dọc
                children: [
                  // 1. Nút Lưu (To, nổi bật)
                  ElevatedButton(
                    onPressed: () {
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

                      Navigator.pop(context); // Xử lý xong thì đóng Dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      // Dùng cột nhỏ để icon nằm trên chữ
                      children: [
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          "Lưu",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // QUAN TRỌNG: Để trống phần actions vì nút đã chuyển vào content rồi
        actions: [],

        // Các nút hành động ở dưới cùng
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       Navigator.of(
        //         context,
        //       ).pop(); // Bấm Hủy -> Đóng Dialog, không làm gì cả
        //     },
        //     child: const Text('Hủy', style: TextStyle(color: Colors.red)),
        //   ),
        //   ElevatedButton(
        //     onPressed: () {
        //       // Lấy dữ liệu người dùng vừa nhập
        //       List<String> newTarget = targetController.text.split(":");
        //       String newIp = newTarget[0];
        //       int newPort = int.parse(newTarget[1]);

        //       try {
        //         VControllerClient().updateServerAddress(
        //           ip: newIp,
        //           port: newPort,
        //         );
        //         _saveSetting(targetController.text);
        //         if (context.mounted) {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(
        //               content: Text(
        //                 'Đã lưu & kết nối tới ${targetController.text}',
        //               ),
        //             ),
        //           );
        //         }
        //       } catch (e) {
        //         throw Exception(e);
        //       }

        //       Navigator.of(context).pop(); // Xử lý xong thì đóng Dialog
        //     },
        //     style: ButtonStyle(),
        //     child: const Text('Lưu & Kết nối'),
        //   ),
        // ],
      );
    },
  );
}
