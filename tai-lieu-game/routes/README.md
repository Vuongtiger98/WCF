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

Map019 được giữ làm map test siêu thị, không thuộc route Atlantis. Flow hiện tại của Atlantis là Map010 → Map021 → Map022. Ở Map022, pha mì dẫn đến Map023; tìm chìa khóa và vào Map026 rồi đọc thư dẫn ngay đến ký ức Map024. Map023 không còn choice prototype tự viết; hiện chỉ chứa phần mở đầu tại tiệm đúng kịch bản. Map024 không còn thoại chase prototype tự viết; hiện dừng ở cờ `HQ_MEMORY_CHASE_READY` vì chưa có map gương/Clone.

Mỗi route cần ghi entry condition, transfer, flag đọc/ghi, gift/recipient, scene hội tụ, trao quà và ending. Không dùng `EVxxx` làm traceability; cần đổi tên event theo `SCN-xxx` sau khi route được duyệt.
