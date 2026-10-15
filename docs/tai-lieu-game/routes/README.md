# Route runtime hiện tại

Đây là tài liệu route có thẩm quyền cho runtime. Các file có hậu tố `plan`, tài liệu trong `archive/` và DOCX trong `docs/kich ban/` là nguồn hoặc lịch sử triển khai, không được dùng để suy ra flow hiện tại khi chúng mâu thuẫn với file này.

## Điểm phân nhánh chính

Map010 có bốn lựa chọn:

1. Đi siêu thị.
2. Tới văn phòng Wanderer.
3. Xuống Atlantis.
4. Mua mì cay.

Mọi choice trung gian trong Test Hub phải có phương án Hủy và không thay đổi state khi hủy.

## Siêu thị — 16 tổ hợp quà/người nhận

```text
Map010 → Map019 → Map037 → Map038 → Map039 → Map036 → Title
```

- Variable 42 `MKT_GIFT`: máy pha cà phê, dao/chảo, đồ đan, bộ phá khóa.
- Variable 43 `MKT_TARGET`: Leo, Kohi, Shylvie, Hakase.
- Map037 dùng hai biến này để chọn một trong 16 cảnh chuẩn bị.
- Map038 chọn đúng scene tiệc và mở free roam/ném tuyết.
- Map039 chạy epilogue tương ứng. Riêng máy pha cà phê có nhánh cà phê thường hoặc đi câu cà phê Atlantis qua Map040.
- Map036 dùng `ENDING_HINT_ID` 2–17.

## Mì cay cho Leo

```text
Map010 → Map020 → Map019 hoặc Map020 → Map037 → Map014 → Map038 → Map036 → Title
```

- Tin Aira: Map019 chỉ chạy montage nguyên liệu, không kích hoạt hệ thống chọn quà.
- Không tin Aira: Hải Quỳ tự phân tích và chuẩn bị.
- Người nhận luôn là Leo.
- Cảnh chuẩn bị dùng page variant 47 của Map037. Map047 cũ chỉ còn là archive, không có incoming transfer.
- Map014 E025 tự khóa bằng Self Switch A để không lặp cảnh nấu khi quay lại bếp.
- Map038 dùng Switch 55/58/59 và E118 cho phần tiệc riêng của route mì cay.

## Hai route sách Atlantis

### Sách dịch chuyển cho Shylvie

```text
Map010 → Map022 → Map021 → Map023 → Map037 variant 49
→ Map038 E119 → Map050 → Map036 hint 19 → Title
```

Map049 đã archive; không dùng làm đích transfer runtime.

### Sách Ma Vương Cổ Đại cho Hakase

```text
Map010 → Map022 → Map021 → Map023 → Map037 variant 51
→ Map038 E120 → Map052 → Map036 hint 20 → Title
```

Map051 đã archive. Nhánh này vẫn thiếu sprite Hakase dạng mới và ending CG riêng.

## Nói chuyện với chủ tiệm sách trước

```text
Map023 → Map053 → Map054 → Map055 → Map036 hint 21 → Title
```

Đây là ending Vực Sâu tách biệt với hai route mua sách và với route phòng kho/rượt đuổi.

## Phòng kho, ký ức và rượt đuổi

```text
Map022 → Map026 → Map024 → Map028 → Map034 → Map029
→ Map025 → Map035 → Map036 hint 1 → Title
```

- Map024 kết thúc animation layer rồi mới hiện player và `falling_path` để free roam.
- Map028 là mê cung tự do với clone, choáng/reset, gai, đá lăn, cửa/nút, thùng lửa và KUL.
- Map034 là vòng vây clone và jumpscare.
- Map029 là chase QTE; bốn lần thất bại tại chase vẫn dẫn tới Game Over. Không nhầm với Map028, nơi lần choáng thứ tư reset người chơi về đầu mê cung.

## Hỏi Leo ba lần

```text
Map013 E097 → Map056 → Map057/058/059 → Map037 variant 60
→ Map038 E121 → Map036 hint 22–24 → Title
```

- Map057: dụng cụ ma pháp/áo choàng tàng hình → Hakase.
- Map058: cà phê đặc biệt → Kohi.
- Map059: cửa hàng vũ khí/khiên → Shylvie.
- Map060 đã archive; phần chuẩn bị dùng Map037.

## Hỏi Shylvie ba lần

```text
Map013 E098 → Map064 → Map037 variant 65 → Map038
→ Map066 → Map067 → Map036 hint 25–28 → Title
```

- Purple Garnet → Leo.
- Kim cương hình hạt cà phê → Kohi.
- Congo Tourmaline → Shylvie.
- Rainbow Fluorite → Hakase.
- Map065 đã archive; phần chuẩn bị dùng Map037.

## Điểm hội tụ Map037 và Map038

Map037 là stage chuẩn bị chung. Variable 83 `HQ_PREP_SCENE_VARIANT` chọn variant 37/47/49/51/60/65. Không chuyển trực tiếp tới các map chuẩn bị cũ.

Map038 là hub tiệc Giáng sinh dùng chung cho các route đã hội tụ. Trước khi mở free roam, mỗi page phải:

- khôi phục visibility/through/speed của player;
- reset camera và Map Effects;
- reveal KUL;
- dựng đúng NPC và layer bàn tiệc;
- giữ đúng state điện thoại và lựa chọn quà.

Trong free roam, người chơi có thể vào các phòng, chơi ném tuyết và lấy Item 18 `Ram`. RAM có thể nhặt từ mười event hoặc farm bằng cách thắng ném tuyết. Đủ 10 RAM kích hoạt cutscene Diana một lần qua Switch 82.

## Map archive

Map047, 049, 051, 060 và 065 được giữ để đối chiếu/rollback nhưng không có incoming transfer. Chúng nằm dưới group Map068 `ARCHIVED — Map chuẩn bị cũ`. Không xóa hoặc tái kích hoạt chúng khi chưa có yêu cầu.

## Quy tắc kiểm tra route

- Không transfer player tới tile không đi được nếu sau đó trả quyền điều khiển.
- Fade/KUL phải được dọn ở cả map nguồn và map đích.
- Không dựng lại toàn bộ map chỉ để sửa event; giữ nguyên vị trí và event do người dùng chỉnh.
- Không tự viết thêm thoại. Đối chiếu compact trước, sau đó DOCX nguồn khi compact thiếu hoặc mâu thuẫn.
- Điểm bắt đầu nhanh nằm ở Map069 Test Hub; checkpoint phải phục hồi cả timeline và tin nhắn điện thoại.
