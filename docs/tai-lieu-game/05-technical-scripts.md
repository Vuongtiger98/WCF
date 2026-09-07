# Technical Script Bible — RPG Maker VX Ace

Tài liệu này là bản tra cứu kỹ thuật cho các script đang có trong `Data/Scripts.rvdata2` và bản export tương ứng trong `Scripts/`. Runtime là nguồn quyết định; thư mục export chỉ dùng để đọc, review và chỉnh sửa có kiểm soát.

Checklist các lỗi runtime đặc thù RGSS3 và transfer/viewport được lưu tại [production/rgss3-runtime-pitfalls.md](production/rgss3-runtime-pitfalls.md). Phải kiểm tra checklist này khi thêm overlay, camera, lighting hoặc hiệu ứng tồn tại qua chuyển map.

## Quy ước quan trọng

- Script được thực thi theo thứ tự slot trong `Data/Scripts.rvdata2`. Các script có `alias`/định nghĩa lại class phụ thuộc thứ tự này.
- Switch và Variable là global của toàn game, không phải của từng map.
- Self Switch là theo từng event/map, không nằm trong bảng conflict global dưới đây.
- ID không được tự ý đổi khi chưa kiểm tra toàn bộ map/event/common event.
- Các số region/terrain bên dưới là cấu hình đã đọc từ code; những ID chưa được dùng trong map hiện tại vẫn phải xem như đã bị chiếm.

## Bảng ID cần giữ ổn định

### Switch

| ID | Chủ thể sử dụng | Ý nghĩa |
|---:|---|---|
| 1 | Galv Double Message | ON = khóa bỏ qua message |
| 3 | Map015 Smart Toilet; điều kiện page Map013 | Trạng thái biến hình toilet; đang xung đột global |
| 4 | KUL Fog Add-on; Map019 E33 | Bật/tắt fog |
| 17 | KUL Graphics | ON = tắt phần vẽ nguồn sáng (`draw_lights`); Map025 chủ động đặt OFF |
| 18 | KUL Graphics | ON = tắt toàn bộ ultra lighting; Map025 chủ động đặt OFF |
| 19 | KUL Item Lantern Add-on; Map019 E43 | Lantern; đang dùng trùng với logic map |
| 21 | Yanfly Flip Pictures | Cho phép/lệnh flip picture |
| 25 | Yanfly Gabwindow | ON = ẩn gab window |
| 94 | Galv Region Effects | ON = tắt region effects |
| 98 | Fixed Pictures | Khóa picture cố định và tọa độ; hiện đang dùng đồng thời cho hai mục đích cấu hình |
| 99 | Yanfly Event Popup | ON = ẩn popup event |
| 238 | Stop Movement | Khóa chuyển động NPC |
| 239 | Stop Movement | Khóa chuyển động player |

Ngoài các ID trên, Map data hiện dùng trực tiếp Switch 2, 5, 6, 7, 8; chúng thuộc logic event/map, không được tái sử dụng cho script hệ thống nếu chưa rà map.

### Variable

| ID | Chủ thể sử dụng | Ý nghĩa |
|---:|---|---|
| 4 | Transform Form Selection; Map008/Map013 | Form biến hình; đang bị map dùng chung |
| 6 | Fixed Pictures | Z-order của picture cố định |
| 19 | BulletHell | Điểm hiện tại |
| 20 | BulletHell; Map019 E4 | High score; đang xung đột với page condition map |
| 0 | Catto Petting Minigame cấu hình mặc định | Không ghi kết quả vì ID 0 bị vô hiệu hóa |
| 40 | Map001 E15 | Logic map hiện hữu |

Map data còn dùng Variable 1, 2 và 3 cho các event tại Map003/Map013. Không dùng các variable này cho hệ thống mới nếu không có bảng mapping cập nhật.

### Region, terrain tag và self switch

| Loại | ID | Script | Cách dùng |
|---|---:|---|---|
| Region | 1 | Pathfinder | Ví dụ vùng safe zone trong cấu hình pathfinding |
| Region | 1 | Galv Char Effect | Tường phản chiếu/mirror |
| Region | 1 | Stairs Movement | Không; stairs dùng Region 63 |
| Region | 63 | Stairs Movement | Ô cầu thang; `FORCE_REGION_PASSABLE = true` |
| Region | 1–255 | Terrain and Region Effects | Đọc từ note tag `<region N se>`/`</region se>` |
| Terrain | tileset-defined | Terrain and Region Effects | Đọc từ note tag `<terrain N se>`/`</terrain se>` |
| Self Switch B | — | Mog Event Sensor Range | Sensor event dùng self switch B |

KUL Graphics còn diễn giải region/height theo cấu hình riêng trong KUL Core Library. Cần kiểm tra trực tiếp các bảng region trên tileset trước khi tái sử dụng region 1 hoặc 63.

## Danh mục script và cách ứng dụng

### Hệ thống nền và dependency

- `Yanfly Core Engine`, `XS Core`, `victor module`, `Basic__Module`, `KUL Core Library`: thư viện nền. Không xóa hoặc đổi thứ tự nếu script phụ thuộc còn dùng.
- `Yanfly Message System`, `Yanfly Message System addon`, `Yanfly Adjust Limits`: message window, giới hạn dòng/kích thước.
- `Yanfly Menu Engine`, `Yanfly Save Engine`, `Yanfly System Option`, `Yanfly Window Icons`, `Yanfly Menu Cursor`: menu/save/system.
- `Victor Engine - Animations Settings`: cấu hình animation theo note/tag.
- `Easy Script Importer-Exporter`: công cụ export/import. Mode 1 chỉ dùng lúc export; trước khi chạy game phải chuyển về mode runtime.

### Map, camera và chuyển động

- `Enhanced Camera`: camera focus/scroll; Map015 gọi `ms_pro_cam_focus_on(-1)`.
- `Lune Smooth Camera Sliding`: camera trượt. `Galv's Cam Slide Control` hiện bị comment toàn bộ trong project nên không được tính là runtime conflict; chỉ xem xét lại nếu được bật.
- `Galv's Layer Graphics`: layer map bằng script call `layer(...)`, `refresh_layers`.
- `parallax lock yanfly`, `animated parallax`: khóa/chuyển động parallax.
- `Stairs Movement`: Region 63 là cầu thang; có script call bật/tắt `RegionStairs`.
- `Pathfinder`: pathfinding, có cấu hình safe region 1.
- `Dash Control`: điều khiển dash.
- `Stop Movement`: dùng Switch 238/239 để khóa NPC/player.
- `Yanfly Event Chase Player`, `Yanfly NPC Move Restrict`, `Yanfly Force Move Titles`, `Yanfly Slippery Titles`, `Followers`: AI/chuyển động event, follower và địa hình đặc biệt.
- `Mog Event sensor range`: sensor event, self switch B.

### Hình ảnh, picture và hiệu ứng

- `Fixed Pictures`: picture cố định; Switch 98, Variable 6.
- `Picture bug`, `Pictures under characters`, `Yanfly Flip Pictures`: viewport/Z-order/flip picture.
- `Galv Char effect`: phản chiếu theo Region 1.
- `Galv's Region Effects`: hiệu ứng theo region; Switch 94 để tắt.
- `Terrain and Region Effects`: âm thanh/hiệu ứng bước chân qua note tag terrain/region.
- `KUL Graphics`, `KUL Graphics Menu Add-on`, `KUL Item Lantern Add-on`, `KUL Fog Add-on`: lighting/fog/lantern; dùng Switch 17, 18, 19, 4.
- `victor fog`, `Map effects`, `Particles`, `Particles Weather`, `MOG_Weather_EX`, `anti-animation lag`: fog, weather, particle và tối ưu animation.
- `The Art of Screenshake`: script call `shake_screen(duration, power)`.
- `Map Screenshot`: công cụ chụp/debug map, có thể hiển thị region/passage.
- `HP Bar Over Player`, `Text Over Event`: thông tin hiển thị trên map.

### Title screen và easter egg Hải Quỳ

- `MOG_T_Logo` đã được chỉnh để `Salt_Pebbles` bay từ ngoài mép trái vào giữa màn hình trong 60 frame, giảm tốc ở cuối, phát SE tạm `cute-squeak-1`, dừng 45 frame rồi fade 20 frame; sau đó mới chạy `Logo_0`, `Logo_1`, ...
- `MOG_T_Name` luôn vẽ foreground `Graphics/Titles1/Title name.png` ở tâm màn hình; không phụ thuộc tùy chọn Draw Game Title và không còn dùng background `WCF title` trong Database.
- Nếu thư mục game có `HaiQuy.txt`, mỗi lần tạo Scene Title sẽ chọn ngẫu nhiên `Title_Screen_1` hoặc `Title_Screen_2`.
- Nếu không có `HaiQuy.txt`, title luân phiên `Title_Screen_3` và `Title_Screen_4`; cứ 180 frame bắt đầu một transition glitch dài 24 frame.
- Sau ending, `HAIQUY_TITLE.set_ending_background(filename)` tạm ưu tiên ảnh trong `Graphics/Gallery` làm nền Title của phiên hiện tại. Route rượt đuổi dùng `EDRuotDuoi`; khởi động lại game vẫn quay về quy tắc title easter/glitch bình thường.
- Nội dung chuẩn của file easter egg là `Anizoa Drosallie  Hexacoral  Dahria  Actini`.
- Script Call bật easter egg: `HAIQUY_TITLE.create_easter_egg`.
- Script Call tắt easter egg: `HAIQUY_TITLE.delete_easter_egg`.
- Việc tạo/xóa file chỉ ảnh hưởng lần tạo Scene Title kế tiếp. Nếu gọi trong game và muốn thấy ngay, sau đó dùng `SceneManager.goto(Scene_Title)`.

### Menu điện thoại và minigame

- `MOG_Picture_Gallery`: gallery nền tảng; script call `picture_gallery`, `enable_picture(id)`, `disable_picture(id)`.
- `Cutscene Group Chat`: chat trong cutscene, choice và branch.
- `Custom Menu`: menu điện thoại, Contacts, Gallery, item/save/load/system.
- `Custom Menu` có `PhoneTimeline`: widget ngày/giờ/pin được lưu theo save và chỉ tiến về phía trước qua Common Event 12–18. CE18 là mốc hội tụ trao quà ngày 25/12 lúc 19:00.
- `Custom Menu` hiện đã tích hợp Gallery Upgrade và Saved Group Chat Patch. Không thêm lại hai patch cũ vào slot riêng.
- Gallery unlock toàn cục lưu tại `Save/GlobalGallery.rvdata2`.
- Gallery ID 1–81 dùng registry trong `Custom Menu`. CG/vật phẩm được nạp thẳng từ `Graphics/Pictures`, còn ending art tiếp tục nạp từ `Graphics/Gallery`; không cần giữ hai bản bitmap giống nhau. `WCFGalleryScene.show(id)` hiện ảnh và unlock, `hide` xóa ảnh, `hold(frames)` dùng cho nhịp trình bày không có Show Text. Danh sách ID/scene nằm trong `docs/gallery-assets.md`.
- Group chat lưu trong `$game_config.phone_group_chats`; các API chính gồm `PhoneGroupChatSave.add_text`, `add_image`, `add_system`, `add_choice_result`, `save_current_cutscene`.
- `WCFEventNotice` dùng cửa sổ của `Yanfly Event Popup` để báo `Đã unlock CG` khi `GlobalGallery.unlock(id)` thực sự đổi từ khóa sang mở, và `Đã nhận tin nhắn mới` khi `PhoneGroupChatSave` thêm/lưu nội dung. Thông báo phát sinh ngoài Scene_Map được queue tới lúc quay lại map; các thông báo giống nhau trong 20 frame được gộp. Switch 99 ON vẫn ẩn toàn bộ popup theo cấu hình gốc.
- `BulletHell`: minigame danmaku; Variable 19 điểm hiện tại, Variable 20 high score.
- Các mốc tăng spawn, enemy cap và tỉ lệ loại enemy dùng `@game_time` của riêng lượt chơi; không dùng `Graphics.frame_count`, vì bộ đếm toàn cục này không reset khi chọn chơi lại.
- `Random Event Patch`: addon của BulletHell, chạy event định kỳ gồm Firework Line, Spiral Fan Boss, Coffee Drop, Tsunami, Slash Trap và Gravity Well.
- Gravity Well có bốn pha: cảnh báo 90 frame; hút Player theo lực radial tăng phi tuyến và tạo vật thể quỹ đạo trong 720 frame; gom toàn bộ vật thể vào lõi trong 150 frame đồng thời chuyển lõi dần sang đỏ; sau đó phóng chúng ra và collapse trong 90 frame kèm vòng đạn cuối. Vật thể được rải trên nhiều bán kính từ gần lõi tới giao điểm với mép màn hình, luân phiên quay thuận/ngược chiều và sinh mỗi 7 frame để tránh vùng đứng yên an toàn. Mỗi vật thể thứ tư dùng sprite alien xoay tròn nhưng vẫn được xử lý như projectile: chạm Player gây damage, không có HP và không tham gia điều kiện wave. `FORCE_EVENT_ID = 0` nên hệ thống đang dùng weight bình thường; đặt thành `6` khi cần ép Gravity Well để test.
- Death-state BulletHell đã được khóa cứng: sau khi chết, projectile/orbit/pickup ngừng collision và bị dọn; `destroy_player` không thể chạy lặp. `Z/Enter` chơi lại sau khi game-over hiện đủ, `A` thoát về map kể cả khi ảnh game-over đang fade.
- Khi chuẩn bị random event, chỉ `update_event_preparation` được phép điều khiển enemy retreat; không gọi pattern movement, tránh `anchor_hover`/`orbit_anchor` kéo enemy về anchor.
- Trong Firework Line, kẻ phản đòn dùng `event_center_x` làm tọa độ bám Player độc lập với pattern di chuyển thường; nó có thể đi tới hai mép theo nửa chiều rộng sprite, và lần sync sau base update chỉ khôi phục vị trí chứ không di chuyển thêm lần hai.
- Slash Trap dùng `Sprite_Player#hitbox_x/#hitbox_y` thay cho sprite origin và cộng bán kính hitbox vào phép thử đoạn thẳng, nên vùng gây damage khớp hiệu ứng chém ở cả focus và normal mode.
- `Catto Petting Minigame`: minigame petting; `RESULT_VARIABLE_ID = 0` nghĩa là hiện không ghi điểm ra Variable.
- `Transform Form Selection`: ghi form vào Variable 4.

## Nhóm script có khả năng conflict

### Camera — cần quyết định một script làm chủ

`Lune Smooth Camera Sliding`, `Galv Cam Slide Control` và `Enhanced Camera` đều chạm vào update/scroll camera. Map015 đang phụ thuộc Enhanced Camera. Không nên sửa tự động lúc này vì cần xác định camera nào được dùng ở từng route; khuyến nghị giữ Enhanced Camera làm camera chính và chỉ bật slide của Galv nếu đã kiểm tra alias chain.

### Message/UI — cần test thứ tự load

`Yanfly Message System`, addon, `Galv Double Message`, `Pop Message`, `Yanfly Gabwindow` và Group Chat đều sửa message/input/window. Không phát hiện lỗi cấu hình tĩnh mới sau lần hợp nhất menu điện thoại; cần test message thường, message skip, gab window và chat choice riêng.

### Balloon cảm xúc

Project dùng hai sheet `Graphics/System/Balloon1.png` và `Balloon2.png` thay cho `Balloon.png` mặc định. Runtime `Sprite_Character` ánh xạ ID 1–10 vào mười hàng của `Balloon1`, ID 11–20 vào mười hàng của `Balloon2`. Route Atlantis hiện ưu tiên các ID: 1 ngạc nhiên, 2 nghi vấn, 5 tức giận, 6 ngượng/căng thẳng, 8 im lặng, 9 nảy ý, 10 ngủ. Trong minigame ném tuyết, phản ứng tích cực dùng ID 12 (hàng 2 của `Balloon2`) thay cho balloon bóng đèn; ID 11 vẫn dùng cho sốc/va chạm.

Event command vẫn là Show Balloon chuẩn của VX Ace (`213`): target `-1` là Player, `0` là event đang chạy, số dương là event ID trên map. Với scene controller, phải trỏ đúng ID NPC thay vì `0`, vì `0` sẽ đặt balloon trên controller vô hình.

### WCF Snowball Rhythm

- `WCF Snowball Rhythm` là minigame rhythm tùy chọn tại giai đoạn khám phá tự do của Map038. Gọi bằng `WCF_SNOWBALL.start(EVENT_ID)`, trong đó `3` Shylvie, `4` Kohi, `5` Leo và `6` Hakase.
- Minigame dùng đồng hồ frame nội bộ; BGM RTP `Battle1` chỉ làm nền và không quyết định timing. Trong pha phòng thủ, đối thủ ném từng quả cầu tuyết có ký hiệu `← ↓ ↑ →` về phía Hải Quỳ.
- Chỉ có hai kết quả: bấm đúng hướng trong cửa sổ timing nhận `Perfect`, không mất máu và hất tuyết đi; bấm sai, quá sớm hoặc không bấm là `Miss` và mất nhiều HP. Chữ phán định nổi trực tiếp cạnh Hải Quỳ.
- Quả tuyết của đối thủ không xoay để ký hiệu hướng luôn đọc được. Mỗi người có nhịp riêng: Shylvie ném ổn định và buộc nhập chuỗi dài hơn; Kohi hay tung loạt 3–4 quả và cho ít thời gian phản công; Leo ném thấp, nhanh với chuỗi phím đổi ngang/dọc; Hakase đổi mạnh kích thước, quỹ đạo và dùng chuỗi đối xứng. Quả bị hất văng và quả Hải Quỳ ném trả vẫn có thể xoay.
- Input sai/quá sớm hiện `Miss` cạnh Hải Quỳ ngay lập tức rồi tăng tốc projectile; quả tuyết vẫn hoàn thành quỹ đạo, chạm người và vỡ thành các hạt tuyết. Khi còn HP, tuyết chỉ tích thành ụ thấp quanh chân.
- Khi Hải Quỳ hết HP, đối thủ dùng finisher ném liên tục một trận tuyết để vùi cô thành người tuyết hoàn chỉnh. Khi đối thủ hết HP, Hải Quỳ lướt ra sau lưng với chuỗi bóng mờ xanh được giữ lại trong lúc dừng hình; camera zoom vào hai nhân vật, chữ hoạt hình `SMASH!!` bật lên cùng flash, camera zoom ra rồi đối thủ lộn vòng bay chéo lên góc trái màn hình. Sau khi animation kết liễu hoàn tất, scene lần lượt hiện `FATALITY` và `HẢI QUỲ WINS` hoặc `[TÊN ĐỐI THỦ] WINS`, rồi mới chuyển sang màn hình kết quả.
- Scene tự đọc `Balloon1/2`: đối thủ báo hiệu chuẩn bị ném, Hải Quỳ phản ứng với Perfect/Miss/phản công, và đối thủ phản ứng khác nhau khi trúng quả Good/Perfect hoặc khi bước vào finisher. Đối thủ đồng thời có pose lấy đà khi ném và pose bật lùi/nghiêng người theo lực của cú ném trúng.
- Phase phản công dùng cơ chế riêng theo đối thủ. Chỉ Kohi dùng giao diện chuỗi phím kiểu Audition: hoàn thành toàn bộ nhận `Perfect`, đạt ít nhất 50% nhận `Good`, dưới 50% nhận `Miss`. Shylvie dùng phản cầu liên tục, Leo dùng QTE né nhát chém không gian, còn Hakase dùng cơ chế giữ phím để đấu lực ma thuật.
- Trận kết thúc khi một bên hết HP hoặc người chơi bấm `X/Esc`. Kết quả gần nhất ghi Variable 45 và Scene trả về Map038; BGM trước trận được phát lại. Mỗi chiến thắng được ghi vào bitmask Variable 46; khi đủ Shylvie/Kohi/Leo/Hakase (`15`), Switch 49 tự bật để event phần thưởng kiểm tra. Script call hỗ trợ `WCF_SNOWBALL.defeated?(ID)` và `WCF_SNOWBALL.all_cleared?`.
- Graphic hiện tại chỉ hỗ trợ pose prototype bằng offset/scale sprite. Animation né hoàn chỉnh cần spritesheet riêng trong giai đoạn polish.

### Picture/layer/parallax — rủi ro Z-order

`Atlantis Mirror Maze Chase` xử lý `Graphics/Characters/Monster1.png` và `Monster.png` như atlas custom 4×7, frame 298×313. Không gán hai ảnh trực tiếp làm graphic event vì VX Ace sẽ cắt sai theo charset 3×4/12×8. Map034/029/025 dùng E002 làm anchor trống; overlay lấy tọa độ màn hình, opacity và transparent từ anchor. Trong chase, camera lấy `Game_Player#real_x/real_y`; E002 nhận chính tọa độ nội suy đó với offset bốn tile phía trên. Không dùng proxy, không `moveto` mỗi frame và không chạy Player/quái vật bằng hai timer độc lập. `Monster1` loop 6 frame cho chase; `Monster` phát 26 frame một lần khi gọi `atlantis_monster_mode(2, :bound)`. Map029 loop dọc và manager tự chạy Player theo hướng 2.

Lưu ý lifecycle: VX Ace transfer giữa các map mà không tạo lại `Scene_Map`. Script theo dõi thay đổi `$game_map.map_id`, dispose manager cũ và bind lại các `Game_Event` sau transfer. Nếu bỏ bước này, vào thẳng Map029 vẫn đúng nhưng Map034 → Map029 sẽ tiếp tục vẽ E002 cũ của Map034 trong khi chase điều khiển E002 mới.

Map029 → Map025 giữ `fade_type=0` của transfer engine. Không trộn `Scene_Map#fadeout` (`Graphics.brightness`) với event Fade In (`Game_Screen#brightness`) vì hai hệ brightness khác nhau. E003 Map025 để graphic rỗng từ dữ liệu và chỉ nhận `$OniOnii_landing` trong `atlantis_paulie_high_drop`, nên Spriteset không thể làm lộ Paulie trước autorun.

`Pop Message` đã được vá để lưu ID của `\bm[id]` và cập nhật vị trí cửa sổ/bubble tag mỗi frame. Anchor ưu tiên `Sprite_Character` thực tế nên đi theo move route, jump và zoom của character effect. Vì `Window_Message` không thuộc viewport map, tọa độ sprite phải đổi sang tọa độ màn hình bằng `viewport.rect - viewport.ox/oy`; thiếu bước này làm bubble lệch đúng bằng camera/viewport offset. Đối với atlas custom `Monster/Monster1`, `AtlantisMonsterDisplay` cung cấp riêng screen-X, baseline và top-Y đã quy đổi của overlay; không dùng chiều cao graphic rỗng của E002. Khi sprite sát mép trên, nhánh chuyển hộp thoại xuống dưới cũng dùng baseline overlay này.

`Fixed Pictures`, `Pictures under characters`, `Yanfly Flip Pictures`, `Galv Layer Graphics`, parallax scripts và weather scripts cùng tác động viewport/Sprite/Picture. Không nên gộp thêm code. Cần kiểm thử map có `Bathroom_top`, picture fixed và nhân vật đứng dưới picture cùng lúc.

### Movement — rủi ro alias chain

`Stairs Movement`, `Pathfinder`, `Dash Control`, `Stop Movement`, `Yanfly Chase/Restrict`, `Followers` cùng sửa `Game_Character`/`Game_Player`. Không phát hiện một constant bị trùng trực tiếp, nhưng thứ tự load là hành vi. Cần test stairs, dash, follower, chase và Switch 238/239.

### Menu/save — đã có một điểm cần giữ nguyên

Custom Menu, Yanfly Save Engine, Gallery và Group Chat đều chạm DataManager/save. Phiên bản hiện tại đã hợp nhất đúng thứ tự: Cutscene Group Chat trước, Custom Menu sau. Không thêm patch cũ vào runtime. Khi test cần tạo save mới, load save cũ và kiểm tra `GlobalGallery.rvdata2`.

### Fog/weather/graphics — chưa sửa tự động

KUL, Victor Fog, MOG Weather, Particles và Map Effects cùng tạo/dispose sprite trong Spriteset_Map. Chưa có bằng chứng đủ để chọn một implementation và xóa implementation khác; chỉ nên sửa sau khi có map cụ thể bị lỗi hoặc log FPS/dispose.

## Lỗi cấu hình và khuyến nghị

### Ưu tiên cao

1. Đổi Smart Toilet khỏi Switch 3 hoặc đổi các page Map013 sang một switch riêng. Không dùng chung hai ý nghĩa global.
2. Đổi Variable 4 cho Transform Form Selection sang variable chuyên dụng chưa dùng trong map; cập nhật event gọi form nếu có.
3. Đổi `BulletHell::HIGH_SCORE_VAR` khỏi Variable 20 hoặc đổi điều kiện Map019 E4.
4. Tách `Fixed Pictures::SWITCH_ID` và `COORDINATES_SWITCH_ID` nếu hai chức năng cần bật độc lập.

### Ưu tiên trung bình

5. Đổi `Catto Petting Minigame::RESULT_VARIABLE_ID` từ 0 sang variable chuyên dụng nếu game cần lưu điểm.
6. Đặt tên trong Database cho các variable/switch hệ thống để tránh tái sử dụng nhầm.
7. Ghi một bảng registry ID mới trước khi thêm script hoặc route mới.

### Vận hành

8. Sau mỗi lần export, kiểm tra mode của Easy Script Importer-Exporter trước khi chạy game.
9. Không di chuyển script có alias nếu chưa kiểm tra script đứng trước/sau nó.
10. Mỗi thay đổi menu/save phải test cả save mới và save cũ.

## Kết quả kiểm tra hiện tại

- Runtime và export khớp về nội dung với các khác biệt tab/khoảng trắng đã biết ở Fixed Pictures và Yanfly Event Chase Player; Easy Script Importer-Exporter khác mode có chủ ý (runtime 0, bản export 1).
- Custom Menu đã được hợp nhất và sửa animation; không còn hai patch điện thoại riêng trong runtime.
- Không thấy conflict mới đủ chắc chắn để tự động sửa ngoài các lỗi cấu hình ID đã liệt kê.
- Các nhóm camera, message, picture, movement và graphics cần playtest theo map/route cụ thể trước khi thay đổi hành vi.

## Quy trình thêm script mới

1. Chọn slot sau dependency mà script cần.
2. Đăng ký mọi switch, variable, region, terrain tag, self switch và script call vào bảng registry.
3. Tìm class/method bị `alias` hoặc định nghĩa lại.
4. Kiểm tra save compatibility nếu script thêm field vào Game_System/Game_Config/DataManager.
5. Test map tối thiểu, test load save cũ, rồi mới export bản phát hành.
