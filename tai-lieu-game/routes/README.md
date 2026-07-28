# Route implementation

`04-route-map.md` là cây route; thư mục này là lớp chuyển route thành map/event.

| Route | Map liên quan | Hiện trạng |
|---|---|---|
| Siêu thị: 4 món × 4 người nhận | Map006, Map019 | Map019 có 43 event; chưa chứng minh đủ 16 nhánh |
| Mì cay: tin/không tin Aira | Map010, Map014 | Có bus/bếp; chưa có registry flag |
| Hỏi Leo | Map013 | Có 88 event; chưa gắn scene ID |
| Hỏi Shylvie | Map013 | Có không gian; cần xác định event thoại |
| Atlantis | Map020? | Map020 chưa tên, chỉ 1 event; cần xác nhận |

Route đầu tiên đã được chốt là ending Atlantis. Tuy nhiên map Atlantis chưa dựng; trước khi dựng route sẽ kiểm kê tuần tự các map hiện hữu, bắt đầu từ Map003 Văn phòng Silver Wing. Map generic được bỏ qua.

Mỗi route cần ghi entry condition, transfer, flag đọc/ghi, gift/recipient, scene hội tụ, trao quà và ending. Không dùng `EVxxx` làm traceability; cần đổi tên event theo `SCN-xxx` sau khi route được duyệt.
