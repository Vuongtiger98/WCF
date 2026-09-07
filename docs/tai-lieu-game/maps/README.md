# Map implementation audit

| Map | Tên | Kích thước | Events | Đối chiếu kế hoạch |
|---:|---|---:|---:|---|
| 3 | Văn phòng Silverwing | 22×23 | 65 | Mở đầu/hub |
| 6 | Thành phố | 110×32 | 7 | Kết nối khu mua sắm |
| 10 | Trong xe bus | 28×22 | 2 | Transit |
| 13 | Văn phòng Wanderer | 45×43 | 90 | Hỏi Leo/Shylvie; cửa phòng họp/chế tạo |
| 14 | Bếp | 45×43 | 25 | Route mì cay; E025 là cutscene nấu ăn riêng |
| 15 | Phòng tắm | 26×22 | 18 | Exploration; đã xác nhận nội dung |
| 17 | Hành lang Silverwing | 22×36 | 2 | Kết nối/lore |
| 19 | Siêu thị | 50×50 | 45 | Route quà chính; E045 là montage nguyên liệu mì cay |
| 20 | Quán mì cay | 35×30 | 1 | Tile map `MyCay`; lựa chọn Tin tưởng/Có cái nịt |
| 21 | Điểm xuống Atlantis | 17×13 | 1 | Route gate Atlantis |
| 22 | Nhà Hải Quỳ — bản thử | 22×43 | 48 | Nhà riêng; khám phá, chìa khóa, pha mì |
| 23 | Tiệm sách phép Atlantis | 30×40 | 54 | `Old_Book_Shop_Base/Top`; cảnh đến tiệm và toàn bộ tương tác đã dựng |
| 24 | Ký ức bãi rác | 20×14 | 1 | Mở đầu cảnh dí sau khi đọc thư |
| 25 | Atlantis — Đối đầu Vực Sâu | 17×13 | 3 | Cảnh số 5: Dahria, Oni Onii và đòn kết liễu; visual placeholder |
| 26 | Phòng kho nhà Hải Quỳ | 17×13 | 13 | `Storage_Base/Top`; băng, nhật ký, lá thư |
| 28 | Mê cung gương Atlantis | 31×25 | 11 | Dungeon RTP; Khas `player_small`, 5 gương, 4 scare |
| 29 | Hành lang truy đuổi Atlantis | 20×40 | 13 | Map loop dọc; endless-runner QTE tối thiểu 60 giây, 11 clone |
| 34 | Atlantis — Vòng vây bản thể | 40×15 | 13 | Cutscene 11 clone đúng V2, nối Map28 → Map34 → Map29 |
| 35 | Phòng Hải Quỳ — Đêm muộn | 21×17 | 3 | Epilogue route rượt đuổi; Group Chat và mở khóa ending CG |
| 36 | After Ending Hint | 17×13 | 2 | Hub hint dùng chung; Variable 41 chọn nội dung route |
| 41 | Phòng Hải Quỳ ở nhà | 21×17 | 17 | `HQ_Room_Morning_Base/Top`; khám phá nối từ cầu thang Map022; compact B3331–B3376 |
| 42 | Phòng Hải Quỳ — Wanderer | 20×14 | 14 | `HQ_Room_Normal`; compact B3236–B3258 |
| 43 | Phòng Shylvie | 20×18 | 23 | `CV_Room_Lightoff/Lighton_Base`; compact B3536–B3557 |
| 44 | Phòng Leo | 17×17 | 20 | `Leo_Room_Base`; compact B3495–B3516 |
| 45 | Phòng Hakase | 17×17 | 17 | `MystRoom_Base`; compact B3377–B3401 |
| 46 | Phòng Kohi | 17×18 | 13 | `Kohi_Room_Base`; compact B3517–B3535 |
| 47 | Phòng Hải Quỳ — Chuẩn bị mì cay | 21×17 | 2 | Hai nhánh chuẩn bị/ngủ; `HQ_Room_Midnight_Base/Top` |
| 48 | Wanderer Office — Tiệc mì cay | 45×43 | 8 | Donor/rollback; có cửa phòng họp/chế tạo |
| 49 | Phòng Hải Quỳ — Sách tặng Shylvie | 21×17 | 2 | Chuẩn bị quà/ngủ/thay đồ; compact B3033–B3043 |
| 50 | Hậu truyện — Sách dịch chuyển Shylvie | 45×43 | 16 | Hậu truyện phép hoán đổi; compact B3131–B3149 |
| 51 | Phòng Hải Quỳ — Sách tặng Hakase | 21×17 | 2 | Chuẩn bị quà/ngủ/thay đồ; dùng shell KUL ổn định của Map049 |
| 52 | Hậu truyện — Ma Vương Cổ Đại Hakase | 45×43 | 16 | Hakase hấp thụ ma lực Ma Vương; compact B3110–B3130 |
| 54 | Wanderer Office — Tìm Hải Quỳ | 45×43 | 7 | Search cutscene; có cửa phòng họp/chế tạo |
| 61 | Phòng họp | 36×25 | 2 | `Meeting_Room_Base`; dùng chung bởi office thường |
| 62 | Phòng họp — Movie Night | 36×25 | 2 | `Meeting Room_MovieNight_base`; dùng chung bởi office Giáng sinh |
| 63 | Phòng chế tạo | 34×24 | 61 | `Crafting_Room_Base`; 44 nhóm tương tác compact B2540–B2584 |

Map001/002/004/005/007/008/009/011/012/016/018 có event generic hoặc đang là map phụ/tạm. Map013 và Map019 vẫn còn nhiều event tên `EVxxx`, nên cần dựa vào event đã đặt tên khi trace route.

## Route mì cay cho Leo

- Map010 có lựa chọn thứ tư `Mua mì cay`, bật Switch 55 rồi chuyển đen sang Map020.
- Map020 dùng tile map gốc 35×30; không ép `MyCay.png` thành parallax. Hai lựa chọn ghi Variable 50: `1` Aira, `2` Hải Quỳ.
- Nhánh Aira qua E045 Map019 dưới dạng montage không tương tác; nhánh Hải Quỳ đi thẳng Map047. Cả hai không ghi Variable 42–44 và không kích hoạt checkout siêu thị.
- Map047 dùng Group Chat cố định Leo, chuẩn bị Sting, ngủ và CG11–CG14; Map014 E025 dùng animation 151/59 làm demo nấu ăn rồi hiện `Mibullyquy` hoặc `Mihaiquy`. E025 bật Self Switch A trước khi sang Map038, tránh phát lại nếu người chơi quay vào bếp trong free roam.
- Map038 E001 có page riêng cho phần mở đầu route mì cay, sau đó mở free roam và bốn trận ném tuyết giống các route quà. Page riêng của Leo tiếp tục bằng E118, chứa CG6/CG7, CG19, CG22–CG24, hình vật phẩm và placeholder một dòng `[ẢNH BÌNH STING 20 LÍT]`.
- Map048 giữ nguyên làm nguồn đối chiếu/rollback cho cutscene; không còn map nào transfer vào Map048.
- Sau cuộc gọi Silver Wing, route chuyển thẳng Map036 với `ENDING_HINT_ID = 18`; không có epilogue sáng hôm sau.

## Map003 — Văn phòng Silver Wing

- 22×23, 65 event.
- Event 1 khởi tạo Contacts điện thoại: Momo, Popo, OniiOni-chan, Hoàng Hà và Ánh Lam. Đây là dữ liệu runtime, không phải route flag.
- Event 2 tạo layer `MapVanPhong_top` bằng Galv Layer Graphics rồi tự tắt Self Switch A.
- Event 3 là cutscene công sở: khóa camera, focus nhiều tọa độ, zoom 130%, thoại Alpha C-61/Beta M-34/Hải Quỳ và chuyển giao hồ sơ Vực Sâu 61. Có dùng `find_path(4,4)`, Enhanced Camera và `map_effects`.
- Event 18 là event song song theo Variable 1; focus `(13,3)`, zoom 130% và movement route gây gag “chạm cỏ”.
- Event 22 có thoại Alpha/Beta/Hải Quỳ và Self Switch A.
- Event 25 điều khiển Switch 2.
- Event 62/63 có choice `Xong rồi/Chưa xong`, transfer/movement route tới Map006 hoặc Map017.
- Event 64 đọc Variable 1, focus `(1,12)` và route bad ending với sprite `!$Bad_End2`.
- Event 65 là điểm tương tác phụ tại `(4,10)`.

Map003 đã có nội dung phù hợp với hub Silver Wing và POV Hải Quỳ, nhưng chưa đủ scene ID/flag để nối chắc chắn với timeline. Không nên thêm route Atlantis vào map này trước khi đặt tên các event chính.

## Map010 — Trong xe bus

- 28×22, 2 event.
- E001 `BUS BUMP EFFECT`: touch effect, gọi `shake_screen(45, 10)`.
- E002 `SCN-BUS-001 CHRISTMAS GIFT PLAN`: autorun, tạo layer `xebuyt_top1`, reset camera/zoom, kể phần Hải Quỳ suy nghĩ về quà Giáng sinh.
- Choice cuối: `Tới siêu thị` → Map019 `(26,35)`; `Tới văn phòng Wanderer` → Map013 `(4,4)`.
- Có nhiều `shake_screen` tạo nhịp xe bus; cần kiểm tra Common Event camera reset nếu bus được gọi lại sau cutscene khác.

## Map013 — Văn phòng Wanderer (đã review)

- 45×43, 88 event; đây là hub Wanderer được mở từ Map010.
- Event khởi tạo tạo hai layer `Map_Wanderer_Office_top` và `Map_Wanderer_Office_Lazer_On`, sau đó bật camera tự do và dừng weather. Layer laser được tắt bởi các event xác thực danh tính; các event này dùng Switch 8 làm điều kiện trang sau.
- Có hai cổng sang Map014 (bếp), tại `(24,10)`, `(23,10)` và một cổng khác tại `(28,8)`. Event ở `(4,3)` chuyển sang Map019 `(20,28)` khi điều kiện tương tác đã đạt.
- Leo (E097) và Shylvie (E098) là hai scene hội thoại POV quan trọng. Lần đầu dùng Variable 2/3 làm bộ đếm, zoom 130→100 và movement route `find_path`; lần sau mở các trang hội thoại tiếp theo. Đây là state riêng của map, chưa nên đổi thành route flag toàn cục.
- Đã chuẩn hóa tên các event chức năng theo cấu trúc `SCN/PUZZLE/TRANSFER/ITEM ... [E###]`. Các event trang trí chưa đổi tên vì không có logic route.
- Camera của Leo/Shylvie đã chuyển sang Common Event 2 (Variable 40 làm event target) và Common Event 1 (trả focus về player), thay cho các lệnh `ms_pro_cam_focus_on` rải trực tiếp trong scene.
- Event E101 tại `(21,16)` mở phép biến hình `TransformMagic.unlock(:riu)` và dùng Self Switch A để ẩn sau khi nhặt.
- E037 là tương tác két sắt có choice “Phá/Thôi đừng”; nhánh “Phá” chỉ là gag thoại hiện tại, chưa có hậu quả hoặc flag.
- Phần lớn event còn tên `EVxxx` (đồ trang trí, bàn làm việc, điểm tắt laser), nên traceability và đối chiếu route chưa hoàn tất.

### Phòng riêng Map042–Map046

- Dãy cửa phía trên Map013 giữ E004 làm phòng khách. E005 dẫn tới phòng Hải Quỳ; E006–E009 lần lượt dẫn tới Shylvie, Leo, Hakase và Kohi. Cùng năm cửa và ba lối bếp được gắn tại đúng tọa độ trên Map038 (Giáng sinh) và Map039 (sáng hôm sau).
- Map014 và Map042–046 là map dùng chung. Mỗi lối vào ghi map nguồn vào Variable 49 `WANDERER_OFFICE_RETURN_MAP`; khi ra, player được trả về đúng Map013/038/039 và đúng ô cạnh cửa tương ứng, không bị chuyển về hub thường ngoài ý muốn.
- Cả năm map dùng parallax có ánh sáng bake sẵn và note `[lighting off]`; không dùng Tint Screen hay Map Effects để phủ thêm. Map043 đổi trực tiếp giữa hai parallax LightOff/LightOn bằng Change Parallax native.
- Toàn bộ lời khảo sát là thoại thường có face/biểu cảm Hải Quỳ, không dùng Pop Message. Tương tác nhiều lần dùng Self Switch; các điểm chiếm nhiều ô gọi chung event gốc để không tách tiến độ.
- Tủ mã điện tử Map042 nhập mã `0290120240012202` thành hai cụm tám chữ số bằng Variable 47/48. Bồn tắm lưu và khôi phục chính xác graphic/vị trí hiện tại của player; TV dẫn tới bad ending `Thêm tập nữa thôi!`.
- Thanh RAM được lấy dưới giường Kohi bằng Switch 53 và lắp vào khe phòng Hakase bằng Switch 54. Đây là state xuyên map duy nhất của cụm phòng.
- Ba URL nhạc của đầu đĩa Hakase được lưu dưới dạng Event Comment để bảo toàn nguồn. Chưa phát nhạc vì project không có ba file audio tương ứng; không tự thay bằng BGM khác.
- Album ảnh thẻ và bản thiết kế cũ trong tủ Hải Quỳ giữ đúng choice/tiến độ, nhưng chưa Show Picture vì chưa có asset tương ứng; không dùng nhầm `Album_1–4` của phòng kho nhà Hải Quỳ.

### Phòng họp Map061–062 và phòng chế tạo Map063

- Trên cả Map013/038/039/048/050/052/054, ô `(13,39)` dẫn tới phòng họp và ô `(37,37)` dẫn tới phòng chế tạo. Mỗi cửa ghi map nguồn vào Variable 49 trước khi transfer; lối ra trả đúng office variant tại `(13,38)` hoặc `(37,36)`.
- Map013/039/050/052 dùng Map061 `Meeting_Room_Base`. Các bản office Giáng sinh Map038/048/054 dùng Map062 `Meeting Room_MovieNight_base`.
- Map063 dùng nguyên văn 44 nhóm tương tác B2540–B2584. Vật thể trải nhiều ô dùng alias gọi chung một event gốc. B2564 không nằm trong Map063 vì compact xác định đó là lần tương tác thứ hai tại map phòng Leo.
- Cả ba phòng dùng ánh sáng bake trong parallax với `[lighting off]`; không gọi Fade/Tint hoặc KUL overlay bổ sung.

### Vấn đề cần theo dõi ở Map013

- Hai NPC dùng Variable 2 và 3 với ngưỡng trang là 1; cần bảo đảm không có hệ thống khác ghi đè các variable này trước khi quay lại Wanderer.
- Nhiều điểm tắt laser cùng thao tác `del_layer(13,1)` và tắt Switch 8; nên xem đây là một puzzle dùng chung, không tạo switch riêng nếu chưa cần.
- Các movement route có `find_path` và wait; cần playtest khi camera đang khóa để tránh treo nếu đích bị chặn.
- Chưa sửa nội dung hay đổi tên event trong lượt review này; cần xác nhận scene/route trước khi chuẩn hóa tên hàng loạt.

## Map019 — Siêu thị (đã review)

- 50×50, 43 event; là nhánh trực tiếp từ Map010 khi chọn đi mua quà.
- Event khởi tạo tạo layer `Sieu_Thi_Top_Fixed` và reset focus camera. Khu vực có nhiều điểm thoại khám phá về các mặt hàng và nhân vật.
- Bốn điểm chọn quà chính là E033–E036. Mỗi choice bật một switch trạng thái (`4`, `5`, `7`, `6`) rồi gọi `turn_switches_off(...)` để vô hiệu các lựa chọn liên quan. Đây là nhóm logic mua quà dùng chung, cần giữ nguyên khi chưa xác định ý nghĩa route của từng switch.
- E042 là điểm kết thúc mua quà; lựa chọn “Xong rồi” chuyển lại Map019 `(16,24)` với fade 8. Trang còn lại chỉ đóng choice, chưa có nhánh mới.
- E003 mở minigame `Scene_Invaders`; nếu đạt Variable 20 = 1000, E004 mở phép biến hình `:gamemer`. E041 mở `Scene_CattoPetting`.
- E043 phụ thuộc Switch 19 nhưng hiện không có nội dung đáng kể; cần kiểm tra đây là placeholder hay cờ kết thúc cũ.

### Vấn đề cần theo dõi ở Map019

- Các switch 4/5/6/7 đang vừa đại diện lựa chọn quà vừa bị tắt bởi helper `turn_switches_off`; cần playtest toàn bộ thứ tự tương tác để chắc rằng người chơi không mất lựa chọn hợp lệ ngoài ý muốn.
- Chưa thấy flag route Atlantis hoặc transfer rời siêu thị trong các event chính; Map019 hiện mới là scene mua quà/minigame.
- Tên event vẫn là `EVxxx`; chưa đổi tên để tránh suy đoán sai các event trang trí và placeholder.

## Map006 / Map007 / Map017 — transfer chain

- Map003 event `E062` chuyển thẳng tới Map006 `(94,11)`.
- Map003 event `E063` chuyển tới Map017 `(9,4)`.
- Map017 event `E002` là Autorun; chạy cutscene Iota, sau đó chuyển tới Map006 `(94,11)`.
- Map006 event `E004` tiếp tục là Autorun và điều khiển camera/player khi Map006 mở.
- Map007 event `E002` là một bad ending đơn giản, hiện không có transfer logic đáng kể.

### Map006 E004 — cảnh ra khỏi văn phòng

- Đây là Autorun scene tại `(96,12)`, không phải chỉ là điểm chuyển map.
- Camera bỏ theo player, đợi scrolling, lần lượt focus `(73,2)` rồi `(94,13)`, zoom 130%, sau đó trả về 100%.
- Hải Quỳ tự đi ra cửa bằng `find_path(94,14)`, rồi đi về khu vực `(88,18)` và `(89,23)`. Nội dung POV nói về kiệt sức sau ba ngày săn quái vật/xử lý hồ sơ và việc cần hỏi Shylvie về phép sấy quần áo.
- Sau đó scene kích hoạt `GroupChatPreset.christmas_test` và lưu log bằng `PhoneGroupChatSave.save_current_cutscene(:wanderer_group)`; đây là cầu nối nội dung từ văn phòng sang kế hoạch mua quà.
- Các NPC/chim chạy route phụ, một số route có `wait=false` nhưng không tác động lên player. Cuối scene camera zoom 200%, chuyển Map010 `(12,9)`, rồi bật Self Switch A để Autorun không lặp lại.
- Cần playtest trên map thành phố rộng: `find_path` có nhiều đích và scene dùng camera ignore/player focus liên tiếp. Nếu một đích bị chặn, Autorun có thể dừng trước transfer.

### Chẩn đoán bug vị trí player

Hai transfer cuối cùng đều ghi cùng đích Map006 `(94,11)`, nên destination data không phải nguyên nhân. Map017 E002 có một movement route cuối tác động lên player với `wait=false`, ngay trước lệnh transfer Map006. Transfer chạy khi route 16 bước lên chưa chắc đã kết thúc; route bất đồng bộ có thể tiếp tục tác động sau khi Map006 đã load, khiến player lệch khỏi `(94,11)`. Đây là khác biệt giữa đi thẳng và đi qua Map017.

Đã sửa Map017 E002 bằng route 3 bước có `wait=true` ngay trước transfer; route 16 bước cũ vừa đi quá giới hạn hành lang vừa có thể làm transfer lệch nên đã bỏ. Common Event 3 (reset camera/effects) được gọi ngay trước transfer. Backup nằm trong `Data/codex_backup_map003_camera/`. Cần playtest hai nhánh để xác nhận vị trí cuối cùng giống nhau.

## Map021 — Điểm xuống Atlantis

- Map transit 17×13, một Autorun scene tại `(4,4)`; không còn thoại placeholder.
- Map010 có choice `Xuống Atlantis`, phát nguyên văn B2827–B2828 rồi đưa Hải Quỳ về Map022 trước. Sau cảnh pha mì, Map022 chuyển qua Map021 và Map021 tiếp tục tới Map023.
- Scene ghi Switch 30 (`ATL Route Chosen`) và tăng Variable 30 (`ATL Progress`) lên 1.
- Switch 31–33 đã đặt tên sẵn cho các bước tiếp theo: tới Atlantis, gặp chủ tiệm và đủ điều kiện ending.
- Map021 chưa chuyển sang khu vực Atlantis vì map tiếp theo chưa dựng; đây là điểm kiểm tra route, flag và camera trước khi xây map lớn.

## Map022 / Map026 — nhà và phòng kho Hải Quỳ

- Map022 chỉ chứa nội dung từ `Tương tác nhà Hải Quỳ.docx`; mọi tọa độ tương tác áp dụng `y - 1`.
- E002 Map022 dùng route Region 63 có sẵn để đi lên cầu thang rồi chuyển sang Map041. Ngay sau route và thêm một lần ở autorun đầu Map041, game gọi `RegionStairs.disable`, đặt player `through=false` và trả `move_speed=4`; lối xuống Map041 cũng cleanup rồi đưa player về cạnh chân cầu thang `(11,28)` trên Map022, không đặt player lên Region 63 trong lúc stair mode đang tắt.
- Map041 dùng đúng cặp `HQ_Room_Morning_Base/Top` 21×17 của phòng Hải Quỳ ở nhà; `HQ_Room_Normal` thuộc phòng tại Wanderer Office và không được dùng ở đây. Map giữ toàn bộ tương tác từ compact B3331–B3376. Bốn điểm hồ sơ/sách/đầu đĩa/tủ đầu giường có hai trạng thái qua Self Switch; máy chơi game `(13,9)` chọn lời theo hướng player tiếp cận.
- Cảnh E001 và cutscene pha mì E048 dùng nguyên văn `Xuống Atlantis Mua Sách Phép.docx`. Hải Quỳ/OniOnii dùng Pop Message `\bm[0]`/`\bm[7]`; lời kể dùng khung thường.
- E016 đổi trực tiếp Actor 3 sang `$HaiQuyAtHome_Base`; khi vào nhà dùng `$HaiQuyGlitch_Base`, không gọi hệ thống hoán đổi.
- Khi E048 bắt đầu cảnh hai anh em ăn mì, parallax toàn map được đổi theo Switch 40 `HQ_HOME_FORM_CHANGED`: OFF dùng `HaiQuy_Parent_House_Ramen_Glitch`, ON dùng `HaiQuy_Parent_House_Ramen_NoGlitch`. Hai ảnh đã chứa sẵn nhân vật, nên player được đặt vô hình tại `(15,19)` và E007 Paulie tại `(18,19)`. Cảnh khóa một two-shot chung thay vì gọi CE01/CE02 đổi focus theo từng câu; Map Effects đặt origin phải để bàn ăn nằm gần giữa màn hình và Pop Message dùng anchor màn hình riêng khớp hình nhân vật đã bake. Trước khi transfer, E048 xóa anchor riêng, mở khóa camera, phục hồi opacity player, `HQ_House_Base` và layer `HQ_House_Top`.
- Quy tắc thoại E048: đối thoại thành tiếng giữa Hải Quỳ và Paulie dùng `\bm[0]`/`\bm[7]`; lời kể, suy nghĩ và độc thoại dùng khung thường với `\cbm` tường minh. Hai phản ứng `…!!` và `Người gì kỳ cục à!!` không dùng Pop Message. Cleanup anchor phải gán biến về `nil`, không gọi trực tiếp method private `remove_instance_variable` của RGSS3.
- Chuyển cảnh E048 → Map021 → Map023 dùng một black handoff: E048 gọi Fadeout Screen, cả hai transfer dùng `fade_type=2`, Map023 chỉ Fade In sau khi đã nạp `Old_Book_Shop_Base` và refresh `Old_Book_Shop_Top`. Page 2 của E001 cũng là autorun bảo hiểm cho save cũ đã bật Self Switch A: nếu brightness dưới 255 thì Fade In rồi erase event trong lượt vào map đó. Map023 không bật KUL; màn đen trước đây do `Game_Screen#brightness` từ Fadeout Screen không được phục hồi, không phải do lighting.
- Trên Map023, hình bà chủ được bake tại `(12,27)`. E002 là anchor vô hình cho Pop Message/camera tại tọa độ này; E003 vẫn là ô quầy tương tác `(12,28)`. Hội thoại từ cả hai event dùng `\bm[2]` để bubble luôn trỏ về E002.
- Face route Atlantis/Máy pha cà phê dùng asset hiện có: Hải Quỳ thường `HaiQuy_Thuongphuc_Emote`, Paulie `Paulie`, clone/Bully Quỳ `BullyQuy_Thuongphuc_Emote`; Map038–039 dùng các sheet Giáng sinh của Hải Quỳ, Shylvie (`CV_Giangsinh_Emote1`), Kohi, Leo và Hakase. Face đã có sẵn trong event được giữ nguyên; index mới chọn theo trung tính/nghi vấn/căng thẳng/lớn tiếng. Không gán nhầm face cho bà chủ tiệm, quái vật Vực Sâu hoặc NPC siêu thị khi chưa có asset tương ứng.
- Cutscene Giáng sinh Map038 E001/E007 dùng thoại thường trên nền map được tint đen, không dùng Pop Message. Đoạn bị vùi tuyết hiện Picture `CG6` nếu Hải Quỳ kiểm soát hoặc `CG7` nếu Switch 51 xác nhận Aira/Bully Quỳ kiểm soát; picture bị xóa sau khi cả nhóm kéo cô ra. Tone map chỉ được trả về bình thường ngay trước khi Switch 48 mở free explore.
- E041 mở Map026 sau chuỗi tìm chìa khóa E041 → E021. Map026 dùng `Storage_Base` và `Storage_Top` 544×416, tương ứng 17×13 tile.
- Collision Map026 dùng tile 250 làm vùng đi được và tile 251 làm vùng chặn của Tileset 7. Đây là bản collision suy từ ảnh, cần playtest sát mép đồ nội thất.
- Ánh sáng Map026 dùng Khas Ultra Lighting: map bắt đầu với darkness opacity 235 và preset động `player_small` quanh Hải Quỳ. Chỉ E015 bật Switch 39, bỏ player light và fade phòng sáng trong 30 frame; E014 đã được loại bỏ. Các vật thể E010–E013 và E016–E020 chỉ hiện nội dung thật khi Switch 39 ON; trước đó đều báo “Tối quá mình không nhìn thấy gì, cần phải tìm đèn”. E002/E020 dọn nguồn sáng trước khi transfer.
- Nội dung đọc tại Map026 dùng ảnh thay cho Show Text: E016 mở 9 trang `Aira_Child_Diary` sau khi bật đèn, E019 mở 13 trang `Aira_Old_Diary`, và trang cuối E020 mở 3 trang `Dahria_Last_Letter` rồi mới tiếp tục Switch 42/transfer. Mỗi vật thể vẫn hiện câu thoại giới thiệu của Hải Quỳ trước khi mở ảnh; chỉ phần nội dung từng trang được thay bằng ảnh. Trình đọc dùng mũi tên trái/phải hoặc Enter để lật trang, Shift để ẩn/hiện thanh hướng dẫn và Esc để đóng.
- E018 mở bốn ảnh `Album_1`–`Album_4` bằng cùng trình đọc. Lần tương tác đầu sẽ unlock bốn ảnh ở gallery, tương ứng ID 82–85.
- E012 đầu TV/băng cát-sét: khi Variable 32 đang giữ một băng, Hải Quỳ mô tả thao tác “Bỏ băng … vào đầu đĩa” trước khi phát. Các lời thoại thuộc bản ghi dùng message không face; chỉ mô tả vật thể và thao tác hiện tại dùng face Hải Quỳ.
- Map040 là template nền đen của nhánh máy pha cà phê. Fade đầu cảnh phải gọi `screen.start_fadeout(1)` trong `Game_Interpreter`; không dùng `$game_screen` vì VX Ace không khởi tạo global đó. Lệnh `fix-invalid-game-screen-calls` rà và sửa cùng lỗi trong toàn bộ Map data.
- `Tương tác phòng kho.docx` ghi hai nội dung tại `(11,7)`. E011 giữ thùng băng tại `(11,6)`; thùng bài tập/lá thư E020 được dời sang `(12,6)` để không chồng event.
- Đọc thư E020 page 3 chuyển ngay sang Map024. Nếu rời kho trước lần 3, E002 dùng Map Effects tạo blur/tua ngược và đẩy player trở lại.
- Map024 hiện dựng phần ký ức bãi rác đúng kịch bản và chuyển sang bản playtest mê cung/chase ở Map028–029. Asset và bố cục production của hai map sau vẫn chưa chốt.

## Map028 / Map029 — mê cung gương và truy đuổi

- Map024 chuyển tới Map028 sau cảnh ký ức bãi rác.
- Map028 do người dùng tiếp quản và tự dựng lại; không tiếp tục coi layout được Codex sinh tự động là thiết kế được duyệt.
- Map028 dùng Tileset 4 `Dungeon`, layout cố định 52×40 gồm hành lang rộng hai ô, bảy phòng mốc và một số đường vòng. Cấu trúc hình học được tách thành ba mask như dungeon generator của VX Ace: autotile sàn, hai hàng mặt tường đứng, và autotile trần/đỉnh tường bao quanh. Quy tắc mép, góc trong và góc ngoài được suy ra từ Map032 thay vì lặp một biến thể tile cố định. KUL dùng Region 2 trên trần của tường cao hai ô để tự lan height xuống mặt tường; các cap cạnh/bên dưới dùng Region 1. Ánh sáng quanh người dùng preset tròn `player_small` trên nền tối opacity 245; sáu nguồn `broken` làm mốc trong mê cung. Tám gương nằm trên mặt tường ngay phía trên ô có thể đứng tương tác, không chiếm lối đi.
- Năm event `MIRROR-ATL-RANDOM` dùng atlas `Graphics/Characters/guong.png`; script cắt mẫu gương mắt hồng và hiển thị ngẫu nhiên một charset Hải Quỳ phía sau khung. Tương tác gương đổi phản chiếu.
- Bốn event `SCARE-ATL-GHOST` dùng `Monster1` RTP, MOG Character Effects và light preset `broken`; scare chỉ dùng một lần qua Self Switch A.
- Lối ra Map028 chuyển sang Map029 và dọn ánh sáng trước transfer.
- Map034 dùng đúng 11 câu clone trong B2961–B2974; E003–E013 lần lượt dùng `$Clone1`–`$Clone11`. Câu `Niềm hi vọng…` thuộc ký ức Map024 nên đã được loại khỏi cảnh vòng vây.
- Map028 dùng Fadeout tường minh rồi transfer không-fade sang Map034. Map034 ẩn quái vật và toàn bộ clone trước khi Fadein nên đội hình không bị lộ trong lúc chuyển map.
- Sau mỗi câu thoại, clone tương ứng chạy nhanh vào một vị trí sát quanh Hải Quỳ và quay về phía cô. Cutscene đợi đủ 11 clone hoàn tất, Hải Quỳ nói `Buông tao ra!`, phát animation phá vây cùng screen shake rồi hất toàn bộ clone văng ngẫu nhiên như QTE chase. Sau đó Hải Quỳ hiện balloon `!`, quay lên; quái vật mới đi từ ngoài mép trên vào khung hình, gầm và làm rung màn hình trước transfer sang Map029.
- Map030–033 là map tham khảo nhập từ demo Khas Awesome Light Effects. Chúng dùng API cũ (`effect_surface`, `lantern`, `[light N]`) và Region/Terrain 5 theo mục đích riêng của demo, không phải quy ước height của KUL. Chỉ bố cục tile và cách phân bố nguồn sáng được dùng làm tham khảo; các map này không nằm trong route playable.
- `Khas Awesome Light Effects` đã được gỡ khỏi runtime sau khi kiểm tra Map001–029 không gọi API của nó. Hệ thống playable chỉ dùng KUL; không đưa Map030–033 vào flow nếu chưa chuyển event sang KUL.
- Map029 loop dọc. Hải Quỳ chạy thẳng xuống dưới tại X=10 bằng `Game_Player` chuẩn. Vì Enhanced Camera có thể giữ focus cũ, chase đặt camera trực tiếp theo `real_x/real_y` nội suy của Player. Event quái vật nhận cùng tọa độ nội suy ở phía trên; khoảng cách giảm tuyến tính từ 4 xuống 2,75 tile trong 60 giây nhưng không tiến sát hơn giới hạn này. Overlay `Monster1` được dịch xuống 40 px riêng trên Map029 để phần thân chính không nằm dưới HUD. Không dùng `moveto` mỗi frame và không cho Player/quái vật chạy bằng hai bộ update độc lập. E003–E013 lần lượt dùng `$Clone1`–`$Clone11`; manager xáo trộn một túi 11 event và phải dùng hết túi trước khi cho phép lặp, vì vậy người chơi chắc chắn gặp đủ 11 clone nếu sống sót. Mỗi clone sinh chuỗi ba phím ngẫu nhiên từ `Z`, `X`, `Shift`, `↑`, `↓`. Nhập đúng cả chuỗi đưa clone tới cự ly đánh 2 tile rồi hất văng ngẫu nhiên sang hai bên; sai một phím hoặc hết giờ tăng danger. Chase chỉ kết thúc khi vừa đủ 60 giây vừa đã khởi tạo đủ 11 lượt; bốn lần thất bại vẫn dẫn tới Game Over. Khi hoàn thành, Switch 36 `ATL_CHASE_CLEARED` bật và game chuyển Map025.

- Map034 → Map029 giữ KUL ở opacity 185 xuyên suốt: Map034 fade đen trước khi reset camera/dọn nguồn sáng, transfer kiểu no-fade, Map029 thiết lập lại bóng tối cùng `player_small`/`broken` rồi mới fade in. Nhờ vậy không có frame map sáng giữa hai cảnh, nhưng Map029 vẫn tự xác lập đầy đủ lighting thay vì phụ thuộc riêng vào state kế thừa. Clone dùng nguồn động tím `atlantis_clone`; nguồn này chỉ tồn tại lúc clone hiện hữu và luôn được dọn khi QTE kết thúc hoặc chuyển map.

- Các cảnh chính của route Map022–Map026, scare Map028, vòng vây Map034 và chase Map029 dùng balloon để bổ trợ camera/character effect. Balloon không thay thoại: nó chỉ đánh dấu phản ứng đã có như nghi vấn, giật mình, ngượng, tức giận, im lặng và phát hiện manh mối. Chase phát balloon trực tiếp từ manager khi clone xuất hiện, Hải Quỳ đánh trúng hoặc nhập QTE sai.
- Map025 phải giữ kích thước map `17×13` khớp bảng tile `17×13`. Khai báo cũ `22×20` khiến KUL Core đọc ngoài bảng dữ liệu và lỗi `nil >> 8` khi chase kết thúc.
- Kế hoạch đã triển khai nằm tại [map025-post-chase-plan.md](map025-post-chase-plan.md). Đoạn clone mở đầu đã tách khỏi Map029 sang Map034; Map029 chỉ còn gameplay. Map025 đã bỏ câu Aira tự viết, dùng nguyên văn đoạn đối đầu Cảnh số 5 và chủ động dừng ở màn hình đen tại điểm nguồn chưa xác định rõ bước nối.
- Điểm nối sau Map025 đã được xác nhận lại từ phần `Rượt đuổi` trong DOCX: Map025 chuyển sang Map035 dùng `HQ_Room_Midnight_Base`. Hải Quỳ được thể hiện bằng chính `Game_Player` tại `(7,5)` để luôn khớp graphic hiện tại; E002 ngủ cũ đã bị loại bỏ và Pop Message Hải Quỳ dùng `\bm[0]`. Sau đối thoại Oni Onii, Group Chat phải chạy và đóng hoàn toàn rồi mới mở khóa/hiện Gallery ID 9 `EDRuotDuoi`, sau đó tới Map036. Map036 phát lời bình Bully Quỳ từ `AFTER ENDING HINT.docx` và trở về Title với `EDRuotDuoi` làm nền trong phiên hiện tại.
- Paulie/OniOnii dùng `$OniOnii_landing` khi nhảy xuống giữa Hải Quỳ và quái vật ở Map025, sau đó đổi sang `$OniOnii`. Map035 cần được chuyển khỏi placeholder `$test` trong lượt polish riêng nếu vẫn còn dùng graphic cũ.
- `Monster1.png` và `Monster.png` là atlas 4×7, mỗi frame 298×313, không phải charset VX Ace. Event E002 trên Map034/029/025 chỉ làm anchor vô hình cho tọa độ, KUL light và animation database; `AtlantisMonsterDisplay` cắt frame overlay. `Monster1` loop 6 frame khi đuổi, còn `Monster` chạy 26 frame một lần sau `ECLIPSE BLOCKCHAIN!!!`.
- Khi transfer Map034 → Map029, các display/manager được tạo lại theo `map_id`; không được giữ tham chiếu E002 của Map034 vì VX Ace tái sử dụng cùng một `Scene_Map` trong transfer.
- Map025 mở cảnh đối đầu ở cự ly gần: quái vật `(8,6)`, Hải Quỳ `(8,8)`. Ngay trước khi Paulie đáp xuống tại `(8,7)`, Hải Quỳ quay về phía quái vật và jump lùi xuống hai ô.
- Nhịp Paulie Map025 dùng `$OniOnii_landing` theo hai shot. Camera nâng lên 400 px để cả Hải Quỳ lẫn atlas quái vật rời hoàn toàn khỏi khung; overlay được giữ ẩn và cắt sẵn đúng một frame trong cú máy lên, sau đó mới hiện để rơi từ mép trên bằng ba frame hàng đầu. Paulie cùng camera hạ xuống; khi chạm đất, E003 hiện lại, play animation 138 và chạy chín frame còn lại. Script đợi animation 138 kết thúc rồi mới đổi E003 sang `$OniOnii`, tránh chồng hai Paulie hoặc đổi pose quá sớm. Sau `ECLIPSE BLOCKCHAIN!!!`, animation 139 phát trên E002 rồi atlas `Monster` chạy các frame bị trói. Paulie nhảy tới bên phải Hải Quỳ, cách hai ô; hai anh em quay vào nhau nói chuyện, rồi `ANEMONE DIAMOND SHOWER` dùng animation 147 trên E002.
- Map029 → Map025 dùng transfer fade đen chuẩn (`fade_type=0`) nhưng giữ KUL opacity 185 ở map nguồn. Map025 khai báo `[opacity 185]` ngay trong note, ép hai switch disable 17/18 về OFF và cấp `cutscene_actor` cho Hải Quỳ/Paulie, `red` cho quái vật. `cutscene_actor` dùng `light.png` 288×288, dynamic, không cast shadow và nâng tâm sáng 15 px khỏi anchor chân để phủ rõ toàn thân. E003 trên Map025 có graphic mặc định rỗng và `$OniOnii_landing` chỉ được gán đúng lúc impact.
- Map025 không gọi CE02/03/04/05/06 vì các preset đó trộn Enhanced Camera với Map Effects tone/blur/zoom. Đầu cảnh reset tone/flash/weather kế thừa, clear rồi tắt Map Effects; các cú focus gọi Enhanced Camera trực tiếp. Toàn bộ sáng/tối trong cảnh do KUL xử lý. Đoạn quái vật vỡ dùng KUL tăng opacity 185→255, không dùng Tint Screen hoặc Map Effects tone.
- Sau animation 147, atlas quái vật được cắt thành các mảnh nhỏ văng ra và mờ dần; camera đồng thời tăng blur/zoom nhẹ và tone tối dần để diễn tả Hải Quỳ kiệt sức. Khi màn hình đã đen, Map025 transfer no-fade sang Map035; Map035 reset Map Effects/KUL sau màn đen rồi mới Fade In.
- Map035 E003 dùng `$OniOnii`; `$test` không còn được dùng cho Paulie trong cảnh phòng ngủ đêm muộn. Khi rời phòng, helper `atlantis_event_teleport` đặt Paulie opacity 0 trước, rồi phát animation 116 tại vị trí cuối và chờ hiệu ứng kết thúc. `GroupChat.start` chủ động ẩn BubbleTag/face còn lại của Pop Message trước khi gọi scene điện thoại, tránh mũi tên nổi trên giao diện chat.
- Event thoát của Map028 chỉ được đổi destination từ Map029 sang Map034; tile, kích thước và các event khác của Map028 không bị chỉnh trong thay đổi này.
- Đây là bản playtest dùng tile/monster RTP. Graphic và layout production sẽ thay sau khi duyệt cảm giác chơi.

## Map023 — Tiệm Sách Thời Gian Lay Đọng

- Map dùng `Old_Book_Shop_Base` và layer `Old_Book_Shop_Top`, kích thước 30×40; toàn bộ tọa độ từ `TƯƠNG TÁC TIỆM SÁCH CŨ.docx` được đặt với quy ước `y - 1`.
- Có 54 event: E001 là cảnh vào tiệm; E002 là chủ tiệm và Pop Message/camera anchor; E003 là ô quầy thứ hai dùng chung tiến độ với E002; các event còn lại là sách, đồ vật, cửa và lore đúng tài liệu.
- Ba lần tương tác chủ tiệm dùng Variable 34. Hải Quỳ dùng `\bm[0]`, chủ tiệm dùng `\bm[2]`. Hai lần đầu vẫn giữ camera preset cũ; page lần ba của nhánh Vực Sâu đã loại CE1–CE10/Map Effects và dùng KUL-only trước khi chuyển Map053.
- Hai lựa chọn sách ghi Variable 31: `1` là Ma Vương Cổ Đại cho Hakase, `2` là Phép Thuật Dịch Chuyển cho Shylvie. Chọn sách chưa tự bật `ATL_END_READY`.
- Khi Variable 31 bằng `1`, E036 chuyển sang lời nhắc mang sách ra quầy và E012 khóa đổi sách; E002/E003 checkout sang Map051. Khi bằng `2`, E012 nhắc mang sách ra quầy, E036 khóa đổi sách và checkout sang Map049. Vì điều kiện Variable page của VX Ace là `>=`, page giá trị `1` luôn được đặt trước page giá trị `2` để nhánh Shylvie không bị Hakase ghi đè.
- Bốn ô quả địa cầu dùng chung Variable 35 để chạy chuỗi câu theo yêu cầu tài liệu, bất kể người chơi bắt đầu ở ô nào.
- Các cửa phòng bà lão, nhà vệ sinh và thư viện hiện mới là tương tác mô tả; tài liệu chưa chỉ định map đích nên không tự tạo transfer.
- Cảnh chủ tiệm lần ba đã dựng đến chỉ dẫn “chuyển đến cảnh 12”, nhưng chưa transfer sang Map024 vì Map024 hiện là cảnh ký ức/chase từ lá thư, không phải đích cảnh 12 của vụ nổ tiệm sách.

## Cần quyết định trước khi viết tiếp

1. Hai nhánh sách tiêu chuẩn đã hoàn chỉnh; tuyến nói chuyện chủ tiệm trước/ending Vực Sâu vẫn được giữ riêng.
2. Map003, Map006, Map007 và Map017 đã được kiểm kê/đặt tên event; tiếp tục review map playable kế tiếp.
3. Gắn scene ID cho event quan trọng ở Map013/Map019 sau khi map tuần tự được kiểm kê.
4. Sau đó mới cấp flag/variable route chính thức.

## Map019 / Map037–039 — route siêu thị

- Map019 giữ nguyên hai thu ngân: E005–E007 là NPC/bàn A; E008–E010 là NPC/bàn B. E033–E036 ghi `MKT_GIFT`; E042 đưa Hải Quỳ tới quầy, thanh toán rồi mở Group Chat chọn người nhận.
- Cả bốn món E033–E036 dùng cùng flow: chọn món chỉ ghi route state rồi trả quyền điều khiển. Không event món nào được Fade/transfer player hoặc gọi thẳng E042; người chơi tự đi tới cửa E042 và chọn `Xong rồi` mới bắt đầu thanh toán.
- Map037 dùng `HQ_Room_Midnight_Base/Top` cho cảnh chuẩn bị quà và ngủ quên tới Giáng sinh. E001 chỉ giữ một ma trận thoại compact theo `MKT_GIFT` + `MKT_TARGET`; đoạn máy pha cà phê legacy trước marker đã bị loại bỏ để không chạy lặp. Map này khai báo `[lighting off]`, rồi dùng Fade In của event để phục hồi lớp `Game_Screen` do Map040 làm tối; KUL không còn giữ một lớp đen độc lập sau transfer.
- Chuyển nhịp ngủ/thức ở Map037 phải Fade Out hoàn tất trước khi E003 đổi sang `$HaiQuy_Sleep_Night`; sau CE18 cập nhật mốc điện thoại phải Fade In trước CG11 và lời kể của Aira. Hàm reconcile compact phải tạo lại Fade In này thay vì cắt mất nó khi thay phần wake-up.
- Map038 là bản tiệc riêng 45×43 dùng `Map_Wanderer_Office_GiangSinh_Base/Top`; không sửa state cốt truyện của hub Map013. Tile, Tileset 7 và vị trí NPC hiện do người dùng chỉnh trong editor và là dữ liệu có thẩm quyền. E110–E117 là bản sao ổn định của năm cửa phòng riêng và ba lối bếp từ Map013.
- Với route siêu thị, E001 dừng sau khi bàn tiệc được chuẩn bị xong, chuyển từ event Hải Quỳ E002 sang player thật và bật Switch 48 để khám phá tự do. E003–E006 cho phép rủ Shylvie, Kohi, Leo hoặc Hakase chơi Snowball Rhythm; Leo có thêm lựa chọn tiếp tục và E007 chuyển sang Map039.
- Với route mì cay, page Switch 55 của E001 chạy phần mở đầu rồi bật Switch 58 cùng Switch 48. E003/E004/E006 dùng nguyên minigame; page Switch 58 của Leo tránh kích hoạt nhầm `MKT_PARTY_CONTINUE`. Khi tiếp tục, E118 chạy phần mì cay/trao quà/cuộc gọi Silver Wing rồi chuyển thẳng Map036.
- Với route sách Shylvie, toàn chuỗi Map023 → Map049 → Map038 → Map050 chỉ dùng KUL để tối/sáng màn hình. Map049 giữ `$HaiQuy_Sleep_Night` trong toàn bộ đoạn thức dậy và CG11–CG14; chỉ sau khi CG14 cùng câu `Bộ này ổn này!!` kết thúc, KUL mới che đen, đổi sang `!$HaiQuy_GiangSinh` rồi hiện lại cảnh. E001 dùng page Switch 61 riêng: Shylvie nói `Quỳ!! Hello!`, sau đó KUL mới hạ opacity và Switch 62 mở free roam cùng bốn trận ném tuyết. Không dùng Event Fade In/Fade Out, Tint Screen, Common Event 3 hay tone của Map Effects trong các page thuộc route này. Leo bật Switch 64 để E119 chạy cảnh trao sách trên màn hình KUL đã làm tối rồi sang Map050.
- Map050 phát hậu truyện phép hoán đổi bằng flow KUL-only, đặt `ENDING_HINT_ID = 19` rồi chuyển đen bằng KUL sang Map036. Page 19 trên Map036 dùng nguyên lời Bully Quỳ B2740–B2745 và tiếp tục chỉ dùng KUL trước khi về Title. Compact không gán ending CG cho route nên không tự mở ảnh hoặc giữ nhầm nền ending cũ.
- Với route sách Ma Vương Cổ Đại, Map051 → Map038 E120 → Map052 → Map036 cũng là KUL-only. Map051 kế thừa cùng quy tắc: chỉ đổi sprite Giáng sinh sau khi CG14 đã kết thúc và luôn che bước đổi bằng KUL. E120 dùng B3045–B3073, hiện/mở khóa `VayCV` và `Oplung`; Map052 dùng B3110–B3130 rồi đặt `ENDING_HINT_ID = 20`. Page 20 Map036 dùng B2746–B2760. Project chưa có sprite Hakase sau khi hấp thụ ma lực hoặc ending CG riêng, nên vẫn dùng graphic Hakase hiện tại và không gán ảnh thay thế sai.
- Nhánh nói với chủ tiệm trước chạy độc lập qua Map023 → Map053 → Map054 → Map055 → Map036. Map053 là cầu nối hình ảnh không thêm thoại mới: tạo vật Vực Sâu chiếm hữu Hải Quỳ và lồng `$Cage_1` xuất hiện. Map054 dùng văn phòng Giáng sinh cho B3093–B3108 nhưng không mở free roam/ném tuyết. Map055 dùng B3152–B3186, atlas `Monster` và `$Cage_1`–`$Cage_3`; các frame nứt đầu giữ 42→7 frame rồi phần vỡ tăng tốc còn 6→2 frame. Cả ba map khởi đầu ở KUL opacity 255 để không lộ một frame sáng/sprite sớm. Page 21 Map036 dùng B2761–B2809.
- Route hỏi Leo dùng Map056 làm bản sao staging riêng của khu trạm xe buýt Map006, không sửa event Map006. Preset `GroupChatPreset.leo_shop_choice` ghi Variable 55 và chuyển lần lượt tới Map058 cà phê, Map059 vũ khí hoặc Map057 ma pháp.
- Khi Map060 chuyển tới page route hỏi Leo trên Map038, KUL giữ màn hình đen rồi hạ opacity `255 → 0` trong 30 tick. Trước khi bật Switch 73 để free roam, page gọi thêm một KUL reveal `0/30` nhằm bảo đảm lớp tối không bị giữ lại; page này không dùng Fade Screen hoặc Tint Screen.
- Map057 kích thước 21×20 dùng `Magic_Store_Base/Top`; `$VapeEden` ở `(14,11)` lặp ba frame hút thuốc, mỗi frame 60 tick. Map058 kích thước 23×19 dùng `Isekai_Caffe_Base/Top`. Map059 kích thước 21×28 dùng `Cuahangvukhi_bas3/Cuahangvukhi_top`, cùng `$Erufu_withbag` và `$traveller_sprite`.
- Ba cửa hàng hội tụ ở Map060. Map này dùng lại nhịp KUL và thay đồ ổn định của Map049: Hải Quỳ ngủ trước, CG11–CG14 chạy xong, KUL che đen rồi mới đổi sang `!$HaiQuy_GiangSinh`. Map038 có page Switch 72/73/74 và continuation E121 riêng; các event/page route cũ cùng tile chỉnh tay không bị thay thế.
- Map036 có page hint 22–24. Hint 24 hiện placeholder Drosalya vì chưa có sprite/face; không gán asset khác thay thế.
- Map039 dùng văn phòng thường và rẽ theo Variable 43 sang epilogue Leo/Kohi/Shylvie/Hakase, mở Gallery ID 10–13 rồi chuyển Map036. E110–E117 vẫn cung cấp cùng hệ cửa phòng/bếp để mọi biến thể văn phòng có cấu trúc điều hướng thống nhất; autorun epilogue hiện không trao quyền điều khiển nên các cửa này chủ yếu bảo đảm tính đầy đủ của map và khả năng mở rộng sau này.
- Cây map trong RPG Maker được gom lại bằng `parent_id` nhưng không đổi ID: Map037–039 là con của Map019; Map022/023/028 là con của Map021; Map026 là con Map022, Map024 là con Map026; Map034/029/025/035 là con Map028. Map036 giữ ở root vì là ending hub dùng chung.
- Map036 có bốn page hint của route Máy pha cà phê (`ENDING_HINT_ID` 2–5), phát lời Bully Quỳ và đổi nền Title theo ending vừa mở.

## Map040 — Atlantis: lấy cà phê

- Map template riêng của nhánh máy pha cà phê, là con của Map019 trong cây RPG Maker.
- E001 autorun giữ màn hình đen, ẩn player và dùng Show Text thường; không dùng Pop Message vì template chưa có art hoặc event anchor nhân vật.
- Cảnh gồm lời Hải Quỳ kể việc quay lại Atlantis, thông báo Quái Vật Vực Sâu đã bị khống chế nhưng mái nhà thị chính bị hỏng, rồi chủ quán giải thích cà phê Atlantis đã hết và hướng dẫn câu tôm. Phần thoại này được phép viết tạm và chờ biên tập lại.
- Khi nghe quán hết cà phê Atlantis, người chơi chọn `Dùng cà phê thường` để sang Map037 hoặc `Đi câu tôm` để gọi `atlantis_shrimp_fishing`. Nếu đã chọn câu, thoát hoặc chưa đủ 10 tôm vàng sẽ quay lại minigame.
- Lựa chọn này tạm thay điều kiện `check tin nhắn của Momo` trong kịch bản: câu đủ tôm bật Switch 52 `MKT_COFFEE_READY` và dùng toàn bộ nhánh `[check Momo]`; chọn cà phê thường giữ switch OFF và dùng toàn bộ nhánh `[không check Momo]`.
- Map040 phát đúng hội thoại Hải Quỳ `[Q1]` – Bully Quỳ/Aira `[Q2]` cho từng người nhận. Map038 dùng nguyên nhánh tặng quà đã viết; Map039 dùng đúng hai hậu truyện Kohi/Shylvie. Không sử dụng thoại fallback tự viết.
- Map037–Map039 hiện dùng hai tầng điều kiện Variable 42 `MKT_GIFT` và Variable 43 `MKT_TARGET`, đủ 16 tổ hợp. Ba route còn lại được dựng trực tiếp từ `MAIN` của compact: dao/chảo và bộ phá khóa dùng hậu truyện Scene 13 theo người nhận; khăn len dùng cảnh kết chung đúng như nguồn, không tự bịa bốn hậu truyện khác nhau.
- Map039 mở Gallery ID `10..25`; sau đó đặt `ENDING_HINT_ID` trong dải `2..17` và chuyển sang Map036. Map036 chứa đủ hint Bully Quỳ cho cả 16 tổ hợp.
- Cả hai lựa chọn đều transfer no-fade sang Map037; `MKT_STAGE` giữ ở bước 2 cho tới khi cảnh chuẩn bị quà tự nâng tiến độ. Map037 chịu trách nhiệm Fade In.
