# Tin nhắn chưa đọc theo bản lưu — 16/11/2026

Đã triển khai trong ba slot hiện có: **197 Cutscene Group Chat**, **198 Custom Menu**, **219 WCF Test Hub**. Giữ nguyên ID/tên/thứ tự của 222 slot, CSV và toàn bộ map/event. Backup riêng: `Data/codex_backup_phone_unread_20261116/`.

## Hành vi

- Chấm hồng nhỏ có viền sáng trên icon Tin nhắn khi còn cuộc trò chuyện chưa đọc; trong danh sách, từng cuộc có chấm riêng.
- Khi mở chat, phần chưa đọc có mốc “Tin nhắn mới”; tin/ảnh chưa đọc có chấm cạnh tên người gửi. Mốc giữ vị trí ổn định trong lượt xem để nội dung không nhảy khi đổi trạng thái.
- Mở rồi thoát sớm không xoá dấu. Chỉ đánh dấu cả cuộc đã đọc khi tin cuối hiện đủ, gồm phần cuối của tin dài. Chat ngắn đã hiện toàn bộ được tính đã đọc ngay khi xem.
- Thêm tin/ảnh/thông báo hệ thống mới bằng script tạo dấu lại. Tin Hải Quỳ tự gửi và kết quả lựa chọn không tạo unread.
- Cutscene chỉ tính một entry đã đọc sau khi mọi phần của nó đã nằm trong vùng xem. Đọc dở tin dài hoặc đóng trước khi xem thì phần đó vẫn báo mới khi lưu vào điện thoại.
- Trạng thái và nội dung chat thuộc bản lưu đang chơi. Save A/B độc lập; Game mới không kế thừa chat/unread từ lượt trước. Đọc rồi load lại bản chưa lưu thao tác đọc sẽ trở về trạng thái lúc lưu.
- Test Hub cài lịch sử checkpoint dưới dạng đã đọc; tin script thêm sau đó hoạt động bình thường.

Không làm migration save cũ, theo phạm vi đã thống nhất. Dùng **Game mới** để kiểm tra schema này.

## Lưu dữ liệu và API

`Game_Config` lưu contacts thường, chat nhóm, mã tin tăng dần và tập mã chưa đọc. Mã tin không dựa vào nội dung hoặc số lượng: thêm hai tin giống nhau vẫn là hai tin; thay lịch sử có cùng số entry vẫn nhận ra phần đã đổi. Mã chưa đọc được phân vùng theo `:normal`/`:group` và ID cuộc trò chuyện.

`PhoneMenu::CONTACTS` nay là registry tương thích các thao tác event hiện dùng (`[]=`, `[]`, `each`, `clear`...), trỏ tới `$game_config.phone_contacts`. Không còn một Hash message mutable dùng chung giữa các save. Group metadata cũng được copy từ template, tránh Test Hub hoặc save khác sửa template chung.

Các lệnh hiện có giữ nguyên cách gọi và tự cập nhật unread:

```ruby
PhoneMenu::CONTACTS[1] = ["Momo", "Má của Hải Quỳ.", []]
$game_config.add_message(1, "Con đang ở đâu vậy?")
$game_config.add_messages(1, [["Tin mới", :contact], ["Con đây", :main]])

PhoneGroupChatSave.add_text(:leo, "Quỳ ơi, có tin mới nè.")
PhoneGroupChatSave.add_image(:hakase, "CG22")
PhoneGroupChatSave.add_system("Leo đã vào nhóm")
```

Để thêm mới, dùng API trên thay vì tự `<<` vào mảng message. Mã nội bộ nằm ở phần tử thứ ba của message thường và key `:_phone_id` của message nhóm; không sửa mã này trong event.

`save_current_cutscene` đối chiếu prefix của lịch sử, giữ ID/read state cho phần không đổi và cấp ID mới cho suffix khác. Entry đã xem trong cutscene được nhập dưới dạng đã đọc. Lưu lại cùng transcript không làm tin cũ báo mới. Xoá chat rồi thêm lại cấp mã mới, không tái dùng mã đã đọc.

Khi UI tới cuối, chỉ clear tới ID cuối đã render; một tin mới đến sau mẫu render đó không bị xoá nhầm. Các badge theo revision của model; không dựng lại bitmap mỗi frame. Cutscene chỉ quét lại vùng đã xem khi số entry/scroll/kích thước vùng xem thay đổi.

Preview tin rất dài từng làm danh sách mở chậm vì ellipsis đo lại chuỗi sau mỗi lần bỏ một ký tự. Shared `phone_text` nay tìm prefix bằng tìm nhị phân theo grapheme, giữ dấu tiếng Việt và giảm số lần đo font.

## Kiểm tra

- `ruby tools/test_phone_unread.rb`: **45 case / 1.192 assertion**, gồm regression phone/layout/performance/cutscene và 12 ca unread. Có kiểm tra cô lập dữ liệu qua Marshal, nhận/gửi, watermark, re-import cùng lịch sử, đổi nội dung cùng độ dài, xoá/thêm lại, tin dài, đọc dở cutscene, template và idle không quét lặp. Preview chuỗi dài dùng tối đa 20 lần đo trong fixture.
- Phone animation/layout/performance: **32/802**; Save/Load: **29/758**; không failure/error.
- Native RGSS301 tại `Save/PhoneUnreadQA_20261116/native4`: **27 kiểm tra đạt**, ảnh trực tiếp từ `Graphics.snap_to_bitmap`. Đã thử dấu icon/list/message, mở rồi thoát, đọc thread khác, tin dài phần đầu/cuối, thêm lại, group image/system, cùng transcript/nội dung đổi, Test Hub, ghi hai save thật, Load A/B và Game mới.
- Native cutscene tại `Save/PhoneUnreadQA_20261116/cutscenes4`: **16 ca đạt**, gồm các preset/nhánh hiện có và ba ca đóng sớm. Entry xem đủ read; tin dài chưa hết unread; entry chưa mở unread. Các biến route và history vẫn đúng.
- Lượt tích hợp `Save/PhoneUnreadQA_20261116/prologue`: Title → Test Hub → Silverwing → hành lang → thành phố → chat → bus → Map022. Hoàn tất, brightness 255, group chat 52 entry đã đọc; 21 tin thường chưa xem vẫn chưa đọc. Không xoá nhầm unread của cuộc khác.
- Scope audit đối chiếu **78 file Data ngoài Scripts**, giữ nguyên hash; preset thoại/lựa chọn giữ nguyên. Inventory và semantic audit không lỗi.

```powershell
ruby tools/test_phone_unread.rb
ruby tools/test_phone_menu_animation.rb
ruby tools/test_phone_save_load.rb
ruby tools/audit_phone_unread_scope.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
```

Runner native cho UI/save:

```powershell
ruby tools/build_cutscene_phone_qa.rb Save/<run-moi> tools/qa_phone_unread_native.rb
```

Tạo junction Graphics/Audio/System của runner tới tài nguyên project rồi chạy Game.exe bản sao với working directory của runner. Cho cutscene, dùng harness mặc định của builder. Các runner chỉ thay pack bản sao, không chạy hoặc ghi save của project sản xuất. Đây là kiểm tra bằng lệnh và snapshot native; chưa phải điều khiển phím thật hoặc đo FPS laptop.
