# Đối chiếu route với map hiện có

## Kết luận nhanh

Project đã có khung map phù hợp với phần lớn route, nhưng chưa đủ bằng chứng rằng toàn bộ route design đã được dựng thành event. Nhiều event vẫn mang tên mặc định `EVxxx`, vì vậy chưa thể lập traceability từ scene trong tài liệu sang event runtime.

## Các map đã khớp định hướng

| Map | Tên/diễn giải | Kích thước | Event | Vai trò trong kế hoạch |
|---:|---|---:|---:|---|
| 3 | Văn phòng Silverwing | 22×23 | 65 | Mở đầu, hub Silver Wing |
| 6 | Thành phố | 110×32 | 7 | Di chuyển tới các khu mua sắm |
| 10 | Trong xe bus | 28×22 | 2 | Chuyển cảnh/route transit |
| 13 | Văn phòng Wanderer | 45×43 | 88 | Route hỏi Leo/Shylvie, tiệc |
| 14 | Bếp | 45×43 | 24 | Route mì cay, chuẩn bị đồ ăn |
| 15 | Phòng tắm | 26×22 | 18 | Exploration/easter egg; đã đọc và xác nhận |
| 17 | Hành lang Silverwing | 22×36 | 2 | Kết nối nội bộ/lore |
| 19 | Siêu thị | 50×50 | 43 | Route quà tặng chính |

## Map cần xác minh trước khi làm route tiếp

- Map020 `35×30`, chỉ có 1 event và chưa có tên hiển thị: chưa đủ căn cứ gọi là Atlantis.
- Map001/002/004/005/007/008/009/011/012/016/018/020 có nhiều event generic hoặc map trống; cần gán vai trò trước khi thêm route.
- Map013 và Map019 có nhiều event nhưng event name chưa gắn scene ID. Đây là điểm nghẽn lớn nhất khi so sánh với route.
- Map006 có transfer tới Map010, nhưng cần kiểm tra lại điều kiện và hướng đi để chắc chắn khớp flow bus trong timeline.

## Quyết định trước khi viết tiếp

1. Xác nhận Map020 có phải Atlantis hay chỉ là map tạm.
2. Chọn một route 13 scene trong nhóm đồng hạng.
3. Gắn `SCN-xxx` cho event quan trọng ở Map013/Map019.
4. Chỉ sau đó mới tạo flag/variable chính thức cho route; các tên trong `04-route-map.md` hiện vẫn là ID tạm.

