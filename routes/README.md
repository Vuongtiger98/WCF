# Route implementation index

Đây là lớp chuyển từ route design sang event/map. `04-route-map.md` giữ cây route; thư mục này ghi cách triển khai và điểm cần đối chiếu với project hiện tại.

## Route production order

Theo quyết định đã duyệt, route đầu tiên phải là route có nhiều scene nhất. Hiện tài liệu nguồn có nhiều route đồng hạng 13 scene, vì vậy chưa tự chọn canon. Đề xuất kỹ thuật: làm một route siêu thị hoàn chỉnh trước vì Map019 đã tồn tại và có nhiều event nhất trong nhóm mua quà.

## Route groups

| File dự kiến | Route | Map đã có | Trạng thái |
|---|---|---|---|
| `supermarket.md` | 4 món × 4 người nhận = 16 tổ hợp | Map006, Map019 | Map nền và event đã có; chưa chứng minh đủ 16 nhánh |
| `spicy-noodles.md` | Tin Aira/không tin Aira | Map014, Map010 | Có map bếp/bus; logic route chưa được registry hóa |
| `wanderer-leo.md` | Hỏi Leo | Map013 | Văn phòng có 88 event; cần gắn ID route |
| `wanderer-shylvie.md` | Hỏi Shylvie | Map013 | Có không gian map; cần kiểm tra event thoại |
| `atlantis.md` | Mua sách/ending Vực Sâu | Map020 (chưa đặt tên) | Chưa đủ dữ liệu để xác nhận map Atlantis |

## Quy tắc triển khai event

Mỗi route phải có: entry condition, map transfer, flag đọc/ghi, item hoặc gift ID, scene hội tụ, scene trao quà và ending. Không dùng tên `EV001` làm logic; đổi tên event theo mã `SCN-xxx` sau khi route được duyệt.

