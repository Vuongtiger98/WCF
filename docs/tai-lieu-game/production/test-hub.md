# Map069 — Route Checkpoint Hub

Map069 là map playtest-only `44×32` với 41 event. Không có production transfer dẫn tới đây. Tester vào hub từ New Game/Test Play để rút ngắn thời gian chạy lại route.

## Quy tắc bảo toàn dữ liệu

- Vị trí, graphic, walk animation và step animation của event do người dùng chỉnh trong RPG Maker là dữ liệu có thẩm quyền. Không dựng lại toàn bộ Map069 hoặc bật/tắt animation hàng loạt.
- Khi chỉ sửa choice/page, giữ nguyên tọa độ và các thuộc tính graphic hiện có.
- Mọi nhóm lựa chọn nhánh phải có `Hủy`; hủy không thay switch, variable, điện thoại hoặc teleport.
- Không dùng F8 hoặc phím tắt quay lại hub. Tester có thể về Title và chọn chơi mới.

## Trạng thái checkpoint phải khôi phục

Mỗi checkpoint chịu trách nhiệm cho toàn bộ state cần thiết, không chỉ destination map:

- switch/variable route;
- Self Switch của các map route;
- sprite player, transparency, through, speed và frequency;
- KUL, player/event light, Map Effects, layer và screen fade;
- timeline ngày/giờ của điện thoại;
- Contacts, Group Chat, lựa chọn đã ghi và tin nhắn đã có tới checkpoint;
- đúng page autorun/free roam của map đích.

Trước khi áp checkpoint, runtime reset Switch 30–81 cùng các switch dùng chung của route, Variable 30–58 và 80–84, Self Switch của các map route, light/effects/layers và dữ liệu chat tạm. Sau khi seed điện thoại, state route được áp lại lần cuối để preset chat không ghi đè lựa chọn nhánh.

## Nhóm checkpoint hiện có

- Mở đầu: Silverwing, thành phố, bus, Wanderer Office.
- Atlantis nhà/kho: nhà Hải Quỳ, tiệm sách, kho tối, kho sáng, ký ức, mê cung, vòng vây, chase và hậu chase.
- Siêu thị: vào siêu thị, chuẩn bị quà và tiệc; choice chọn món/người nhận phải hỗ trợ đủ ma trận.
- Mì cay: tiệm mì, chuẩn bị, bếp và tiệc; choice giữ hai nhánh Aira/Hải Quỳ.
- Sách: preparation/party/ending cho Shylvie và Hakase.
- Chủ tiệm/Vực Sâu: checkpoint bắt đầu route owner-first.
- Hỏi Leo: bus, ba cửa hàng, preparation và party; choice giữ đủ ba nhánh.
- Hỏi Shylvie: tiệm đá, preparation, party và ending; choice giữ đủ bốn loại đá/người nhận.
- Các event bữa tiệc/hậu truyện phải cho chọn biến thể trước khi teleport, không mặc định một trường hợp.
- Một event riêng cho phép nghe thử danh sách BGM đã duyệt và dừng nhạc.
- **E043 — Thử biến hình**, tại `(6,7)`, sprite `!$HaiQuyRiu`. Riu có sẵn. Menu gồm **Thử biến hình**, **Mở từng thẻ** (Gamemerr/Sanic/Diana), **Thiết lập nhanh** (mở cả bốn hoặc chỉ giữ Riu), **Hủy**. Thử dùng đúng các thẻ đã mở, không tự mở tất cả. Reset chỉ khóa ba phép trong lượt hiện tại và khôi phục dạng gốc, giữ bộ sưu tập/quest/điện thoại. X trong màn hình chọn form trả về dạng gốc qua 127. Mọi menu tối đa bốn lựa chọn, có Hủy bằng X. Vị trí, sprite và thiết lập event được giữ; 40 event khác không thay đổi.

## Kiểm tra sau khi thêm checkpoint

1. Bắt đầu New Game vào Map069.
2. Chọn từng nhánh rồi Hủy: player phải ở nguyên hub, state không đổi.
3. Chọn từng checkpoint: map đích không được đen vĩnh viễn, player có đúng sprite và có thể di chuyển khi tới free roam.
4. Mở điện thoại: timeline, Contacts và tin nhắn phải tương ứng checkpoint.
5. Thử vào/ra phòng phụ rồi quay lại map chính để phát hiện duplicate NPC hoặc state staging sai.
6. Không dùng công cụ dựng lại map sau khi người dùng đã di chuyển/clone event trong editor.
