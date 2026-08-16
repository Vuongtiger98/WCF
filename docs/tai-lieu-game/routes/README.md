# Route implementation

`04-route-map.md` là cây route; thư mục này là lớp chuyển route thành map/event.

| Route | Map liên quan | Hiện trạng |
|---|---|---|
| Siêu thị: 4 món × 4 người nhận | Map006, Map019 | Map019 có 43 event; chưa chứng minh đủ 16 nhánh |
| Mì cay: tin/không tin Aira | Map010, Map014 | Có bus/bếp; chưa có registry flag |
| Hỏi Leo | Map013 | Có 88 event; chưa gắn scene ID |
| Hỏi Shylvie | Map013 | Có không gian; cần xác định event thoại |
| Atlantis | Map010 → Map021 → Map022/026 → Map023 hoặc Map024 | Nhà/kho và hai nhánh đầu đã dựng; shop/chase còn thiếu map art và gameplay |

Route đầu tiên đã được chốt là ending Atlantis. Tuy nhiên map Atlantis chưa dựng; trước khi dựng route sẽ kiểm kê tuần tự các map hiện hữu, bắt đầu từ Map003 Văn phòng Silver Wing. Map generic được bỏ qua.

Map019 được giữ làm map test siêu thị, không thuộc route Atlantis. Flow hiện tại bắt đầu Map010 → Map021 → Map022 rồi tách nhánh. Pha mì/nghỉ ngơi dẫn đến Map023 tiệm sách. Tìm chìa khóa, vào Map026 và đọc thư dẫn tới ký ức Map024 → Map028 do người dùng tự dựng → Map034 clone bao vây → Map029 chase QTE → Map025 đối đầu Vực Sâu → Map035 epilogue phòng ngủ/Group Chat → Map036 after-ending hint → Title. Map025 không phải scene Aira; đây là cảnh Hải Quỳ tự khẳng định tên Dahria. Không gộp nhánh tiệm sách và nhánh thư/chase nếu chưa có điều kiện hội tụ rõ trong nguồn.

Mỗi route cần ghi entry condition, transfer, flag đọc/ghi, gift/recipient, scene hội tụ, trao quà và ending. Không dùng `EVxxx` làm traceability; cần đổi tên event theo `SCN-xxx` sau khi route được duyệt.
