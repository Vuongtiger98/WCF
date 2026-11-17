# Cách dùng và dependency

Các API bên dưới đã có trong project. Kiểm tra target event/map hiện tại trước khi gọi; một ID event chỉ có ý nghĩa trong map chứa nó.

## Chuỗi phụ thuộc cần giữ

| Hệ thống | Thứ tự và điều kiện |
|---|---|
| Lighting | KUL Core → KUL Graphics Library → KUL Graphics → add-on; native `System/KGL2.klib` phải khớp bản library |
| Victor | Basic Module → Animations Settings/Fog; Anti Animation Lag load sau animation settings và phải giữ chain cleanup |
| Message | Yanfly Message → Actor Codes → Double Message → Pop Message; Group Chat/Custom Menu bổ sung scene điện thoại |
| Điện thoại | MOG Picture Gallery → Cutscene Group Chat → Custom Menu; registry/gallery/chat patch đã nằm trong Custom Menu |
| Particle | Particles → Particles Weather; MOG Title Particles là hệ riêng |
| Minigame | BulletHell → Random Event Patch; lớp/constant của base phải tồn tại trước addon |
| WCF | Manager Atlantis, Snowball, Storage Transition và Test Hub phải ở trước Main |

Không thay thứ tự chỉ vì script cùng sửa một method: cần xem alias, điều kiện và việc gọi bản gốc. Enhanced Camera có alias về Lune khi strength không kích hoạt Enhanced; đây là hành vi có chủ ý trong bản hiện tại.

## Ánh sáng và chuyển cảnh

```ruby
$game_player.give_light('maze_player_amber')
$game_player.drop_light
$game_map.shadows.show
$game_map.shadows.set_opacity(255, 30)
```

Lệnh fade theo frame không tự chặn interpreter: phải có Wait phù hợp trước transfer/reveal nếu scene yêu cầu chờ. Switch 17/18 là disable; bật chúng sẽ bỏ nguồn sáng/tắt ultra lighting. Room có parallax tô tối sẵn như preparation hoặc tiệm ma pháp không cần thêm lớp tối trong giai đoạn nhìn thấy.

`Game_Screen` fade, `Graphics.brightness` và KUL shadow là các hệ khác nhau. Chuỗi Map037 đã có native fade che CG kết hợp handoff KUL được audit; không áp quy tắc “chỉ một hệ” một cách máy móc để xóa các bước đồng bộ cần thiết.

## Layer

```ruby
layer($game_map.map_id, 2, ['Wanderer_Party_prepare', 0, 0, 255, 200, 0, 0, 0])
refresh_layers
del_layer($game_map.map_id, 2)
```

Tham số: file, tốc độ X/Y, opacity, Z, blend, offset X/Y. Layer mới trên map đang hiển thị cần refresh. Layer gắn với map và tiếp tục tồn tại cho tới khi thay/xóa. Bitmap từ Cache thuộc cache; plane không được hủy bitmap đó khi refresh.

Map024 dùng `falling_base` làm parallax. Các frame Hải Quỳ và `falling_path` là layer. Việc thay layer không được làm lộ sprite/parallax trong thời gian đang che màn hình.

## Camera, balloon và message

```ruby
ms_pro_cam_ignore_player(true)
ms_pro_cam_center_at(14, 21, 24)
ms_pro_cam_wait_for_scrolling
ms_pro_cam_ignore_player(false)
ms_pro_cam_focus_on(-1)
```

Đây là script call trong `Game_Interpreter`, không mặc nhiên là method public trên mọi class. Camera zoom từ Map Effects có viewport tổng hợp riêng; cần kiểm tra lại vị trí Pop Message/KUL khi phối hợp.

Pop Message dùng `\bm[id]`; `\cbm` quay về khung thường. Thoại thường sau bubble phải reset placement, face phụ và BubbleTag. Show Balloon dùng target `-1` player, `0` event đang chạy, số dương là event ID; controller vô hình không nên nhận balloon thay NPC.

## Di chuyển và tương tác

- `find_path(x,y)` là forced route theo tile; nếu đích không tới được và route có wait, cutscene có thể treo. Kiểm tra collision/priority trước khi thêm đường đi.
- `RegionStairs.enable`/`disable` quản lý cầu thang Region 63. Sau khi ra khỏi mode cần phục hồi through/speed cho player.
- Event Followers có `follow(id)` và `stop_follow`; không nhầm với follower party mặc định.
- Map058 dùng anchor cho NPC vẽ trên parallax và hitbox gọi vào cùng controller. Thay vị trí event không được tạo thêm bản sao chuỗi thoại.

## Điện thoại, Gallery và minigame

- `PhoneGroupChatSave.save_current_cutscene(:wanderer_group)` lưu chat sau cảnh.
- Dấu chưa đọc tự cập nhật khi thêm bằng `PhoneGroupChatSave.add_text/add_image/add_system` hoặc `$game_config.add_message/add_messages`; normal contact và unread đều thuộc save hiện tại. Xem [phone-unread-2026-11-16.md](phone-unread-2026-11-16.md). Không tự append thẳng vào mảng message.
- `WCFGalleryScene.show(id)`, `hide`, `hold(frames)` trình bày CG/vật phẩm và đồng bộ unlock.
- `WCF_SNOWBALL.start(event_id)` dùng `3` Shylvie, `4` Kohi, `5` Leo, `6` Hakase trên Map038.
- `WCFTestHub.prepare(key, overrides)` chuẩn bị checkpoint và điện thoại; event hub chịu trách nhiệm chọn branch và teleport.
- Common Event 20 nhận Item 18 và kiểm tra Diana. Cutscene threshold hiện chỉ chạy tại Map038; mở rộng RAM sang map khác cần giữ việc nhận item tách khỏi thời điểm gặp Diana.

## ID và tài nguyên cần tra trước khi sửa

State chuẩn nằm trong [registry](../systems/flags-and-variables.md), BGM nằm trong [audio-map.md](../systems/audio-map.md). Switch 98 của Fixed Pictures, Region 1 của reflection, Region 63 của cầu thang và Self Switch B của MOG sensor là các vùng phải kiểm tra trước khi tái sử dụng.

Âm lượng BGM/BGS/ME/SE được Yanfly System Options bọc ở `RPG::*#play`. Phát nhạc trực tiếp bằng `Audio.*` trong tính năng mới có thể bỏ qua tùy chọn âm lượng; ưu tiên wrapper hiện có và giữ phân loại BGM/SE đúng.
