# Map implementation audit

| Map | Tên | Kích thước | Events | Đối chiếu kế hoạch |
|---:|---|---:|---:|---|
| 3 | Văn phòng Silverwing | 22×23 | 65 | Mở đầu/hub |
| 6 | Thành phố | 110×32 | 7 | Kết nối khu mua sắm |
| 10 | Trong xe bus | 28×22 | 2 | Transit |
| 13 | Văn phòng Wanderer | 45×43 | 88 | Hỏi Leo/Shylvie, tiệc |
| 14 | Bếp | 45×43 | 24 | Route mì cay |
| 15 | Phòng tắm | 26×22 | 18 | Exploration; đã xác nhận nội dung |
| 17 | Hành lang Silverwing | 22×36 | 2 | Kết nối/lore |
| 19 | Siêu thị | 50×50 | 43 | Route quà chính |
| 20 | Map tạm | 35×30 | 1 | Bỏ qua, chưa dựng |
| 21 | Điểm xuống Atlantis | 17×13 | 1 | Route gate Atlantis |
| 22 | Nhà Hải Quỳ — bản thử | 22×43 | 48 | Nhà riêng; khám phá, chìa khóa, pha mì |
| 23 | Tiệm sách phép Atlantis | 30×40 | 54 | `Old_Book_Shop_Base/Top`; cảnh đến tiệm và toàn bộ tương tác đã dựng |
| 24 | Ký ức bãi rác | 20×14 | 1 | Mở đầu cảnh dí sau khi đọc thư |
| 25 | Atlantis — Đối đầu Vực Sâu | 17×13 | 3 | Cảnh số 5: Dahria, Oni Onii và đòn kết liễu; visual placeholder |
| 26 | Phòng kho nhà Hải Quỳ | 17×13 | 13 | `Storage_Base/Top`; băng, nhật ký, lá thư |
| 28 | Mê cung gương Atlantis | 31×25 | 11 | Dungeon RTP; Khas `player_small`, 5 gương, 4 scare |
| 29 | Hành lang truy đuổi Atlantis | 40×15 | 7 | Map loop ngang; endless-runner QTE 30 giây |
| 34 | Atlantis — Vòng vây bản thể | 40×15 | 14 | Cutscene 12 clone, nối Map28 → Map34 → Map29 |
| 35 | Phòng Hải Quỳ — Đêm muộn | 21×17 | 3 | Epilogue route rượt đuổi; Group Chat và mở khóa ending CG |
| 36 | After Ending Hint | 17×13 | 2 | Hub hint dùng chung; Variable 41 chọn nội dung route |

Map001/002/004/005/007/008/009/011/012/016/018/020 có event generic hoặc đang là map phụ/tạm. Map013 và Map019 có nhiều event nhưng tên vẫn `EVxxx`, nên chưa thể so sánh chắc chắn với từng scene route.

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

- Map route gate mới, 17×13, một Autorun scene tại `(4,4)`.
- Map010 có choice `Xuống Atlantis` chuyển tới Map021 `(4,4)`.
- Scene ghi Switch 30 (`ATL Route Chosen`) và tăng Variable 30 (`ATL Progress`) lên 1.
- Switch 31–33 đã đặt tên sẵn cho các bước tiếp theo: tới Atlantis, gặp chủ tiệm và đủ điều kiện ending.
- Map021 chưa chuyển sang khu vực Atlantis vì map tiếp theo chưa dựng; đây là điểm kiểm tra route, flag và camera trước khi xây map lớn.

## Map022 / Map026 — nhà và phòng kho Hải Quỳ

- Map022 chỉ chứa nội dung từ `Tương tác nhà Hải Quỳ.docx`; mọi tọa độ tương tác áp dụng `y - 1`.
- Cảnh E001 và cutscene pha mì E048 dùng nguyên văn `Xuống Atlantis Mua Sách Phép.docx`. Hải Quỳ/OniOnii dùng Pop Message `\bm[0]`/`\bm[7]`; lời kể dùng khung thường.
- E016 đổi trực tiếp Actor 3 sang `$HaiQuyAtHome_Base`; khi vào nhà dùng `$HaiQuyGlitch_Base`, không gọi hệ thống hoán đổi.
- E041 mở Map026 sau chuỗi tìm chìa khóa E041 → E021. Map026 dùng `Storage_Base` và `Storage_Top` 544×416, tương ứng 17×13 tile.
- Collision Map026 dùng tile 250 làm vùng đi được và tile 251 làm vùng chặn của Tileset 7. Đây là bản collision suy từ ảnh, cần playtest sát mép đồ nội thất.
- Ánh sáng Map026 dùng Khas Ultra Lighting: map bắt đầu với darkness opacity 235 và preset động `player_small` quanh Hải Quỳ. E014/E015 bật Switch 39, bỏ player light và fade phòng sáng trong 30 frame; E002/E020 dọn nguồn sáng trước khi transfer.
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
- Map030–033 là map tham khảo nhập từ demo Khas Awesome Light Effects. Chúng dùng API cũ (`effect_surface`, `lantern`, `[light N]`) và Region/Terrain 5 theo mục đích riêng của demo, không phải quy ước height của KUL. Chỉ bố cục tile và cách phân bố nguồn sáng được dùng làm tham khảo; các map này không nằm trong route playable.
- `Khas Awesome Light Effects` đã được gỡ khỏi runtime sau khi kiểm tra Map001–029 không gọi API của nó. Hệ thống playable chỉ dùng KUL; không đưa Map030–033 vào flow nếu chưa chuyển event sang KUL.
- Map029 loop ngang, giữ Hải Quỳ ở khoảng một phần ba bên trái màn hình; quái vật bám sau 4 tile (giảm còn 2 khi danger tăng) và các phân thân cản đường xuất hiện trước mặt khoảng 10 tile. Hải Quỳ chỉ chạy thẳng trên Y=7; không còn nhảy, lộn hoặc đổi lane. Mỗi phân thân sinh chuỗi ba phím ngẫu nhiên từ `Z`, `X`, `Shift`, `↑`, `↓`. Trong thời gian nhập chuỗi, phân thân được giữ trước Player và tiến gần dần từ 10 xuống 3 tile, nên không thể trôi qua sau lưng khi Hải Quỳ vẫn chạy. Nhập đúng cả chuỗi đưa nó tới cự ly đánh 2 tile rồi hất văng ngẫu nhiên khỏi đường chạy; sai một phím hoặc hết giờ tăng danger. Player và quái vật dùng move speed 5, frequency 6 và step animation trong chase, sau đó phục hồi cấu hình cũ. Bốn lần thất bại dẫn tới Game Over; sống sót 30 giây bật Switch 36 `ATL_CHASE_CLEARED` và chuyển Map025.

- Các cảnh tối Map034/Map029 không dựa vào ánh sáng kế thừa: Hải Quỳ dùng `player_small`, clone dùng nguồn động tím `atlantis_clone`, còn quái vật dùng nguồn đỏ ở cutscene và `broken` khi chase. Nguồn clone chỉ tồn tại lúc clone hiện hữu và luôn được dọn khi QTE kết thúc hoặc chuyển map.

- Các cảnh chính của route Map022–Map026, scare Map028, vòng vây Map034 và chase Map029 dùng balloon để bổ trợ camera/character effect. Balloon không thay thoại: nó chỉ đánh dấu phản ứng đã có như nghi vấn, giật mình, ngượng, tức giận, im lặng và phát hiện manh mối. Chase phát balloon trực tiếp từ manager khi clone xuất hiện, Hải Quỳ đánh trúng hoặc nhập QTE sai.
- Map025 phải giữ kích thước map `17×13` khớp bảng tile `17×13`. Khai báo cũ `22×20` khiến KUL Core đọc ngoài bảng dữ liệu và lỗi `nil >> 8` khi chase kết thúc.
- Kế hoạch đã triển khai nằm tại [map025-post-chase-plan.md](map025-post-chase-plan.md). Đoạn clone mở đầu đã tách khỏi Map029 sang Map034; Map029 chỉ còn gameplay. Map025 đã bỏ câu Aira tự viết, dùng nguyên văn đoạn đối đầu Cảnh số 5 và chủ động dừng ở màn hình đen tại điểm nguồn chưa xác định rõ bước nối.
- Điểm nối sau Map025 đã được xác nhận lại từ phần `Rượt đuổi` trong DOCX: Map025 chuyển sang Map035 dùng `HQ_Room_Midnight_Base`; Hải Quỳ nằm trên giường bằng charset `$HaiQuy_Sleep_Night`. Sau đối thoại Oni Onii, Group Chat phải chạy và đóng hoàn toàn rồi mới mở khóa/hiện Gallery ID 9 `EDRuotDuoi`, sau đó tới Map036. Map036 phát lời bình Bully Quỳ từ `AFTER ENDING HINT.docx` và trở về Title với `EDRuotDuoi` làm nền trong phiên hiện tại.
- Paulie/OniOnii dùng charset `Graphics/Characters/$test.png`, index 0 tại Map025 và Map035.
- Event thoát của Map028 chỉ được đổi destination từ Map029 sang Map034; tile, kích thước và các event khác của Map028 không bị chỉnh trong thay đổi này.
- Đây là bản playtest dùng tile/monster RTP. Graphic và layout production sẽ thay sau khi duyệt cảm giác chơi.

## Map023 — Tiệm Sách Thời Gian Lay Đọng

- Map dùng `Old_Book_Shop_Base` và layer `Old_Book_Shop_Top`, kích thước 30×40; toàn bộ tọa độ từ `TƯƠNG TÁC TIỆM SÁCH CŨ.docx` được đặt với quy ước `y - 1`.
- Có 54 event: E001 là cảnh vào tiệm; E002 là chủ tiệm và Pop Message/camera anchor; E003 là ô quầy thứ hai dùng chung tiến độ với E002; các event còn lại là sách, đồ vật, cửa và lore đúng tài liệu.
- Ba lần tương tác chủ tiệm dùng Variable 34. Hải Quỳ dùng `\bm[0]`, chủ tiệm dùng `\bm[2]`; CE1/CE2/CE3 điều khiển camera theo hệ thống preset.
- Hai lựa chọn sách ghi Variable 31: `1` là Ma Vương Cổ Đại cho Hakase, `2` là Phép Thuật Dịch Chuyển cho Shylvie. Chọn sách chưa tự bật `ATL_END_READY`.
- Bốn ô quả địa cầu dùng chung Variable 35 để chạy chuỗi câu theo yêu cầu tài liệu, bất kể người chơi bắt đầu ở ô nào.
- Các cửa phòng bà lão, nhà vệ sinh và thư viện hiện mới là tương tác mô tả; tài liệu chưa chỉ định map đích nên không tự tạo transfer.
- Cảnh chủ tiệm lần ba đã dựng đến chỉ dẫn “chuyển đến cảnh 12”, nhưng chưa transfer sang Map024 vì Map024 hiện là cảnh ký ức/chase từ lá thư, không phải đích cảnh 12 của vụ nổ tiệm sách.

## Cần quyết định trước khi viết tiếp

1. Route đầu tiên đã chốt là ending Atlantis; Map023 đã có `Old_Book_Shop_Base/Top` và scene đến tiệm, nhưng chưa có event chủ tiệm/tìm sách.
2. Map003, Map006, Map007 và Map017 đã được kiểm kê/đặt tên event; tiếp tục review map playable kế tiếp.
3. Gắn scene ID cho event quan trọng ở Map013/Map019 sau khi map tuần tự được kiểm kê.
4. Sau đó mới cấp flag/variable route chính thức.
