# Danh mục công dụng và tác giả

Slot bên dưới theo runtime zero-based. Link trực tiếp tới từng file nằm trong [runtime-inventory.md](runtime-inventory.md). Phiên bản ghi trong header là phiên bản nền; các script đã được chỉnh cho WCF có thể khác bản gốc dù giữ nguyên nhãn phiên bản.

## Script chuẩn VX Ace

Các nhóm `Vocab`, `Sound`, `Cache`, `DataManager`, `SceneManager`, `BattleManager`; `Game_*`; `Sprite_*`, `Spriteset_*`; `Window_*`; `Scene_*` và `Main` là cấu trúc chuẩn VX Ace của Enterbrain/KADOKAWA. Danh sách từng slot được giữ đầy đủ trong inventory, gồm cả code chuẩn đã chỉnh cho WCF như balloon của `Sprite_Character`.

Những lớp này là điểm mở rộng của script bổ sung. Không thay chúng bằng bản stock để “làm sạch” vì có thể xóa patch hiện tại. `Main` phải chạy sau khi toàn bộ class/patch đã được định nghĩa.

Ngày 15/11/2026, `Game_Map` (slot 31) được sửa để các truy vấn event không tạo bản sao mảng toàn bộ event. KUL Graphics, Custom Menu, MOG Weather và Text Over Event cũng có bản tối ưu/cleanup WCF; chi tiết tại [báo cáo hiệu năng](performance-audit-2026-11-15.md).

## Thư viện nền và lighting

| Slot | Script | Tác giả/phiên bản nền | Công dụng và dependency |
|---:|---|---|---|
| 127 | Basic__Module | Yami; cập nhật 2012-04-27 | Yami Engine Ace Basic Module; helper và nạp notetag. Đây là Yami, khác Yanfly |
| 128 | victor module | Victor Sant | Victor Engine Basic Module; phải đứng trước fog và animation settings |
| 136 | Victor Engine - Animations Settings | Victor Sant; 1.01 | Tùy chỉnh animation qua tag, cần Victor Basic Module 1.35+; load trước MOG Anti Animation Lag |
| 129 | XS Core | Nicke; 2.1f | XaiL System Core, màu và helper UI; chưa có bằng chứng đủ để gỡ bỏ an toàn |
| 130 | Yanfly Core Engine | Yanfly | Core engine, cấu hình hiển thị và các sửa nền |
| 177 | KUL Core Library | Nilo K. / Khas; 1.03 | Thư viện nền; trước Graphics Library và Ultra Graphics |
| 178 | KUL Graphics Library | Khas; 2.0 | Bridge native KGL, cần `System/KGL2.klib`; cấu hình 640×480 |
| 179 | KUL Graphics | Khas; 1.00, header Ultra Graphics | Lighting/shadow, preset đèn WCF và Region height; phụ thuộc 177/178 |
| 180 | KUL Graphics Menu Add-on | Khas; 1.00 | **Tắt** bằng comment; giữ để tham khảo, không tham gia menu hiện tại |
| 181 | KUL Item Lantern Add-on | Khas; 1.00 | Đèn vật phẩm, Switch 19; chỉ hoạt động khi điều kiện lantern thỏa mãn |
| 182 | KUL Fog Add-on | Khas; 1.00 | Fog tích hợp KUL, Switch 4 và notetag fog |

## Camera, chuyển động và map

| Slot | Script | Tác giả/phiên bản nền | Công dụng và dependency |
|---:|---|---|---|
| 122 | Theo Anti Lag | TheoAllen; 1.1 | **Tắt** toàn bộ phần code; chưa bật tối ưu event/sprite |
| 123 | MOG character effect | Moghunter; Character EX 1.2 | Hiệu ứng angle, zoom, nhấp nháy trên charset; WCF dùng cho cảnh rơi |
| 125 | Followers | Hime; 2014-03-31 | Event theo một leader, API `follow`/`stop_follow`; thân code vẫn chạy dù header ở comment |
| 132 | Stairs Movement | Project/custom; header không ghi tác giả | Region 63, đi cầu thang và toggle cho cutscene |
| 134 | Mog Event sensor range | Moghunter; 1.0 | Sensor khoảng cách, đổi Self Switch B; cần phân biệt với sensor riêng của mê cung WCF |
| 135 | Lune Smooth Camera Sliding | Raizen | Camera trượt; `set_camera_focus`; có mặt trong đường fallback của Enhanced Camera |
| 139 | parallax lock yanfly | Yanfly | Khóa parallax theo tile/full lock; tên file không phải tên class riêng |
| 140 | animated parallax | modern algebra; 1.0 | Chạy chuỗi ảnh parallax theo hậu tố frame |
| 145 | Pathfinder | TheoAllen; A* 1.0 | `find_path`, tìm đường theo tile và hỗ trợ map loop |
| 146 | Dash Control | IXFURU | Cấu hình dash; header yêu cầu credit IXFURU |
| 151 | Stop Movement | Yanfly; 1.00 | Khóa NPC/player bằng Switch 238/239 |
| 161 | Yanfly Event Chase Player | Yanfly | Event đuổi/tránh player và alert; không thay cho manager clone WCF |
| 163 | Yanfly Force Move Titles | Yanfly | Tên gốc Force Move Tiles; cưỡng bức chuyển động theo địa hình/notetag |
| 164 | Yanfly Slippery Titles | Yanfly | Tên gốc Slippery Tiles; trượt trên tile được cấu hình |
| 165 | Yanfly NPC Move Restrict | Yanfly | Giới hạn bước đi NPC/player theo Region |
| 202 | Galv's Cam Slide Control | Galv; 1.0 | **Tắt** bằng comment; không tính như một camera đang tranh quyền |
| 204 | Enhanced Camera | Maker Systems / RPG Maker Source; 1.0.2 | Focus nhân vật/tọa độ, easing, camera cutscene; hỗ trợ script call `ms_pro_cam_*` |
| 205 | The Art of Screenshake | TheoAllen | `shake_screen(duration,power)`; game đã có cả rung riêng của mê cung |

## Layer, particle, weather và picture

| Slot | Script | Tác giả/phiên bản nền | Công dụng và dependency |
|---:|---|---|---|
| 124 | Pictures under characters | Woratana; 1.0, có ghi chú Kread/Mithran | Picture ID 30–35 xuống dưới character; liên quan viewport của Fixed Pictures |
| 133 | MOG_Weather_EX | Moghunter; 2.1 | Weather bằng sprite, lưu dữ liệu thời tiết qua scene |
| 138 | Galv's Layer Graphics | Galv; 1.3 + WCF fixes | Overlay/parallax layer theo map; dùng rộng rãi cho bàn tiệc, ký ức và background top |
| 141 | anti-animation lag | Moghunter; 1.0 + WCF fixes | Hoãn hủy bitmap animation; cần giữ reference count khi dọn hàng đợi |
| 142 | victor fog | Victor Sant | Fog bằng plane, phụ thuộc Victor Basic Module |
| 143 | Galv Char effect | Galv; 2.1 | Shadow/reflection/icon của character; Region 1 có chức năng riêng |
| 147 | Picture bug | Mithran; 2012-03-12 | Tránh tạo bitmap rỗng liên tục, dọn picture bị erase |
| 148 | Fixed Pictures | modern algebra; 1.0.2 | Picture theo tọa độ map và Z; Switch 98, Variable 6 |
| 149 | Map Effects User Guide | Hướng dẫn đi kèm Zeus81 | **Tài liệu**, không có code chạy |
| 150 | Map effects | Zeus81; 1.4.1 | Zoom/blur/wave/tone ở viewport tổng hợp; cần phối hợp với KUL |
| 174 | Yanfly Flip Pictures | Yanfly | Lật picture bằng cấu hình và Switch 21 |
| 184 | Terrain and Region Effects | Neon Black; 1.0a | SE/hiệu ứng bước chân theo terrain/Region, CC BY 3.0 trong header |
| 185 | Galv's Region Effects | Galv; 1.9 | **Tắt** bằng comment; từng sinh hiệu ứng theo Region, có credit Yanfly/Quack |
| 186 | Text Over Event | TheoAllen; 1.0 | Nhãn trên event từ tên `<text: ...>` |
| 188 | HP Bar Over Player | TheoAllen; 1.0 | Thân chức năng thanh HP đang nằm trong comment; chỉ còn gán cờ `$imported[:Theo_MapHP]` chạy |
| 189 | Particles | Dekita; 1.0 + WCF fix | Particle sprite/cache và lifecycle theo scene; header nhắc D13x Core 2.5+ |
| 190 | Particles Weather | Dekita; 1.0 | Weather dựa trên Particle_Core của slot 189 |

## Message, menu, Title và công cụ

| Slot | Script | Tác giả/phiên bản nền | Công dụng và dependency |
|---:|---|---|---|
| 153 | Disable key | Chainsawkitten; 1.1 | **Tắt** phần hook native F1/Alt+Enter/F12 |
| 154 | Map Screenshot | Hime; 2015-09-25 | Công cụ chụp map, có tùy chọn layer/region/passage |
| 156 | Yanfly Message System | Yanfly | Ace Message System, escape code/namebox/kích thước message |
| 157 | Yanfly Message System addon | Yanfly; Actor Codes 1.01 | Escape code actor, cần Message System 1.03+ |
| 158 | Yanfly Adjust Limits | Yanfly; 1.00 | Điều chỉnh giới hạn hệ thống/database theo cấu hình |
| 159 | Galv's Double Message | Galv; 0.5, header ghi incomplete release | Message bổ sung và skip; Switch 1 khóa skip |
| 162 | Yanfly Event Popup | Yanfly | Popup ngoài map; WCF queue thông báo unlock CG/tin nhắn qua hệ này |
| 166 | Yanfly Gabwindow | Yanfly | Cửa sổ thoại ngắn; Switch 25 ẩn |
| 168 | Yanfly Menu Engine | Yanfly; có sửa bởi Doogy | Menu nền, một phần UI được điện thoại WCF thay thế |
| 169 | Yanfly Save Engine | Yanfly | Save UI và metadata; giữ tương thích phần save/load của điện thoại |
| 170 | Yanfly Window Icons | Yanfly; 1.00 | Icon trong command window |
| 171 | Yanfly Menu Cursor | Yanfly; 1.00 | Cursor UI; không mặc nhiên coi là đã tắt chỉ vì menu chính dùng điện thoại |
| 172 | Yanfly System Option | Yanfly | Âm lượng, autodash, message speed và option hệ thống |
| 192 | MOG_T_Logo | Nền MOG theo tên/lịch sử WCF; header hiện đã viết lại | Intro logo Salt_Pebbles và chuỗi logo; cần giữ ghi nhận Moghunter và phần sửa WCF |
| 193 | MOG_T_Particles | Moghunter; 1.1 | Particle của Title, độc lập Dekita Particles |
| 194 | MOG_T_Name | Nền MOG theo tên/lịch sử WCF; header hiện đã viết lại | Foreground Title và easter egg `HaiQuy.txt` |
| 195 | MOG_Picture_Gallery | Moghunter; 2.0 | Gallery nền tảng; registry/global unlock nằm thêm trong Custom Menu |
| 196 | Move the Menu | Header không ghi tác giả | Đặt Window_TitleCommand tại `(240,320)` |
| 197 | Cutscene Group Chat | Project/custom; header không ghi tác giả | Chat điện thoại trong cutscene, choice và branch |
| 198 | Custom Menu | Project/custom; tích hợp MOG Gallery và patch WCF | Menu điện thoại, Contacts, timeline, Gallery, saved chat và thông báo; [bố cục/cleanup mới](phone-ui-review-2026-11-15.md) |
| 201 | Easy Script Importer-Exporter | KK20; 4.0 | Công cụ export/import; runtime và export đều đặt mode 0 |
| 203 | Pop Message | Yami; cập nhật 2013-01-29 + WCF patches | Bubble bám target, face phụ, đo chữ tiếng Việt và cleanup qua scene |
| 206 | Transform Form Selection | Project/custom; header không ghi tác giả | Bốn dạng TFCard1–4, Variable 4; animation 125 → chọn dạng → 127 |
| 210 | Multi Switch Condition Helper | Project/custom; header không ghi tác giả | Helper điều kiện switch; cần kiểm tra script call trước khi đổi API |
| 218 | WCF Storage Memory Transition | WCF/custom; header không ghi cá nhân | Sàn kho vỡ, parallax rời màn hình, sprite rơi/xoay và cleanup |
| 219 | WCF Test Hub | WCF/custom; header không ghi cá nhân | Seed checkpoint, route flags, sprite, KUL và toàn bộ điện thoại |

## Minigame và manager riêng của WCF

| Slot | Script | Nguồn gốc | Công dụng |
|---:|---|---|---|
| 199 | BulletHell | Custom merged WCF; header không đủ để xác nhận toàn bộ nguồn nền | Invader mini game, wave/enemy/projectile và state chết/chơi lại |
| 200 | Random Event Patch | Custom merged; header gọi “Galv Invader”, cần xác minh bản gốc | Bổ sung event ngẫu nhiên cho BulletHell, gravity well và gimmick |
| 209 | Catto Petting Minigame | Project/custom; header không ghi cá nhân | Vuốt mèo; Variable kết quả 0 nghĩa là chưa ghi ra database |
| 211 | Atlantis Shrimp Fishing | WCF/custom; header không ghi cá nhân | Câu tôm lấy cà phê Atlantis |
| 213 | Atlantis Mirror Maze Chase | WCF/custom; header không ghi cá nhân | Manager mê cung/clone/choáng/bẫy, chase QTE và overlay quái vật/cutscene Atlantis |
| 214 | WCF Snowball Rhythm | WCF/custom; header không ghi cá nhân | Bốn đối thủ ném tuyết, composite layer bàn tiệc và phần thưởng RAM |

Không gán toàn bộ script custom cho Codex, Galv hoặc một tác giả khác chỉ dựa vào tên file. Hai module Invader cần tìm lại bản script nguồn nếu chuẩn bị danh sách credit phát hành.
