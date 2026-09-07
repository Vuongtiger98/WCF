# Open issues

1. Route đầu tiên là ending Atlantis, nhưng map Atlantis chưa dựng.
2. Map019 đã đủ 16 tổ hợp món quà/người nhận chưa?
3. Event nào ở Map013 tương ứng hỏi Leo, hỏi Shylvie, tiệc và group chat?
4. Các map generic được bỏ qua trong giai đoạn hiện tại.

## Route siêu thị

- Vertical slice Máy pha cà phê → Kohi cần playtest trong VX Ace: Pop Message, Group Chat bắt buộc chọn, layer Map037/038, Gallery ID 11, hint và đổi nền Title.
- Menu điện thoại chưa lưu trạng thái “đã đọc tin nhắn Momo”, nên epilogue đang dùng đúng nhánh mặc định không đọc. Cần thêm flag riêng trước khi triển khai biến thể còn lại.
- Hai bản DOCX có sai khác “Wanderer/siêu thị” và đại từ “ông/bà” của Kohi. Flow dùng siêu thị và Kohi là “bà” theo ngữ cảnh; giữ note để biên kịch duyệt.
- Mười lăm tổ hợp quà/người nhận còn lại mới có asset placeholder và Gallery ID, chưa có cutscene/ending.

Đã biết: Galv Cam Slide Control bị comment toàn bộ nên không tính active conflict; Switch 3, Variable 4, Variable 20 đang dùng trùng ý nghĩa; Fixed Pictures dùng Switch 98 cho hai mục đích; Catto dùng `RESULT_VARIABLE_ID = 0`; exporter mode 1/runtime mode 0; event còn tên `EVxxx`.

Camera, message, picture/layer/parallax, movement và KUL/Victor/MOG graphics cần playtest; chưa tự sửa vì chưa có bằng chứng chọn implementation nào.

## Bug transfer Map003 → Map017 → Map006

Map003 và Map017 đều chuyển cuối về Map006 `(94,11)`. Map017 E002 đã được sửa: bỏ route 16 bước gây lệch/treo, thay bằng route 3 bước lên có `wait=true` trước transfer. Vẫn cần playtest hai nhánh để xác nhận vị trí thực tế.
