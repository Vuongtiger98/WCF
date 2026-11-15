# Save / Load trong điện thoại — 16/11/2026

Mốc trước thay đổi đã commit/push lên `origin/master`: `a56ad23`. Bản sửa này chỉ thay source slot 198 `Custom Menu`, giữ nguyên 222 slot, ID/tên/thứ tự script, CSV, map/event và save của người chơi. Backup trước sửa nằm tại `Data/codex_backup_phone_save_20261115/` (bắt đầu trước nửa đêm); trước lần đổi sang ngang: `Data/codex_backup_phone_landscape_20261116/`; trước lần thêm nhãn/Z-X/luồng Title: `Data/codex_backup_phone_labels_20261116/`. Chưa đổi giao diện Settings.

## Giao diện và hành vi

- Save/Load dùng điện thoại ngang **460×336**, font/màu xanh đen và thẻ chọn xanh tím. Giữ 24 ô của Yanfly, **hai ô/trang, 12 trang** để nhãn có đủ chỗ. Tiêu đề cỡ 24, mốc truyện/nội dung 17–19; màn so sánh có chữ nhỏ hơn để vừa hai cột. ↑↓ chọn ô, ←→/Q/W đổi trang; **Z** mở/xác nhận, **X** quay lại/hủy. Mọi hint Enter/Esc trong Custom Menu, gồm trang chính, danh bạ, lịch sử chat, Gallery/xem ảnh/lật trang và Save/Load, đã đổi nhãn sang Z/X. Input vẫn dùng hành động RGSS `:C`/`:B`, không đổi binding.
- Vào Save/Load: thân điện thoại xoay 0→90° quanh tâm trong 24 frame (~0,4 giây), kết thúc mới hiện chữ nằm ngang/upright. Quay lại: ẩn nội dung, xoay 90→0° trong 24 frame rồi mới trả về màn hình trước. Tạm thu nhỏ thân ở giữa animation để góc điện thoại không bị cắt ở màn hình 640×480; cuối animation trở về scale 1. Nền cảnh không xoay. Input bị khóa trong cả hai chiều xoay.
- Màn hình chi tiết có thông tin bên trái, thao tác bên phải. Xác nhận ghi đè đặt dữ liệu đang có và dữ liệu sắp lưu cạnh nhau. Chữ dài wrap theo pixel trong vùng thông tin, không kéo giãn font.
- Mỗi thẻ gồm mốc truyện, địa điểm, món quà/người nhận đã xác nhận và thời gian chơi. Bỏ tiền, level, đội hình, số lần lưu và hai cột variable khỏi giao diện. Tên map biên tập như `(C)`, tên variant hoặc ID không được dùng làm nhãn người chơi.
- Nhãn rõ ràng: **Route:** là nhóm nhánh đã chọn, **Mốc truyện/Mốc:** là đoạn đang chơi, **Vị trí hiện tại:** là map trong save; Quà/Người nhận/Đã tặng/Đã chơi có nhãn riêng. Ví dụ save nhà Hải Quỳ có Route Atlantis, mốc Về nhà và vị trí Nhà Hải Quỳ — không gọi “Về nhà” là tên route.
- Màn hình chi tiết có avatar người nhận, ngày giờ lưu và các thao tác theo ngữ cảnh. Không có thao tác lưu trong Scene_Load. Tôn trọng `save_disabled`.
- Lưu, tải, xóa đều cần xác nhận bằng một lần nhấn Z mới sau khi mở hộp xác nhận; X hủy ngay. Ghi đè so sánh mốc, địa điểm, quà/người nhận và thời gian giữa dữ liệu đang có và dữ liệu sắp ghi. Lưu thành công cập nhật thẻ tại chỗ.
- Phân biệt ô trống với file không đọc được. Không cho tải ô trống/hỏng. Vẫn có thể xác nhận xóa hoặc ghi đè file hỏng ở màn hình phù hợp. Nếu tải thất bại, giữ giao diện và báo lỗi.
- Thông báo lưu/xóa tự biến mất; không đọc file hoặc dựng lại bitmap mỗi frame. Chỉ đọc header của hai ô đang hiện khi mở trang; cache trong scene chỉ giữ mô tả đơn giản.

## Load từ màn hình chính

`Scene_Menu#leave_phone_scene` gắn `wcf_phone_origin = :phone` trực tiếp lên instance Scene_File vừa được tạo. Chỉ nguồn này mới xoay 0→90 khi vào và 90→0 khi quay lại. Không suy caller bằng top stack hoặc global dùng chung.

Load từ Title không có điện thoại dọc trước đó nên hiện sẵn góc 90, nội dung xuất hiện ngay; X trả về Title trực tiếp, không xoay về dọc. Hộp tải game ở Title ghi “Tiếp tục từ bản lưu này?”, không cảnh báo mất tiến độ chưa lưu khi chưa chơi. Caller khác mở trực tiếp Scene_File cũng dùng landscape tĩnh. Context là state UI của instance, không lưu trong save.

## Tên bản lưu và phím xác nhận trực tiếp

Tất cả tên hiển thị dùng `Bản lưu 01` … `Bản lưu 24` thay cho `Ô 01`, gồm danh sách, chi tiết, tiêu đề lưu/tải/xóa/ghi đè và thông báo kết quả. Danh sách dành một dòng riêng cho tên bản lưu và thời gian; các nhãn Route/Mốc truyện/Vị trí/Quà nằm các dòng dưới, không ép tên dài vào vùng 52 px cũ. Không đổi số thứ tự, số lượng bản lưu hoặc tên file `SaveNN.rvdata2`.

Trong hộp `:confirm`, Z thực hiện thao tác đang xác nhận và X hủy, không còn dùng mũi tên để chọn một nút. Hai thẻ phía dưới/phía phải là hướng dẫn phím cố định, không hiển thị focus mặc định. Mũi tên được bỏ qua ở bước này, không phát tiếng cursor hoặc redraw. Nếu X và Z cùng được nhấn trong một frame, X ưu tiên hủy. Z dùng để mở hộp xác nhận không tự thực hiện luôn trong cùng update. Danh sách bản lưu và danh sách thao tác trước bước xác nhận vẫn chọn bằng mũi tên vì có nhiều mục khác nhau.

Backup trước thay đổi: `Data/codex_backup_phone_shortcuts_20261116/`.

## Nháy đen khi vào Save/Load

Người dùng thấy chiều quay về đã mượt nhưng chiều mở có khoảng nháy đen. Kiểm tra lifecycle phát hiện `leave_phone_scene` ẩn/hủy toàn bộ phone sprite trước khi `Scene_Base#terminate` gọi `Graphics.freeze`. Vì vậy frame chuyển cảnh có thể trống. Scene_File còn chạy fade mặc định 10 frame và bắt đầu bằng overlay 240, khác overlay trang chính 172.

Đã để hook `terminate` hiện có dọn sprite sau freeze, không dọn ngay trong handler mở ứng dụng. `Scene_File#transition_speed` trả 0 khi mở từ phone để animation xoay làm chuyển cảnh duy nhất; caller Title vẫn dùng transition gốc. Overlay đầu animation dùng cùng alpha 172 với trang chính, tăng dần tới 240 theo easing xoay. Chỉ vẽ lại overlay khi alpha đổi. Chiều xoay ngược vẫn giữ 240 như trước.

Ba ca regression tái hiện trên bản cũ đều fail: phone không còn visible/alive sau app call, transition speed còn 10, overlay đầu không khớp trang chính. Sau sửa đều đạt. Backup riêng: `Data/codex_backup_phone_transition_20261116/`.

## Quay về trang điện thoại

Lỗi slide-in lặp lại bắt nguồn từ `Scene_Menu#post_start` luôn gán `:opening`, kể cả khi instance menu cũ được `SceneManager.return` đưa trở lại. Nay `leave_phone_scene` đánh dấu `@phone_app_suspended` trên chính instance đó; lần `start` tiếp theo tiêu thụ cờ và dựng điện thoại tại vị trí nghỉ, `post_start` dùng `:idle`. Cờ không dựa trên caller ở top stack hoặc global kéo dài sang New Game.

Save/Load xoay về dọc xong mới return; Túi đồ/Cài đặt cũng trở về menu tại chỗ. Danh bạ/Thư viện là các màn trong cùng instance, tiếp tục dùng trạng thái idle sẵn có. Đóng điện thoại về map rồi mở lại vẫn có animation trượt vào bình thường. Bitmap/sprite của instance được tạo/dọn lại như trước, cờ cleanup được reset ở `start`.

## Nguồn thông tin

`WCFPhoneSaveRecord` dùng registry route tại `systems/flags-and-variables.md` và map hiện tại để tạo thông tin hiển thị. Đây là nhãn UI, không phải thoại mới hoặc nhánh truyện mới.

- Siêu thị: V42 chọn quà, V43 chọn người nhận; đủ 16 tổ hợp. Không dùng tên người đưa gợi ý để suy ra người nhận.
- Mì cay, hai sách Atlantis, ba nhánh gợi ý Leo, bốn viên đá đều có mapping riêng. Tiệm ma pháp/cà phê dùng stage 2 cho free roam trước khi mua: chưa hiển thị quà như đã chọn ở stage này. Tiệm đá chỉ xác nhận món sau khi stage đạt 2.
- Trạng thái đã tặng chỉ hiện sau mốc tương ứng; không hiển thị trước ending hoặc tỷ lệ hoàn thành. Không đưa tiến độ Gallery vào ô lưu vì Gallery dùng chung giữa các save.
- Nếu thiếu người nhận hoặc có nhiều route cạnh tranh, không đoán tên món/người nhận. Map chưa có nhãn dùng mô tả chung hoặc display name, không lộ tên nội bộ MapInfo.

Alias `DataManager.make_save_header` thêm `:wcf_phone_save` phiên bản 1, gồm các chuỗi/số/bool, hiện có thêm chuỗi `:route`. Header Yanfly và save contents vẫn giữ nguyên; không đổi `extract_save_contents`. Không lưu bitmap/viewport/UI vào metadata. Save version 1 cũ thiếu route được bổ sung khi đọc từ switch/variable/map của header đó; không ghi lại file cũ hoặc dùng state live.

Save cũ không có metadata được mô tả từ map/switch/variable nằm trong chính header đó, không dùng state của lượt chơi đang chạy. Ngày giờ của save mới là thời điểm lưu thực; save cũ dùng mtime của file nếu thiếu timestamp. File cũ đã copy/chỉnh mtime có thể có ngày giờ khác thời điểm lưu gốc.

`ps_execute(:load)` gọi `on_load_success` hiện có, giữ chuỗi Yanfly/MOG Weather/GlobalGallery và `Game_System.on_after_load`. Các hàm save/load của DataManager không bị thay thế. Trước ghi đè, wrapper sao lưu byte file cũ vào `<save>.phone-backup`; nếu stock save thất bại và xóa file, wrapper khôi phục bản cũ. Nếu còn backup chưa xử lý, từ chối ghi đè thêm; lỗi khôi phục giữ file backup để xử lý thủ công.

## Kiểm tra

```text
ruby tools/test_phone_save_load.rb
ruby tools/test_phone_menu_animation.rb
ruby tools/test_script_graphics_lifecycle.rb
ruby tools/test_rgss_performance_probe.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
ruby -W0 tools/script_inventory.rb check-phone-save-scope
ruby -W0 tools/script_inventory.rb check-phone-landscape-scope
ruby -W0 tools/script_inventory.rb check-phone-labels-scope
ruby -W0 tools/script_inventory.rb check-phone-transition-scope
ruby -W0 tools/script_inventory.rb check-phone-shortcuts-scope
```

Bộ Save/Load kiểm tra mapping nhánh, route/mốc/vị trí riêng, header cũ/mới và route metadata thiếu, lưu/ghi đè/xóa/hủy, quyền lưu, file hỏng, backup phục hồi, paging/cache, clipping, cleanup, từng frame xoay và luồng Title không xoay/không cảnh báo mất tiến độ. Thêm ca xác nhận Z trực tiếp không dùng mũi tên, X hủy cả lưu/tải/xóa, X ưu tiên khi nhấn cùng Z, nhãn Bản lưu và không có hint mũi tên trong hộp xác nhận. Bộ phone animation/layout/performance kiểm tra context handoff, thời điểm dọn sprite, fade/overlay, quay lại bốn scene con và mở menu mới sau khi bỏ scene cũ. Lượt mới nhất: **71 case / 1612 assertion**, không failure/error (29 case Save/Load + 32 phone/layout/performance + 7 lifecycle + 3 probe).

Kiểm tra native tự động trong bản sao dưới `Save/PhoneSaveLoadQA_*`: builder `tools/build_phone_save_load_qa.rb` chỉ chèn harness `tools/qa_phone_save_load_native.rb` vào pack bản sao. Tạo junction Graphics/Audio/System tới tài nguyên gốc và chạy Game.exe của bản sao. Không chạy route hoặc dùng phím/chuột; các file lưu thử chỉ ở bản sao.

RGSS301/Ruby 1.9.2 đã xác nhận ghi bằng Yanfly, đọc/tải save cũ, ghi đè đúng người nhận, tải đúng map/state/điện thoại, qua load-success hooks và dọn tài nguyên. Lượt đầu phát hiện wrapper viewport không có `disposed?`; đã sửa cleanup dựa trên quyền sở hữu và xóa tham chiếu, lượt sau đạt. Lượt ngang tại `Save/PhoneSaveLoadQA_20261116_004127/` chạy đầy đủ Menu→Save→Menu→Túi đồ→Menu→Cài đặt→Menu→Danh bạ/Thư viện→Load→Menu→Load: xác nhận góc 0 trước khi return và tất cả lần resume đều idle/offset 0, mở mới vẫn opening.

Lượt nhãn/Title tại `Save/PhoneSaveLoadQA_20261116_005712/` thêm Title→Load→Title thật trước chuỗi trên: vào landscape ngay, trở về Title không xoay, sau đó mở từ điện thoại vẫn xoay đầy đủ và resume không slide. Ảnh `00-title-load.png`, `02-save-detail.png`, `03-overwrite.png` thể hiện nhãn và Z/X. Harness âm thanh Title bị tắt để chỉ kiểm tra điều hướng.

Lượt chống nháy tại `Save/PhoneSaveLoadQA_20261116_010803/` đạt đầy đủ chuỗi trên. Hook tại app call và `Graphics.freeze` xác nhận tất cả phần phone đang hiện vẫn visible/alive; `post_start` xác nhận phone→file dùng `transition(0)` và overlay ban đầu 172, Title→Load vẫn transition 10/overlay 240. Vẫn xác nhận xoay về dọc trước return, không slide khi resume và lưu/tải đúng state. Đây là kiểm tra lifecycle/trạng thái RGSS tự động, không phải quan sát chuyển động hoặc đo luminance của frame trình chiếu thật.

Lượt phím tắt tại `Save/PhoneSaveLoadQA_20261116_011902/` gọi chính `ps_update_actions` với trạng thái `:C`/`:B` của harness, không chọn nút bằng mũi tên: ghi đè bằng Z, tải bằng Z và hủy xóa bằng X đều đạt. Ảnh `01-save-list.png`/`03-overwrite.png` xác nhận tên Bản lưu và hai thẻ phím tắt không có focus. Không gửi phím thật vào cửa sổ game.

Ảnh QA dựng từ chính Bitmap/font RGSS của giao diện, không phải ảnh chụp chơi tay. Harness bỏ vòng chờ `Graphics.update`/input của cửa sổ ẩn; xoay bitmap khung/overlay 90° và ghép nội dung theo tọa độ để kiểm tra bố cục. Các góc/trạng thái animation được kiểm tra bằng script, chưa quan sát chuyển động hoặc thao tác phím trực tiếp trong cửa sổ game. Xem `save-load-qa.txt` và ảnh `01-save-list.png` … `08-load-confirm.png` trong thư mục QA.
