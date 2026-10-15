# BGM và quy tắc chuyển cảnh âm thanh

Tên trong bảng là tên file BGM không kèm phần mở rộng. Tài nguyên runtime dùng OGG; `Magic10` và `Laser1` là SE thuộc RTP mặc định, không phải BGM cần chuyển đổi.

## Bảng phân bổ đã duyệt

| Khu vực/cảnh | BGM |
|---|---|
| Title | `mainmenu` |
| After Ending Hint | `sad magic` |
| Văn phòng và hành lang Silverwing | `silverwing` |
| Văn phòng Wanderer và các phòng bên trong | `WandererOffice` |
| Văn phòng Wanderer Giáng sinh, bếp và tiệc | `wochirstmas` |
| Chờ/đi xe bus | `bus` |
| Tiệm sách cũ Atlantis | `bookstore` |
| Phòng ngủ Hải Quỳ | `bedroom` |
| Nhà Hải Quỳ | `hqhouse` |
| Siêu thị | `smarket` |
| Tiệm dụng cụ ma pháp | `magishop` |
| Quán cà phê | `coffeeshop` |
| Cửa hàng vũ khí | `armshop` |
| Cửa hàng đá phong thủy | `rockshop` |
| Mê cung gương/cảnh căng thẳng | `pressure` |
| Vòng vây clone | `clone` |
| Chiến đấu và rượt đuổi | `combat` |
| Cảnh buồn/bad ending | `tragic` |
| Cảnh xúc động | `emotion` |
| Cảnh hài/gag | `gag` |

## Quy tắc runtime

- Khi chuyển sang map/cảnh có BGM đã duyệt, phát bài mới ở đầu scene sau khi state chuyển cảnh đã ổn định.
- Khi rời scene, bài cũ phải được thay hoặc fade out; không để BGM vô tình chạy xuyên sang địa điểm khác.
- Nếu chưa xác định BGM phù hợp, dùng Fadeout BGM và để scene im lặng. Không dùng một “BGM rỗng” giả và không tự chọn bài ngoài bảng.
- Map có nhiều phiên bản phải chọn nhạc theo ngữ cảnh scene, không chỉ theo map ID. Ví dụ Map014/Map038 có bản thường và Giáng sinh.
- Minigame có quyền lưu/phục hồi BGM trước trận, nhưng phải kiểm tra file tồn tại và không gọi nhầm SE như BGM.
- Khi test crash âm thanh, kiểm tra loại lệnh (`Play BGM`, `Play SE`, `Fadeout BGM`), tên file và phần mở rộng trước khi chuyển đổi lại asset.

## Checklist chuyển cảnh

1. Xác định BGM đích hoặc quyết định im lặng.
2. Fade/stop bài nguồn nếu bài đích khác hoặc không có bài đích.
3. Transfer và thiết lập KUL/camera.
4. Phát BGM đích đúng một lần; không lặp lệnh trong Parallel Process.
5. Playtest cả vào đúng route và vào trực tiếp từ Map069.

Static audit hiện tìm thấy kế hoạch âm thanh cho 64 map và Title dùng `mainmenu`. Những scene im lặng vẫn cần playtest để xác nhận đó là chủ ý, không phải lệnh âm thanh bị thiếu.
