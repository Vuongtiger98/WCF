# Chỉnh giao diện điện thoại — 15/11/2026

Đã sửa `Custom Menu` tại slot runtime 198 và đồng bộ vào `Data/Scripts.rvdata2`. Không thêm slot, đổi thứ tự Script Editor, sửa map hoặc đổi thoại/nhánh truyện. Backup trước sửa: `Data/codex_backup_phone_ui_20261115/`.

## Lỗi bố cục và bản sửa

| Phần | Trước | Sau |
|---|---|---|
| Khung điện thoại | Ảnh 350×480 bị kéo thành 350×450 | Khung 336×460, gần đúng tỷ lệ gốc, căn giữa màn hình 640×480 |
| Trang chính | Widget và icon đặt rời rạc; thiếu nhãn chức năng; hình nền lấn chữ | Chung lề 24 px, thẻ nền tối, lưới sáu ứng dụng có tên, hướng dẫn phím ở chân màn hình; nền map được làm dịu phía sau điện thoại |
| Icon được chọn | Zoom quanh góc trái trên nên tâm bị trôi; quầng trắng quá sáng | Neo đúng tâm, kích thước cơ sở 50 px, pulse nhẹ; viền chọn xanh tím nằm trong thẻ |
| Chữ và widget | Nhiều cỡ/chất chữ; một số nhãn dài bị ép vào vùng hẹp | Segoe UI/Arial, màu/cỡ chữ thống nhất, ellipsis theo độ rộng thực cho nhãn; dịch các nhãn widget mặc định khi hiển thị, giữ nguyên dữ liệu lưu và hỗ trợ nhãn tùy chỉnh |
| Danh bạ | Avatar/tên/phần mô tả có thể vượt vùng thẻ | Ba hàng cùng chiều rộng, avatar 44 px, tên/mô tả/bản xem trước chia hàng rõ ràng |
| Lịch sử chat | Wrap theo số ký tự; tên người gửi phải dùng một chiều rộng cố định nên không thẳng với bong bóng | Wrap theo độ rộng font thực, giữ xuống dòng và dấu tiếng Việt; tên bám đúng cạnh bong bóng/ảnh; tên người gửi của liên hệ thường dùng tên liên hệ |
| Tin quá dài | Có thể không vừa vùng hiển thị và bị loại khỏi danh sách đang vẽ | Chia phần, đọc bằng ↑↓, có số phần; không sửa hoặc cắt nội dung lưu. Cache wrap tối đa 32 mục, nhận biết chuỗi bị sửa tại chỗ |
| Gallery | Sáu ô làm hàng cuối chồng vùng chú thích; thumbnail và ảnh lớn bị kéo sai tỷ lệ | Lưới 2×2, chú thích/hướng dẫn tách khỏi thẻ, giữ aspect ratio; ô khóa dùng biểu tượng cùng tông giao diện. Tổng ID/unlock không đổi; runtime hiện có 90 ô, 23 trang |
| Xem ảnh lớn | Kéo ảnh lấp đầy màn hình | Giữ tỷ lệ, không tự phóng ảnh nhỏ; dành riêng 32 px cho hướng dẫn. CG 544×416 giữ kích thước gốc |

Các phím và chức năng Túi đồ/Lưu/Tải/Cài đặt/Tin nhắn/Gallery giữ nguyên. Các preset timeline, `PhoneMenuScript`, Contacts, group chat, lựa chọn và registry Gallery tiếp tục dùng dữ liệu cũ.

## Cleanup khi quay lại menu

`SceneManager.call` có thể đưa cùng instance Scene_Menu trở lại sau Túi đồ/Lưu/Tải/Cài đặt. Trước đây cờ `@phone_menu_disposed` vẫn true từ lần rời menu trước, làm cleanup lần sau bị bỏ qua. `start` nay đặt lại cờ trước khi tạo giao diện mới.

Sprite app/ảnh đại diện giữ bản bitmap riêng để hàm dọn sprite không hủy ảnh nguồn trong Cache. Nền map phía sau không tham gia animation trượt của điện thoại. Bảng widget vẫn chỉ redraw khi dữ liệu đổi; không dựng lại toàn bộ giao diện mỗi frame.

## Kiểm tra

`ruby tools/test_phone_menu_layout.rb` chạy cả bộ performance hiện có: **25 case / 673 assertion**, không failure/error. Các ca mới kiểm tra tâm icon ở mức pulse lớn nhất, biên chữ, cache ảnh sau dispose, text tiếng Việt dạng dấu ghép, chia phần tin dài không mất nội dung, tên bám cạnh bong bóng, giới hạn cache wrap, thẻ Gallery không chồng caption/footer, aspect ratio, vùng hướng dẫn ảnh lớn và animation không kéo lệch nền map.

Thêm hai bộ lifecycle/probe: tổng **35 case / 726 assertion**, không failure/error. `script_inventory check` xác nhận parse/export/CSV khớp; `check-phone-ui-scope` xác nhận chỉ source slot 198 thay đổi, toàn bộ 222 identity/order được giữ. Hash Map069, System và CSV cũng giữ nguyên so với lúc bắt đầu.

Đã chạy RGSS301/Ruby 1.9.2 trong bản sao tại `Save/PhoneUIPlaytest_20261115/current`, quan sát bằng Computer Use. Harness gọi API scene vì phím gửi từ công cụ không được game nhận ổn định:

- Trang chính, danh bạ, tin nhóm, phần cuối tin dài, Gallery trang đầu/trang cuối và xem CG lớn: kiểm tra biên sprite **PASS**, serialize dữ liệu lưu **PASS**.
- Điện thoại → Túi đồ → trở lại điện thoại → đóng về map: cả hai lần start có cleanup guard false; cả hai lần dispose có `remaining_bitmaps=0`. Map hiện lại đầy đủ sau khi đóng điện thoại.
- Mẫu 600 frame của trang chính và Gallery/xem ảnh ổn định khoảng **60 FPS trên máy đang kiểm tra**, p95 khoảng **18 ms**. Chưa đo trên laptop báo lag.

Log local: `Save/PhoneUIPlaytest_20261115/current/ui-report.txt` và thư mục `current/Save/Performance_*.txt`. Nội dung tin dài và unlock được thêm để thử chỉ tồn tại trong bản sao. Chưa xác nhận toàn bộ thao tác phím bằng cách chơi tay hoặc tất cả preset/save cũ.

```text
ruby tools/test_phone_menu_layout.rb
ruby tools/test_script_graphics_lifecycle.rb
ruby tools/test_rgss_performance_probe.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
ruby -W0 tools/script_inventory.rb check-phone-ui-scope
```

## Bổ sung: animation mở điện thoại

Người dùng nhận thấy đóng có trượt nhưng mở không có. Nguyên nhân xác nhận trong `post_start`: nhánh kiểm tra caller loại `Scene_Map` cùng các scene Túi đồ/Lưu/Tải/Cài đặt, sau đó đặt `:idle` và offset 0. Vì vậy trạng thái `:opening` tạo ở `start` bị ghi đè. Ngoài ra, khi `SceneManager.return` trở về điện thoại, stack đã pop scene con; top stack không thể dùng để nhận diện scene vừa rời.

Đã bỏ điều kiện caller và cờ `@from_external_scene`; mọi lần vào Scene_Menu đều bắt đầu ngoài mép dưới, trượt lên trong `SLIDE_DURATION = 30` frame (khoảng 0,5 giây ở 60 FPS). Khung, overlay, widget, icon và viền chọn cùng xuất hiện/trượt như một khối; nền map vẫn đứng yên. Khởi tạo tấm đen legacy ở trạng thái ẩn để không chớp một ô đen đứng yên trong scene transition. Chiều đóng vẫn dùng easing và thời gian cũ; input menu chỉ được xử lý khi mở xong.

Kiểm tra offline `ruby tools/test_phone_menu_animation.rb`: **29 case / 741 assertion**, gồm 25 case layout/performance và 4 case animation. Bản trước sửa có 3 failure / 0 error; bản sau sửa không failure/error. Kiểm tra mở từ map và các scene con, vị trí giữa/cuối animation, các phần cùng dịch chuyển, nền map đứng yên, khóa input lúc mở và đóng/dọn/return đúng một lần.

Tổng cùng hai bộ lifecycle/probe: **39 case / 794 assertion**. Không mở game hoặc dùng Computer Use trong lượt sửa animation này, theo yêu cầu tạm dừng chơi trực tiếp. Chưa xác nhận animation bằng quan sát engine sau bản sửa.

Backup riêng trước sửa: `Data/codex_backup_phone_open_20261115/`. Chỉ source slot 198 thay; kiểm tra bằng `ruby -W0 tools/script_inventory.rb check-phone-open-scope`. Toàn bộ ID, tên, thứ tự script và map/event giữ nguyên.

Ngày 16/11: yêu cầu quay lại từ màn hình con không được slide-in. Hành vi "mọi lần vào Scene_Menu đều mở lại" trong phần trên đã được thay bằng cờ resume trên từng instance. Save/Load xoay ngang khi vào và xoay về dọc khi trở lại; xem [bản cập nhật Save/Load](phone-save-load-2026-11-16.md).
