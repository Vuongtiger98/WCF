# RGSS3 runtime pitfalls

Bổ sung ngày 30/10/2026: các lỗi sở hữu bitmap dùng chung của layer/particle, hàng đợi animation và lỗi ghép slot của công cụ export đã được ghi cùng bằng chứng kiểm tra tại [scripts/compatibility-audit.md](../scripts/compatibility-audit.md).

Tài liệu này ghi lại các lỗi đã thực sự xuất hiện trong dự án. Đây là checklist bắt buộc khi sửa script hình ảnh, camera, lighting và transfer; `ruby -c` chỉ kiểm tra cú pháp, không chứng minh API RGSS3 sẽ chạy được.

## 1. Không giả định mọi đối tượng đồ họa đều có `disposed?`

- `Sprite` và `Bitmap` có API kiểm tra trạng thái riêng, nhưng `Viewport` của RGSS3/VX Ace trong dự án không cung cấp `disposed?`.
- Lỗi đã gặp: `undefined method 'disposed?' for #<Viewport>` sau animation 147, do hiệu ứng vỡ vụn gọi `viewport.disposed?`.
- Với `Viewport`, chỉ giữ tham chiếu trong lúc scene còn hoạt động. Nếu cần bảo vệ lifecycle, thử đọc một thuộc tính vô hại như `viewport.rect` trong `begin/rescue`; không gọi API dựa trên phỏng đoán từ class khác.
- Luôn dispose `Sprite` tự tạo trong `ensure`, nhưng không dispose viewport do Spriteset sở hữu.

## 2. Transfer không đồng nghĩa tạo `Scene_Map` mới

- VX Ace có thể tái sử dụng cùng một `Scene_Map` khi chuyển map.
- Manager giữ `Game_Event`, `Viewport` hoặc `Sprite` phải phát hiện `map_id` thay đổi, dispose tài nguyên cũ rồi bind lại event/viewport mới.
- Không gọi phương thức trên viewport cũ sau transfer. Không để coroutine hiệu ứng tiếp tục chạy qua transfer.

## 3. Cắt atlas ngay khi tạo overlay

- Sau khi gán bitmap, `Sprite#src_rect` có thể vẫn bao phủ cả bitmap cho tới lần cập nhật đầu tiên.
- Overlay dùng charset/atlas custom phải đặt `src_rect` đúng một frame trước khi cho `visible = true`.
- Event thật và overlay không được cùng hiện trong một frame: ẩn event trước, chuẩn bị overlay, rồi mới hiện; lúc bàn giao thì ẩn overlay trước khi hiện event.
- `BubbleTag` của Pop Message là một `Sprite` không gắn viewport. `SceneManager.call` sang Group Chat không dispose `Window_Message` của Scene_Map, nên phải gọi `force_clear_pop_message_visuals` tại ranh giới `GroupChat.start`; chỉ chờ message đóng không bảo đảm mũi tên bị ẩn trước scene mới.
- Event command Show Animation chỉ theo dõi `Game_Character#animation_id`. Với cutscene chuẩn frame, cần xác nhận `Sprite_Character#animation?` đã bắt đầu và chờ sprite kết thúc. Map035 dùng `atlantis_event_teleport`: Paulie được đặt opacity 0 trước, rồi animation 116 phát tại vị trí cuối để thể hiện anh đã teleport và chỉ còn phép thuật lưu lại.

## 4. Ba hệ làm tối không thay thế lẫn nhau

- Transfer của `Scene_Map` dùng `Graphics.brightness`.
- Event `Fadeout/Fadein` dùng brightness của `Game_Screen`.
- KUL dùng `$game_map.shadows` và nguồn sáng gắn với character.
- Mỗi flow phải chọn đúng một hệ làm tối. Với flow KUL-only, không gọi Event Fadeout/Fadein hoặc Tint Screen: tăng KUL opacity lên `255` ở map nguồn, transfer `fade_type=2`, thiết lập KUL và nguồn sáng ở map đích khi overlay vẫn đen, rồi hạ KUL opacity để hiện cảnh.
- Không kéo KUL opacity về `0` ngay trước transfer; thao tác đó làm lộ một frame sáng. Map đích phải tự khai báo `[lighting on]`, opacity tối trong note hoặc thiết lập lại ngay ở autorun, không phụ thuộc trạng thái tình cờ kế thừa từ map nguồn.
- `Spriteset_Map_Effects` có viewport tổng hợp riêng và có lúc ẩn các map viewport gốc. KUL vẽ shadow/light trên viewport của map; vì vậy một scene yêu cầu KUL chính xác không được đồng thời chạy preset Map Effects tone/blur/zoom. Map025 clear trạng thái kế thừa, đặt `map_effects.active=false`, dùng Enhanced Camera trực tiếp và để KUL là hệ duy nhất điều khiển sáng/tối.

## 5. Nguồn sáng phải phù hợp với chuyển động

- Preset `small` gốc là static. Không dùng nó cho Player hoặc event còn nhảy/di chuyển.
- `actor_small` vẫn dùng texture 128×128 cho các scene nhỏ. Map025 dùng `cutscene_actor`: texture `light.png` 288×288, dynamic, không cast shadow và offset `[0,-15]` theo cả bốn hướng. KUL bám character tại chân nên offset âm nâng tâm sáng lên thân/mặt; `-15` là giới hạn an toàn được tài liệu KUL khuyến nghị.
- Map025 đặt Switch 17 và 18 về OFF khi bắt đầu: trong KUL, Switch 17 ON có nghĩa là bỏ qua `draw_lights`, còn Switch 18 ON có nghĩa là tắt toàn bộ ultra lighting. Đây là switch kiểu “disable”, không phải “enable”.
- Chỉ cấp light cho Paulie khi event thật xuất hiện lúc impact; cấp từ đầu khi event còn ẩn sẽ tạo một vùng sáng không có nhân vật.
- Dọn light của Player, quái vật và Paulie sau khi màn hình đã đen, trước transfer.

## 6. Checklist trước khi bàn giao

1. Chạy `ruby -c` cho file export.
2. Replace đúng slot trong `Data/Scripts.rvdata2` và chạy `diff-script` để xác nhận runtime khớp export.
3. Xác định một hệ lighting duy nhất cho cả flow. Với cutscene KUL-only: thiết lập KUL → đổi shadow opacity để hiện cảnh → chạy scene; đổi shadow opacity về `255` → cleanup → transfer `fade_type=2`. Không chèn Event Fade In/Fade Out, Tint Screen hoặc Common Event lighting vào giữa flow.
4. Playtest cả vào thẳng map và đi từ map trước đó, vì lifecycle hai trường hợp khác nhau.
5. Quan sát frame đầu/cuối của transfer, overlay bàn giao và lúc hiệu ứng dispose.
6. Dump event và tìm cả Common Event gián tiếp; một lệnh camera có thể đồng thời chứa Map Effects tone/color/blur dù map không có lệnh Tint Screen trực tiếp.
# Pop Message phải đo chữ giống cách RGSS3 vẽ chữ

`Window_Base#process_normal_character` không vẽ cả dòng một lần. Nó gọi
`text_size(c).width` cho từng ký tự, vẽ ký tự rồi tăng con trỏ theo độ rộng đó.
Vì vậy không được dùng `text_size(line).width` để tạo một cửa sổ ôm sát nội
dung: với Verdana và các ký tự tiếng Việt có dấu, độ rộng cả chuỗi có thể nhỏ
hơn tổng độ rộng các glyph được engine sử dụng khi vẽ, khiến cuối dòng bị cắt.

Pop Message hiện đo lần lượt từng ký tự, mô phỏng các escape code làm thay đổi
font/icon/vị trí và dành thêm biên cho glyph cuối. Khi sửa hệ thống message về
sau, phép đo kích thước và phép tăng `pos[:x]` phải luôn dùng cùng một quy tắc.

Ngoài ra, target `\bm[id]` được Pop Message giữ lại qua nhiều lệnh Show Text.
Không được chỉ gọi `adjust_window_size` khi gặp một tag `\bm` mới: khối Show
Text kế tiếp có thể cố ý kế thừa target nhưng dài hơn khối trước. Mỗi khi
`@pop_message_id` vẫn tồn tại và không có `\cbm`, cửa sổ phải đo lại toàn bộ
nội dung mới rồi mới cập nhật vị trí bubble.

## Pop Message không phải lúc nào cũng có cửa sổ face phụ

`Window_Message#close_and_wait` có thể chạy cho thoại thường `\cbm` ngay sau
free roam mà không đi qua nhánh tạo `Window_MessageFace`. Vì vậy mọi thao tác
đóng/ẩn cửa sổ phụ phải kiểm tra `@face_window` trước. Lỗi đã gặp là
`undefined method 'hide_face' for nil:NilClass` khi bắt đầu phần trao quà sau
free roam của route sách Shylvie. File export và slot runtime phải cùng giữ
guard `@face_window.hide_face if @face_window`.

## Override script load sau phải giữ đầy đủ side effect

RGSS3 dùng implementation được load cuối cùng khi nhiều script định nghĩa lại cùng một method. `Custom Menu` có patch lưu lịch sử lựa chọn và định nghĩa lại `Scene_SimplePhoneChat#apply_choice` sau `Cutscene Group Chat`. Patch cũ chỉ lưu text/result cho lịch sử nhưng bỏ mất xử lý `choice[:switch]` và `choice[:variable]`; vì vậy giao diện vẫn hiện và nhận lựa chọn trong khi Variable route không đổi.

Khi override một method điều khiển state, phải đối chiếu implementation gốc và giữ đủ mọi side effect, hoặc alias/gọi method gốc rồi chỉ bổ sung hành vi. Với lựa chọn Group Chat, implementation cuối phải cập nhật đồng thời `$game_temp.group_chat_result`, switch tùy chọn, variable tùy chọn và dữ liệu lưu lịch sử.
