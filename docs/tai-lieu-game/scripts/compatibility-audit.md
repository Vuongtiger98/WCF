# Rà lỗi và xung đột script — 30/10/2026

Đối chiếu 222 slot runtime, export, token Ruby và các method được định nghĩa lại. Nhiều script cùng chạm một method chỉ là điểm cần review; không tự động coi mọi alias chain là lỗi.

## Lỗi đã xác nhận và đã sửa

| Vị trí | Lỗi và điều kiện tái hiện | Sửa đổi |
|---|---|---|
| Galv Layer Graphics: `Layer_Graphic#dispose` | Plane hủy bitmap từ `Cache.layers`; nhiều layer dùng cùng file có thể cùng giữ bitmap đó | Plane bỏ tham chiếu và tự dispose, giữ bitmap cho cache/đối tượng khác; dispose lặp trở thành no-op |
| Galv Layer Graphics: `yoffset` | Offset dọc thay theo `display_x`; camera đi ngang có thể kéo lệch layer dọc | Dùng `display_y` |
| Galv Layer Graphics: `init_settings` | Đọc vị trí scroll đã lưu từ layer 0 của map hiện tại, trong khi `dispose` ghi vào scratch `$game_map.layers[0]` | Đọc đúng scratch để refresh không reset/đọc nhầm offset |
| Dekita Particles: `Particle_Core#dispose` | Hủy bitmap lấy từ `Cache.particle`, gây ảnh hưởng tới particle/weather khác dùng cùng ảnh | Chỉ dispose sprite, giữ bitmap cache và cho phép cleanup lặp an toàn |
| MOG Anti Animation Lag: queue cleanup | Queue có thể chứa bitmap trùng/đã hủy hoặc bitmap đã được animation mới mượn lại | Khử trùng, bỏ entry nil/đã dispose, kiểm tra reference count và giữ entry đang được dùng cho lần dọn sau |
| MOG Anti Animation Lag: `SceneManager.dispose_animation_garbage` | Scene cleanup trước New Game chưa có `$game_temp` có thể gọi method trên nil | Guard `$game_temp` trước khi đọc queue |
| Exporter KK20 | Runtime mode 0 nhưng file export mode 1; một lần import toàn bộ có thể tái bật export/thoát game | Export cũng đặt mode 0, không thay runtime importer vốn đã đúng |
| `rvdata2_audit.rb`: compare/diff script | Dùng vị trí CSV để chọn filename; CSV thiếu slot khiến report ghép sai script và báo thiếu giả | Chọn filename theo tên slot runtime; CSV được khớp lại riêng, không sort Script Editor |

Trong lượt 30/10, chỉ ba slot code runtime bị thay source: 138 `Galv's Layer Graphics`, 141 `anti-animation lag`, 189 `Particles`. Số slot, thứ tự, ID và tên giữ nguyên. Backup trước sửa tại `Data/codex_backup_scripts_review_20261030/Scripts.rvdata2`. Mọi thay đổi runtime có sẵn trước lượt review vẫn được giữ. Lượt 15/11 sửa thêm năm slot dùng chung, xem [báo cáo hiệu năng](performance-audit-2026-11-15.md).

## Chuỗi method đã đối chiếu

| Method | Thứ tự định nghĩa quan trọng | Kết luận |
|---|---|---|
| `Game_Player#update_scroll` | Stock → Lune 135 → Enhanced Camera 204 | Enhanced dùng nhánh riêng hoặc gọi alias Lune theo strength. Không loại Lune khi chưa kiểm tra cả fallback |
| `Game_Map#setup` | Stock → Galv Layers → Anti Animation Lag → Victor Fog → Galv Char → Yanfly Restrict → KUL Core → Terrain → Particles | Cleanup/setup lồng nhau; patch animation queue đã sửa. Transfer vẫn cần kiểm tra trong Game.exe |
| `Spriteset_Map#update_pictures` | Stock → Pictures under Characters 124 → Picture Bug 147 | Body Woratana bị bản load sau thay. Phần `Sprite_Picture#update` vẫn đổi viewport cho ID 30–35 |
| `Sprite_Picture#update` | Stock → Woratana 124 → Fixed Pictures 148 → Flip Pictures 174 | Fixed Pictures ghi Z và có thể chọn viewport sau Woratana. Cần chốt quyền ưu tiên nếu cùng dùng ID 30–35 và Z explicit; chưa đổi chính sách hiển thị |
| `Sprite_Base#dispose_animation` | Stock → Victor Animation 136 → MOG Anti Lag 141 | Phần cleanup tùy anti_lag_animation; đã thêm bảo vệ bitmap còn reference. Cần playtest animation đồng thời và transfer giữa animation |
| `Window_Message#update_placement` | Stock → Pop Message 203 | Phải giữ reset giữa bubble và khung thường, đo tiếng Việt và cleanup face/BubbleTag |
| `Scene_SimplePhoneChat#apply_choice` | Cutscene Group Chat 197 → Custom Menu 198 | Bản cuối đang gọi `commit_choice_side_effects`, giữ switch/variable/result cùng lịch sử chat; không phát hiện lại lỗi mất nhánh ở code hiện tại |
| `Scene_Map#update` | Stock → Event Popup → Text Over Event → Transform → Shrimp → Atlantis manager | Có nhiều hook cùng frame; ưu tiên kiểm tra manager rebind theo map_id và không cập nhật gameplay trong scene phụ |
| `Scene_Base#terminate` | Stock → Weather → Anti Lag → Particles → Title Logo | Particle không còn phá bitmap cache; queue animation không được hủy tài nguyên đang được dùng |

Nguồn chuỗi là AST của runtime (`ruby -W0 tools/script_inventory.rb overrides`). AST không giải thích đầy đủ `define_method`, `class_eval`, code eval động, alias gián tiếp hoặc điều kiện chạy; các kết luận trên còn dựa vào đọc body method.

## Những điểm giữ lại để playtest hoặc quyết định riêng

- **Viewport picture**: xác nhận ưu tiên picture ID 30–35 so với Variable 6/Fixed Pictures trước khi hợp nhất adapter. Chưa thay code vì cả hai có thể đang được scene dùng có chủ ý.
- **KUL và Map Effects**: KUL vẽ trên viewport map, Map Effects có viewport tổng hợp. Các shot có zoom/blur/tone cần test cả đèn, bubble và frame reveal. Không gỡ Map Effects vì nhiều cutscene đã dùng.
- **Fog chồng lớp**: Victor Fog, KUL Fog, Galv Layers và weather có thể đồng thời tạo lớp phủ; chỉ phát hiện lỗi thị giác khi một map thật bật nhiều hệ. Không tắt toàn bộ fog chỉ vì cùng chức năng.
- **Bộ nhớ cache**: bitmap layer/particle nay sống theo cache thay vì bị từng sprite hủy. Cần đo bộ nhớ khi chơi dài qua nhiều layer lớn; nếu cần giới hạn cache, phải dùng cơ chế theo dõi người mượn thay vì dispose cả cache khi vẫn còn đối tượng hiển thị.
- **Switch/Region**: vùng 3/4/19/98 và Variable 4/20 cần đối chiếu event sử dụng hiện tại trước khi gọi là xung đột đang xảy ra. Các ghi chú lịch sử chưa đủ để tự di chuyển ID.
- **Dekita dependency**: header nhắc D13x Core 2.5+ nhưng runtime không có slot riêng tên đó. Bản Particles hiện chứa code cốt lõi đang dùng; chưa có bằng chứng một constant thiếu gây crash nên không tự cài thêm một core lạ.
- **Âm thanh**: Yanfly System Options bọc `RPG::BGM/BGS/ME/SE#play`; không tìm thấy lý do để đổi RTP SE sang file tự tạo trong lượt này. Crash native phải tái hiện trong Game.exe, không kết luận từ phần mở rộng file.
- **Script đã tắt**: Theo Anti Lag, Galv Cam Slide/Region Effects, KUL menu addon và Disable key không tham gia code runtime. Không “sửa conflict” bằng cách xóa chúng hoặc bật trở lại.

## Bằng chứng kiểm tra

`tools/test_script_graphics_lifecycle.rb` lấy body class thật, dùng stand-in cho Bitmap/Sprite để kiểm tra ownership và offset. Cùng bảy case chạy trên source backup cũ cho 2 failure và 5 error; chạy trên source đã sửa cho **7 case, 18 assertion, 0 failure/error**.

Các case bao gồm layer dùng chung bitmap, particle dùng chung bitmap, offset Y khi camera X/Y khác nhau, refresh giữ offset, queue trước New Game, bitmap animation đang được mượn lại và queue chứa entry đã dispose.

```text
ruby tools/test_script_graphics_lifecycle.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb check-patch-scope
```

`check` kiểm tra parse, export và CSV; `check-patch-scope` hiện đối chiếu backup 30/10 để bảo đảm đúng tám slot source đổi sau cả hai lượt và toàn bộ identity/order giữ nguyên. `check-performance-scope` đối chiếu riêng backup 15/11, chỉ cho phép năm slot của lượt tối ưu. Khác CRLF/LF hoặc thụt lề trong comment không tính là khác logic; semantic audit hiện bằng 0.

Các audit route hiện có cũng chạy qua: cú pháp script trong các map đã review `errors=0`; KUL handoff 49 black transfer/148 entry page `failures=0`; mê cung, sáu page preparation và Test Hub đều `errors=0`.

Đây là kiểm tra offline, chưa phải chạy đồ họa/native trong VX Ace. Playtest còn cần: mở Title trước New Game; refresh layer đang hiện cùng ảnh; chuyển map/menu khi animation chạy; chuỗi KUL/CG; Pop Message → thoại thường → Group Chat; và mở lại save cũ. Native KGL/audio và bố cục camera không thể được chứng minh bằng các stand-in này.
