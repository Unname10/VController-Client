# Cơ chế hoạt động
1. Cơ chế giao tiếp cốt lõi: Giao thức UDP
Hệ thống hoạt động dựa trên mô hình Client-Server trong mạng LAN (mạng nội bộ chung một cục phát Wifi), sử dụng giao thức UDP (User Datagram Protocol).

Tại sao lại là UDP? Khác với giao thức TCP (dùng để lướt web, tải file) đòi hỏi phải "bắt tay" (handshake) và kiểm tra xem gói tin có đến nơi an toàn hay không, UDP có tính chất "bắn và quên" (fire-and-forget). Nó đẩy dữ liệu đi với tốc độ cao nhất có thể. Trong game, nếu mất 1 gói tin tọa độ của Joystick, gói tin tiếp theo (vài mili-giây sau) sẽ bù đắp ngay lập tức, do đó độ trễ (latency) được giảm xuống mức tối thiểu (có thể dưới 5ms).

2. Cấu trúc dữ liệu (Data Payload)
Bí quyết để UDP chạy nhanh là gói tin phải cực kỳ nhỏ gọn. Mỗi lần gửi, điện thoại chỉ bắn qua máy tính một dải byte có độ dài đúng 6 Bytes (định dạng >Hbbbb).

Cấu trúc 6 Bytes này được phân bổ như sau:

Byte 1 & Byte 2 (>H - Unsigned Short 16-bit): Dành cho Nút bấm

Thay vì gửi chuỗi văn bản như "A_is_pressed", hệ thống dùng kỹ thuật Bitmask (mặt nạ bit).

16 bit tương đương với khả năng biểu diễn trạng thái (Bật/Tắt) của tối đa 16 nút bấm cùng lúc.

Ví dụ: Nút A là bit 1 (giá trị 1), nút B là bit 2 (giá trị 2), nút X là bit 3 (giá trị 4)... Nếu bạn bấm cùng lúc A và X, giá trị thập phân truyền đi sẽ là 1 + 4 = 5 (00000000 00000101).

Byte 3 (b - Signed Char 8-bit): Joystick Trái - Trục X

Lưu độ lệch ngang của cần gạt di chuyển. Giá trị dao động từ -127 (kéo kịch sang trái) đến 127 (kéo kịch sang phải). Ở giữa là 0.

Byte 4 (b - Signed Char 8-bit): Joystick Trái - Trục Y

Lưu độ lệch dọc của cần gạt di chuyển (Lên: âm, Xuống: dương).

Byte 5 (b - Signed Char 8-bit): Joystick Phải - Trục X

Lưu độ lệch ngang của cần gạt Camera/Chuột.

Byte 6 (b - Signed Char 8-bit): Joystick Phải - Trục Y

Lưu độ lệch dọc của cần gạt Camera/Chuột.

3. Cách thức Client (Điện thoại) hoạt động
Client đóng vai trò là "Trạm thu thập và Phát tín hiệu".

Nhận diện thao tác: Thông qua các hàm nhận diện cảm ứng ở tầng thấp (như Listener trong Flutter hoặc PanResponder trong React Native), ứng dụng bắt ngay lập tức khoảnh khắc ngón tay chạm, vuốt hoặc rời khỏi màn hình.

Cập nhật trạng thái: Khi bạn chạm nút A, hệ thống dùng phép toán OR bitwise (_buttons |= mask_A) để bật bit tương ứng lên 1. Khi di chuyển ngón tay trên vùng Joystick, tọa độ được quy đổi ra thang đo từ -127 đến 127.

Đóng gói và Gửi: Mọi trạng thái này được nạp vào một bộ đệm (buffer) chuẩn xác 6 bytes. Ứng dụng sẽ có một Game Loop liên tục bắn gói tin này đi 60 lần/giây. Đồng thời, mỗi khi có sự thay đổi đột ngột về nút bấm (nhấn xuống hoặc nhả ra), nó sẽ ưu tiên bắn ngay lập tức 1 gói tin để máy tính nhận lệnh tức thời mà không phải chờ nhịp của Game Loop.

4. Cách thức Server (Máy tính) hoạt động
Server đóng vai trò là "Não bộ phiên dịch".

Lắng nghe: Một script Python mở sẵn cổng (Port 5005) và kiên nhẫn đợi dữ liệu đổ về từ mọi IP trong mạng LAN.

Giải nén (Unpack): Khi 6 bytes bay tới, thư viện struct sẽ dịch ngược chuỗi byte này thành các con số có nghĩa (1 biến trạng thái phím, 4 biến tọa độ Joystick).

So sánh trạng thái (Cơ chế chống dội phím):

Đây là bước quan trọng nhất. Server luôn ghi nhớ gói tin nó nhận được ngay trước đó (biến prev_keys).

Nó dùng phép toán AND bitwise (&) để "soi" xem nút A trong gói tin mới có đang bật không.

Logic: Nếu nút A đang báo BẬT, nhưng ở nhịp trước đó báo TẮT -> Suy ra người dùng vừa CHẠM tay. Lệnh pyautogui.keyDown('space') được gọi để ấn đè nút Space trên máy tính.

Ngược lại, nếu nút A báo TẮT, nhưng nhịp trước báo BẬT -> Suy ra người dùng vừa NHẢ tay. Lệnh pyautogui.keyUp('space') được gọi để thả nút Space ra.

Nhờ cơ chế này, hệ thống phân biệt được rõ ràng hành động "giữ phím dài" và "bấm thả nhanh".

Phiên dịch Joystick:

Với Joystick Trái (WASD): Đặt một mức ngưỡng (Threshold, ví dụ giá trị vượt quá 40 hoặc -40). Khi bạn đẩy cần lên quá ngưỡng -40, Server sẽ mô phỏng việc đè phím W.

Với Joystick Phải (Mouse): Các giá trị từ -127 đến 127 được nhân với một hệ số độ nhạy (Sensitivity) và truyền thẳng vào lệnh pyautogui.moveRel(), giúp con trỏ chuột trên Windows lướt đi mượt mà theo đúng gia tốc ngón tay của bạn.

Hệ thống cứ thế lặp lại chu trình này liên tục hàng trăm lần mỗi giây, tạo ra cảm giác điều khiển tức thời và mượt mà y hệt như một thiết bị ngoại vi chuyên dụng.