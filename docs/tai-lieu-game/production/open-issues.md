# Open issues hiện tại

Tài liệu này chỉ giữ các vấn đề còn mở ở runtime hiện tại. Các câu hỏi lịch sử như “Atlantis chưa dựng”, “Map019 đã đủ 16 tổ hợp chưa” hoặc “event hỏi Leo/Shylvie là event nào” đã được giải quyết và không còn là open issue.

## Cần playtest thủ công

- Chạy toàn bộ 33 đường test được định nghĩa trong `tester-web-app-content-spec.md`, ưu tiên bắt đầu từ Map069 để kiểm tra cả state route, sprite, KUL và dữ liệu điện thoại.
- Kiểm tra timing plugin ở các chuyển cảnh KUL: màn hình phải đen trong lúc transfer nhưng luôn được reveal trước khi trả quyền điều khiển.
- Kiểm tra camera, Pop Message và balloon ở các scene có zoom/focus; static audit không chứng minh được bố cục thực tế ở mọi độ phân giải.
- Kiểm tra Map028 từ đầu mê cung tới lối ra: clone chủ động chạm player, gai chỉ an toàn khi hạ hẳn, đá lăn, thùng lửa, cửa/nút và reset sau lần choáng thứ tư.
- Kiểm tra Map038 với mọi nhóm route: vị trí NPC khi free roam, đường vào/ra các phòng, bốn trận ném tuyết, RAM nhặt/farm và cutscene Diana khi đủ 10 Item 18.
- Kiểm tra save cũ có switch/variable từ phiên bản trước; Test Hub chỉ bảo đảm state sạch cho lượt chơi mới từ checkpoint.

## Asset còn thiếu hoặc đang dùng placeholder

- Chưa có CG đúng chỉ dẫn “Hải Quỳ mỉm cười” ở route giải cứu Vực Sâu.
- Chưa có sprite/face Drosalya và một số face NPC cửa hàng; không thay bằng face nhân vật khác.
- Chưa có sprite Hakase sau khi hấp thụ ma lực hoặc ending CG riêng cho nhánh sách Ma Vương Cổ Đại.
- Một số ending Gallery siêu thị vẫn là artwork placeholder; tên và ID runtime đã ổn định nhưng hình cuối cần artist thay.
- Pose né hoàn chỉnh cho Snowball Rhythm vẫn cần spritesheet riêng; runtime hiện dùng offset/scale sprite.

## Nội dung cần người phụ trách duyệt

- Hai nguồn siêu thị còn khác nhau ở cách gọi “Wanderer/siêu thị” và đại từ của Kohi; runtime đang dùng ngữ cảnh siêu thị và gọi Kohi là “bà”.
- Quyết định có bổ sung portrait cho quái vật Vực Sâu hay tiếp tục giữ các câu thoại vô diện.
- Các map/scene chưa được gán BGM cố ý fade out về im lặng để dễ phát hiện; bổ sung nhạc theo `systems/audio-map.md`, không tự chọn bài ngoài danh sách đã duyệt.

## Nợ kỹ thuật đã biết

- Switch 3, Variable 4 và Variable 20 có lịch sử dùng chồng ý nghĩa; không cấp thêm chức năng mới vào các ID này.
- Fixed Pictures vẫn dùng Switch 98 cho nhiều mục đích cũ.
- Một số event legacy còn tên `EVxxx`; chỉ đổi tên khi đã xác định chắc chức năng và không dựng lại vị trí event do người dùng chỉnh trong RPG Maker.
- Các file kế hoạch cũ đã được gắn nhãn lịch sử. Không dùng chúng làm runtime spec nếu mâu thuẫn với `routes/README.md`, `maps/README.md` hoặc registry hệ thống.

## Đã xác nhận bằng static audit

- Ma trận siêu thị 4 món × 4 người nhận: đầy đủ preparation, party, epilogue, Test Hub và hint.
- Tất cả cảnh chuẩn bị quà đang hội tụ ở Map037; Map047/049/051/060/065 không còn incoming transfer.
- Map024 dùng parallax `falling_base`, 16 layer, vị trí player `(8,6)` và lối ra `(8,13)`.
- Map028 không dùng trigger hù cũ; cơ chế clone, choáng/reset, gai, đá lăn, cửa/nút và ánh sáng đều có runtime handler.
- Kế hoạch BGM hiện có entry cho 64 map và Title dùng `mainmenu`.

Static audit không thay cho playtest trong VX Ace.
