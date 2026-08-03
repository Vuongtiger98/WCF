# Route implementation

`04-route-map.md` là cây route; thư mục này là lớp chuyển route thành map/event.

| Route | Map liên quan | Hiện trạng |
|---|---|---|
| Siêu thị: 4 món × 4 người nhận | Map006, Map019 | Map019 có 43 event; chưa chứng minh đủ 16 nhánh |
| Mì cay: tin/không tin Aira | Map010, Map014 | Có bus/bếp; chưa có registry flag |
| Hỏi Leo | Map013 | Có 88 event; chưa gắn scene ID |
| Hỏi Shylvie | Map013 | Có không gian; cần xác định event thoại |
| Atlantis | Map010 → Map021 | Map021 route gate đã tạo; khu vực Atlantis chưa dựng |

Route đầu tiên đã được chốt là ending Atlantis. Tuy nhiên map Atlantis chưa dựng; trước khi dựng route sẽ kiểm kê tuần tự các map hiện hữu, bắt đầu từ Map003 Văn phòng Silver Wing. Map generic được bỏ qua.

Map019 được giữ làm map test siêu thị, không thuộc route Atlantis. Map021 `Điểm xuống Atlantis` là route gate đầu tiên; Map010 có choice chuyển tới Map021 tại `(4,4)`.

Mỗi route cần ghi entry condition, transfer, flag đọc/ghi, gift/recipient, scene hội tụ, trao quà và ending. Không dùng `EVxxx` làm traceability; cần đổi tên event theo `SCN-xxx` sau khi route được duyệt.
