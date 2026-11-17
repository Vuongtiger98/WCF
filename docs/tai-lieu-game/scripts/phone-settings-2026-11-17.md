# Cài đặt trong điện thoại — 17/11/2026

`Scene_System` hiện dùng theme điện thoại dọc 336×460, cùng hình nền, font Segoe UI/Arial, thẻ xanh đen và focus xanh tím với menu điện thoại. Thay phần cửa sổ Yanfly bằng sprite UI trong slot 198 `Custom Menu`; giữ các API cài đặt và handler thoát của Yanfly.

## Nội dung và thao tác

Danh sách có tám mục, hiện năm mục cùng lúc; thanh cuộn và chỉ số mục cho biết vị trí hiện tại:

1. Nhạc nền — phần trăm và thanh âm lượng BGM.
2. Âm thanh nền — phần trăm và thanh âm lượng BGS.
3. Hiệu ứng âm thanh — phần trăm và thanh âm lượng SFX.
4. Tự động chạy — Bật/Tắt.
5. Cách hiện thoại — Cả câu/Từng ký tự; mô tả rõ “Hiện cả câu ngay lập tức.” hoặc “Hiện dần từng ký tự.”.
6. Về màn hình chính — nhãn vàng cam.
7. Thoát game — nhãn đỏ.
8. Quay lại — trở về màn hình trước.

↑↓ chọn mục và cuộn danh sách; X quay lại. Với âm lượng, ←→ thay đổi 1%, giữ Shift để đổi 10%; giá trị giới hạn 0–100%. Với hai tùy chọn Bật/Tắt, ← tắt, → bật, Z đảo trạng thái. Mô tả và hướng dẫn phía dưới thay đổi theo mục đang chọn. Khi bật tự động chạy, Shift chuyển sang đi bộ theo hành vi Yanfly đang có.

Về màn hình chính/thoát game cần nhấn Z lần nữa để xác nhận; cảnh báo tiến độ chưa lưu sẽ mất. X hủy và giữ nguyên mục đang chọn. X ưu tiên nếu được nhấn cùng Z. Màn xác nhận chỉ có một khung **HƯỚNG DẪN PHÍM**, không có hai nút hoặc lựa chọn mũi tên. Cảnh báo và câu hướng dẫn Z dùng vàng cam/đỏ tương ứng.

## Hành vi và phạm vi

- Dùng `$game_system.volume`, `volume_change`, `autodash?`, `set_autodash`, `instantmsg?`, `set_instantmsg`. Thay đổi có hiệu lực ngay; cách lưu cấu hình cùng `Game_System` trong bản lưu vẫn theo Yanfly hiện có, không thêm file cấu hình toàn cục.
- Áp dụng âm lượng BGM/BGS bằng `last.play(last.pos)` để giữ vị trí đang phát. Không dùng `replay` cho cập nhật âm lượng vì lời gọi đó có thể bỏ qua bản nhạc đang phát. Không phát thử một track mới hoặc bật nhạc khi trước đó không có nhạc.
- Giữ `command_to_title`/`command_shutdown` của Yanfly, gồm fade âm thanh và chuyển scene. Giao diện chỉ thêm bước xác nhận trước khi gọi.
- Settings giữ điện thoại dọc, không cần xoay. Khi mở từ menu điện thoại, `transition_speed=0`; handoff vẫn giữ hình điện thoại cho tới freeze. Quay lại dùng cơ chế resume hiện có, không lặp slide-in.
- Bitmap chỉ vẽ lại khi điều khiển làm đổi trạng thái hoặc mở/hủy xác nhận. Dọn toàn bộ sprite/bitmap do scene sở hữu, giữ artwork trong Cache và ảnh nền của SceneManager.
- Không thêm thiết lập KUL. Add-on Graphics Menu hiện bị comment, các cấu hình ánh sáng vẫn giữ nguyên.

Backup trước sửa: `Data/codex_backup_phone_settings_20261117/`. Giữ nguyên 222 slot, ID/tên/thứ tự và CSV. Chỉ sửa source nén của `Custom Menu`; 78 file Data khác, map/event và web app QA không đổi. Palette màu được chuyển vào `WCFPhoneSaveDrawing` để Settings và Save/Load dùng chung.

## Kiểm tra

```text
ruby tools/test_phone_settings.rb
ruby tools/test_phone_menu_animation.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
```

`test_phone_settings.rb`: **39 case / 1.598 assertion**, gồm 8 case Settings và 31 case Save/Load; không failure/error. Bao gồm thao tác âm lượng/toggle, cuộn tới cuối, xác nhận/hủy, giới hạn bố cục, không redraw khi idle, cleanup và giữ tài nguyên Cache. Bộ animation: **32 case / 802 assertion**, không failure/error. Inventory/semantic xác nhận runtime khớp source và thứ tự CSV.

Native RGSS301/Ruby 1.9.2 trong bản sao `Save/PhoneSaveLoadQA_20261117_015633/` đã hoàn thành chuỗi Menu → Save → Menu → Túi đồ → Menu → Settings → Menu → Load. Xác nhận UI thay được hai cửa sổ Yanfly mặc định; âm lượng mới tới audio backend với vị trí BGM được giữ; autodash/instant-message đổi trên Game_System thật; hủy hai thao tác thoát không rời scene; quay lại menu không slide; tài nguyên được dọn. Save/Load vẫn lưu và tải đúng nhánh.

Đã xem ảnh dựng từ bitmap RGSS: `09-settings-audio.png`, `10-settings-system.png`, `11-settings-title-confirm.png`, `12-settings-exit-confirm.png`. Đây là kiểm thử script và bitmap trong bản sao riêng, không phải điều khiển phím thật trong cửa sổ game.
