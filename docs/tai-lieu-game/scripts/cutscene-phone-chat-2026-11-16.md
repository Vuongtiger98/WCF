# Đồng bộ chat cutscene với điện thoại — 16/11/2026

Chat cutscene dùng `Scene_SimplePhoneChat` riêng, nên bản sửa `Scene_Menu` trước đó chưa áp dụng cho màn này. Đã đồng bộ ở slot **197 Cutscene Group Chat** và **198 Custom Menu**, không thêm hoặc đổi thứ tự script.

## Giao diện và điều khiển

- Chung khung điện thoại 336×460, nền chat, overlay, Segoe UI/Arial, lề, thẻ tiêu đề, màu bong bóng, avatar và thẻ lựa chọn với lịch sử chat trong menu.
- Tách `WCFPhoneDrawing` để cả hai màn dùng cùng bộ vẽ, đo và wrap chữ. Giữ dấu tiếng Việt, từ dài và xuống dòng trống; cache wrap có giới hạn và phân biệt cỡ font.
- Mở/đóng trượt 30 frame, di chuyển các lớp cùng nhau, đặt từ tọa độ gốc để tránh sai lệch do Sprite RGSS làm tròn số nguyên. Nền map giữ cố định phía sau.
- Z hiện tin tiếp theo; ↑↓ xem lại. Tin dài bắt đầu từ đầu và Z đọc phần tiếp trước khi sang tin mới. X đóng khi kịch bản cho phép.
- Lựa chọn có vùng riêng và cuộn theo mục được chọn khi có nhiều đáp án. Không chồng lên vùng tin; choice bắt buộc vẫn chặn X trước khi trả lời.
- Layout từng entry được cache trong scene, tránh đo lại toàn bộ hội thoại cũ mỗi lần nhận một tin. Dispose chỉ hủy bitmap do scene sở hữu, giữ artwork trong Cache.

Không sửa text, người gửi, hình ảnh, đáp án hoặc điều kiện trong các preset. Model dữ liệu và API `Game_SimplePhoneChat`, `GroupChatPreset`, `PhoneGroupChatSave` giữ nguyên.

## Sửa cơ chế chờ của event

`SceneManager.call` chỉ yêu cầu đổi scene, không tự dừng Fiber của `Game_Interpreter`. Trước đây lệnh lưu lịch sử/đọc biến ngay sau lệnh mở chat có thể chạy khi người chơi chưa chọn đáp án. Lượt mở đầu cũ lưu 49 entry gốc, thiếu lựa chọn và hai tin của nhánh.

Wrapper `Game_Interpreter#command_355` trong Cutscene Group Chat nay yield khi scene chat còn mở. Khi quay về map, event tiếp tục với kết quả thật; lịch sử chat mở đầu có **52 entry** sau chọn nhánh đầu. Wrapper không đổi các loại script call khác, không thêm wait vào từng map. `GroupChat.start` chụp nền map hiện tại trước khi chuyển scene.

## Kiểm tra

Offline: `ruby tools/test_cutscene_phone_chat.rb` — **33 case / 1.154 assertion**, không failure/error; gồm layout/performance hiện có và tám case cutscene. Bộ phone animation **32/801**, Save/Load **29/758** vẫn đạt sau tách helper.

Native RGSS301/Ruby 1.9.2 tại `Save/CutsceneChatQA_20261116/native2`: **13 ca đạt**:

- Chat Giáng sinh có ảnh và lựa chọn; bốn người nhận quà siêu thị; ba cửa hàng Leo giới thiệu.
- Chat mì cay, lời mời tiệm đá, hậu truyện Atlantis; tin dài có dòng trống.
- Event dùng interpreter thật: lệnh sau chat chưa chạy khi chat còn hiện, rồi đọc đúng lựa chọn tiệm ma pháp và lưu đủ lịch sử khi quay lại.

Kiểm tra đúng tọa độ sau animation, vùng choice không che tin, biến 43/55/result/branch, X tại choice bắt buộc, transcript sau đóng, cleanup và Cache còn sống. Ảnh lấy trực tiếp bằng `Graphics.snap_to_bitmap`, đã mở kiểm tra: `01-conversation.png`, `01-image.png`, `04-choices.png`, `07-choices.png`, `11-long-page-1.png`. Không thao tác phím/chuột thật và không dùng kết quả này để đánh giá FPS.

Lượt tích hợp tại `Save/CutsceneChatQA_20261116/prologue`: Title → Test Hub → mở đầu Silverwing → hành lang → thành phố → chat mới → xe bus → Atlantis/Map022. Hoàn tất, KUL opacity 0, brightness 255; lịch sử có đủ 52 entry. Không chỉnh map/event, vị trí, graphic hay walk/step của tester.

```powershell
ruby tools/test_cutscene_phone_chat.rb
ruby tools/test_phone_menu_animation.rb
ruby tools/test_phone_save_load.rb
ruby tools/audit_cutscene_phone_scope.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
```

Backup: `Data/codex_backup_cutscene_chat_20261116/`. Audit riêng so sánh với mốc này, chỉ cho phép hai slot thay đổi, xác nhận CSV/map kiểm tra/model/preset giữ nguyên. Các audit scope của lượt prologue trước đó là mốc lịch sử trước thay đổi chat này.

Tạo runner mới: `ruby tools/build_cutscene_phone_qa.rb Save/<thư-mục-QA-mới>`. Tạo junction `Graphics`, `Audio`, `System` trong runner trỏ tới tài nguyên project, rồi chạy Game.exe bản sao với working directory của runner. Observer chỉ được chèn trước Main trong pack bản sao. Kết quả nằm ở `chat-native.log`, `completion.marshal` và `captures/`.
