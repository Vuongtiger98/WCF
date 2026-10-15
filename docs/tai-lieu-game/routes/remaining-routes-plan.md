# Kế hoạch triển khai các route còn lại

> **Tài liệu lịch sử/biên bản hoàn thành.** Backlog trong file này đã bằng 0. Các flow còn nhắc Map047/049/051/060/065 là mô tả trước khi hội tụ toàn bộ preparation vào Map037; xem `routes/README.md` để lấy flow runtime hiện tại.

Trạng thái cập nhật ngày 2026-09-07. Toàn bộ route trong backlog này đã được dựng vào runtime.

## Hiện trạng

- Route mì cay đã nối Map010 → Map020 → Map019/047 → Map014 → Map038 → Map036 với hai nhánh Aira/Hải Quỳ và free roam/ném tuyết dùng chung.
- Route siêu thị đã có đủ ma trận 4 món × 4 người nhận trong runtime hiện tại.
- Ending Atlantis đặc biệt qua kho, clone, rượt đuổi, Paulie và cảnh kết đã được dựng.
- Hai route sách tiêu chuẩn của Map023 đã có chuẩn bị quà, tiệc, epilogue và hint.
- E097 Map013 đã nối đủ ba nhánh hỏi Leo; E098 đã nối đủ bốn nhánh hỏi Shylvie.
- Ghi chú cũ cho rằng Map020 là Atlantis hoặc các route siêu thị còn thiếu đã lỗi thời; cần sửa khi bắt đầu đợt triển khai.

## Backlog route

| Nhóm | Số nhánh chưa hoàn thiện |
|---|---:|
| Hỏi Leo | 0 — đã hoàn thành |
| Hỏi Shylvie | 0 — đã hoàn thành |
| Sách Atlantis tiêu chuẩn | 0 — đã hoàn thành |
| Tổng | 0 |

## Thứ tự đề xuất

### Đã hoàn thành — Mì cay cho Leo

Flow:

```text
Map010 xe bus
→ lựa chọn Mua mì cay
→ Map020 tiệm mì cay
→ Tin tưởng Aira / Có cái nịt
├─ Tin Aira: cutscene mua nguyên liệu tại Map019
└─ Không tin: mua toàn bộ mì tại Map020, về nhà ăn và phân tích công thức
→ cảnh chuẩn bị/ngủ
→ Map014: Aira hoặc Hải Quỳ nấu
→ tiệc Giáng sinh và trao mì cay cho Leo
→ free roam và bốn trận ném tuyết tùy chọn trên Map038
→ cuộc gọi Silver Wing
→ ending/hint
```

Quy tắc:

- Người nhận cố định là Leo; không mở menu chọn bốn người.
- Hai nhánh chỉ khác khâu mua nguyên liệu, chuẩn bị và người nấu.
- Hội tụ ở Sting 20 lít, tiệc, nồi mì cay và gag đá bào mì cay.
- Không tự viết epilogue sáng hôm sau; nguồn hiện kết thúc khi Hải Quỳ rời tiệc làm nhiệm vụ.
- Map019 chỉ chạy cutscene mua nguyên liệu, không kích hoạt hệ thống chọn quà siêu thị.
- Không dùng lại Variable 42–44 của route siêu thị. Runtime dùng Variable 50–51 và Switch 55–59.
- Map038 là shell văn phòng Giáng sinh dùng chung; logic mì cay nằm ở page E001/E005 và E118 riêng. Map048 chỉ là donor/rollback, không còn thuộc flow runtime.

### 1. Hai route sách Atlantis tiêu chuẩn

- E012 Map023: sách dịch chuyển cho Shylvie — **đã dựng** qua Map037 variant 49 → Map038 E119 → Map050.
- E036 Map023: sách Ma Vương Cổ Đại cho Hakase — **đã dựng** qua Map037 variant 51 → Map038 E120 → Map052 → Map036.
- Cả hai nhánh đã chặn đổi sách sau khi chọn, có checkout, chuẩn bị quà, tiệc/free roam, trao quà, epilogue và ending hint đúng compact.
- Nhánh Hakase dùng Hint 20 B2746–B2760; chưa có sprite Hakase dạng mới hoặc ending CG riêng trong tài nguyên.
- Giữ tách biệt hoàn toàn với tuyến nói chuyện chủ tiệm trước và ending Vực Sâu.

### 2. Route hỏi Shylvie — đã hoàn thành

- Dùng E098 Map013 làm entry sau lượt hội thoại thứ ba.
- Dựng tiệm đá từ `Jewel_Shop_Base`.
- Bốn kết quả: Purple Garnet → Leo; kim cương hình hạt cà phê → Kohi; Congo Tourmaline → Shylvie; Rainbow Fluorite → Hakase.
- Flow runtime: Map013 E098 → Map064 → Map037 variant 65 → Map038 → Map066 → Map067 → Map036 → Title.
- Đã có ảnh vật phẩm, chuẩn bị, tiệc, trao quà, epilogue và hint 25–28 cho đủ bốn nhánh.
- Dùng Switch 76–79 và Variable 57–58 riêng; Map066/067 là bản riêng nên không sửa logic Map038/039 dùng chung.
- Có thể dựng lại idempotent bằng `ruby tools/rvdata2_audit.rb implement-shylvie-jewel-routes`.

### 3. Route hỏi Leo — đã hoàn thành

- Dùng E097 Map013 làm entry sau lượt hội thoại thứ ba.
- Ba kết quả: dụng cụ ma pháp/áo choàng tàng hình → Hakase; cà phê đặc biệt → Kohi; cửa hàng vũ khí/khiên → Shylvie.
- Flow runtime: Map013 → Map056 → Map057/058/059 → Map037 variant 60 → Map038 E121 → Map036.
- Dùng `Magic_Store_Base`, `Isekai_Caffe_Base` và `Cuahangvukhi_bas3`; `Crafting_Room_Base` đã được xác nhận không phải cửa hàng vũ khí.
- Đã có chuẩn bị, free roam/ném tuyết, trao quà, Gallery và hint 22–24. Nguồn không chỉ định epilogue sáng hôm sau riêng nên route kết thúc sau cuộc gọi Silver Wing.

## Hạ tầng và kiểm thử chung

1. Cấp flag riêng cho nhóm route, biến thể, quà/người nhận và tiến độ; không tái sử dụng state siêu thị.
2. Mỗi route phải có entry condition, transfer, state đọc/ghi, điểm hội tụ và ending rõ ràng.
3. Dùng bộ dựng idempotent; chạy audit lệnh Control Switches/Variables lặp sau mỗi lần dựng.
4. Audit không có transfer tới map trống, sai tọa độ hoặc không có đường quay lại.
5. Chuẩn hóa Fade Out → transfer no-fade → thiết lập map → Fade In.
6. Mỗi map phải phục hồi player visibility, through, tốc độ, camera và lighting trước khi trao quyền điều khiển.
7. Khi Picture/CG đang hiện hoặc màn hình đen, dùng thoại thường; chỉ dùng Pop Message khi nhân vật/event thật đang hiển thị trên map.
8. Không tự sửa mâu thuẫn nội dung có chủ ý và không tự viết thêm thoại/epilogue ngoài phần được cho phép.
