# Flags and variables

Switch/Variable là global. Các tên route dưới đây chỉ là tên tài liệu, chưa phải ID runtime.

| Loại | ID | Sử dụng |
|---|---:|---|
| Switch | 1 | Galv Double Message: khóa skip |
| Switch | 3 | Map015 toilet; điều kiện page Map013 — conflict |
| Switch | 4 | KUL Fog; Map019 — conflict |
| Switch | 17/18 | KUL light/ultra-light |
| Switch | 19 | KUL lantern; Map019 — conflict |
| Switch | 21/25/94/98/99 | Flip Pictures/Gabwindow/Region Effects/Fixed Pictures/Event Popup |
| Switch | 238/239 | Stop Movement NPC/player |
| Variable | 4 | Transform Form Selection; Map008/Map013 — conflict |
| Variable | 6 | Fixed Pictures Z |
| Variable | 19/20 | BulletHell score/high score; Variable 20 Map019 — conflict |
| Variable | 0 | Catto result disabled |
| Variable | 40 | Common Event camera target event; Map001 cũng dùng |

Map hiện dùng thêm Switch 2, 5–8; Variable 1–4 và 40. Không tái sử dụng trước khi rà toàn bộ event.

Region/terrain:

- Region 1: Pathfinder safe zone và Galv Char Effect mirror wall.
- Region 63: Stairs Movement.
- Terrain/region effects đọc note tag `<terrain N se>` và `<region N se>`.
- Mog Event Sensor Range dùng self switch B.

Flag route đề xuất, chưa ghi vào Database: `WCF_ROUTE_GROUP`, `WCF_GIFT_ID`, `WCF_RECIPIENT_ID`, `WCF_TALKED_LEO`, `WCF_TALKED_SHYLVIE`, `WCF_ATLANTIS_OWNER`, `WCF_GIFT_WRAPPED`, `WCF_PARTY_STARTED`.

## Route Atlantis — trạng thái thiết kế mới

| ID hiện tại | Tên ngắn | Ý nghĩa |
|---:|---|---|
| Switch 30 | `ATL_CHOSEN` | Người chơi chọn xuống Atlantis |
| Switch 31 | `ATL_ARRIVED` | Đã tới khu vực Atlantis |
| Switch 32 | `ATL_OWNER_MET` | Đã gặp chủ tiệm/seller |
| Switch 33 | `ATL_END_READY` | Đủ điều kiện ending Atlantis |
| Switch 34 | `ATL_READ_LETTER` | Đã đọc thư/tin dẫn vào route |
| Switch 35 | `ATL_CHASE_STARTED` | Đã kích hoạt cảnh chase |
| Switch 36 | `ATL_CHASE_CLEARED` | Đã hoàn tất chase |
| Variable 30 | `ATL_STEP` | Tiến độ route Atlantis |
| Variable 31 | `ATL_BOOK_ID` | Sách đã chọn (1=Ma Vương, 2=dịch chuyển) |
| Variable 41 | `ENDING_HINT_ID` | Router Map036; `1` = Atlantis route rượt đuổi |

## Nhà và phòng kho Hải Quỳ — runtime hiện tại

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Switch | 37 | `HQ_KEY_HINT_READY` | Đã kiểm tra cửa kho đủ ba lần |
| Switch | 38 | `HQ_STORAGE_KEY` | Đã lấy chìa khóa ở tủ nhang |
| Switch | 39 | `HQ_STORAGE_LIGHT` | Đã bật đèn phòng kho |
| Switch | 40 | `HQ_HOME_FORM_CHANGED` | Đã xem album và đổi sang dạng ở nhà |
| Switch | 41 | `HQ_MEAL_DONE` | Đã hoàn thành cutscene pha mì |
| Switch | 42 | `HQ_STORAGE_LETTER_READ` | Đã đọc lá thư trong phòng kho |
| Switch | 43 | `HQ_MEMORY_CHASE_READY` | Đã kết thúc đoạn ký ức, sẵn sàng sang map gương |
| Variable | 32 | `HQ_TAPE_ID` | 0=không giữ băng; 1=Paulie; 2=bánh mì; 3=xích đu |
| Variable | 33 | `HQ_STORAGE_BOX_STEP` | Số lần đã kiểm tra chuỗi thùng, 0–3 |
| Variable | 34 | `ATL_OWNER_STEP` | Tiến độ ba lần tương tác với chủ tiệm Map023 |
| Variable | 35 | `ATL_GLOBE_STEP` | Tiến độ chuỗi bốn câu ở quả địa cầu Map023 |

## Route siêu thị

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 42 | `MKT_GIFT` | `1` máy pha cà phê, `2` dao/chảo, `3` đồ đan, `4` bộ phá khóa |
| Variable | 43 | `MKT_TARGET` | `1` Leo, `2` Kohi, `3` Shylvie, `4` Hakase |
| Variable | 44 | `MKT_STAGE` | Tiến độ chung: chọn quà, chat, chuẩn bị, tiệc, epilogue |
| Switch | 44 | `MKT_ACTIVE` | Đã chọn một món quà tại Map019 |
| Switch | 45 | `MKT_PARTY_DONE` | Đã hoàn tất cảnh tiệc của route siêu thị |
| Switch | 46 | `MKT_END_UNLOCK` | Đã mở khóa ending của tổ hợp hiện tại |
| Variable | 41 | `ENDING_HINT_ID` | `2 + (MKT_GIFT-1)*4 + (MKT_TARGET-1)`; dải `2..17` cho đủ 16 tổ hợp quà/người nhận |
| Switch | 47 | `MKT_PARTY_CONTINUE` | Leo kích hoạt phần còn lại của cutscene Map038; được tắt ngay khi E007 bắt đầu |
| Switch | 48 | `MKT_FREE_EXPLORE` | Cho phép điều khiển Hải Quỳ và tương tác NPC trong tiệc Giáng sinh |
| Variable | 45 | `SNOWBALL_RESULT` | Kết quả gần nhất: `-1` thua, `0` bỏ trận, `1` thắng |
| Variable | 46 | `SNOWBALL_WINS` | Bitmask đối thủ đã thắng: `1` Shylvie, `2` Kohi, `4` Leo, `8` Hakase; đủ bốn người = `15` |
| Switch | 49 | `SNOWBALL_ALL_CLEAR` | Tự bật khi `SNOWBALL_WINS == 15`; dùng làm điều kiện nhận phần thưởng sau này |
| Switch | 50 | `MKT_BUS_ARRIVAL` | Map010 chỉ bật ở lựa chọn tới siêu thị; Map019 E044 dùng để chạy cảnh xe bus rời sang trái rồi tự tắt |
| Switch | 51 | `MKT_BULLY_ACTIVE` | Map037 bật khi Aira/Bully Quỳ tiếp quản; Map038 dùng để chọn CG7 thay CG6 trong cảnh bị vùi tuyết rồi tự tắt trước free explore |
| Switch | 52 | `MKT_COFFEE_READY` | ON = đã câu đủ 10 tôm vàng và lấy cà phê Atlantis; OFF = chọn mang cà phê thường về chuẩn bị quà |

Các ID 42–46 được chọn sau vùng flag Atlantis/HQ đang dùng và không trùng cấu hình script đã kiểm kê. Switch và Variable có cùng số là hai bảng độc lập; ở đây vẫn cố tình dùng dải khác nhau theo chức năng để dễ đọc.

Variable 40 vẫn chỉ dùng làm target Event ID cho Common Event camera. Switch 40 là một ô dữ liệu khác nên không xung đột với Variable 40. Variable 34/35 không xung đột với Switch 34/35 vì hai bảng dữ liệu độc lập.

## Phòng riêng Văn phòng Wanderer

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 47 | `WANDERER_ROOM_CODE_A` | Tám chữ số đầu của mã tủ phòng Hải Quỳ; biến nhập tạm |
| Variable | 48 | `WANDERER_ROOM_CODE_B` | Tám chữ số cuối của mã tủ phòng Hải Quỳ; biến nhập tạm |
| Variable | 49 | `WANDERER_OFFICE_RETURN_MAP` | Ghi Map013/038/039/048/050/052/054 trước khi vào phòng dùng chung; Map061–063 dùng giá trị này để trả player về đúng phiên bản văn phòng nguồn |
| Switch | 53 | `WANDERER_RAM_FOUND` | Đã lấy thanh RAM dưới giường Kohi |
| Switch | 54 | `WANDERER_RAM_INSTALLED` | Đã lắp thanh RAM vào khe trong phòng Hakase |

Ánh sáng phòng Shylvie chỉ dùng Self Switch A của Map043 E003 để chọn parallax, không chiếm switch global.

## Route mì cay cho Leo

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 50 | `NOODLE_BRANCH` | `1` tin Aira/Aira nấu; `2` Hải Quỳ tự phân tích và nấu |
| Variable | 51 | `NOODLE_STAGE` | `0` vừa chọn route; `1` montage siêu thị; `2` chuẩn bị; `3` nấu; `4` free roam; `5` tiếp tục tiệc; `6` hoàn tất |
| Switch | 55 | `NOODLE_ACTIVE` | Route đang chạy; làm điều kiện autorun Map020/019/047/014 và page route mì cay trên Map038 |
| Switch | 56 | `NOODLE_AIRA_CONTROL` | Nhánh Aira kiểm soát cơ thể; giữ riêng để dùng cho visual mở rộng |
| Switch | 57 | `NOODLE_DONE` | Đã hoàn tất tiệc và rời đi làm nhiệm vụ |
| Switch | 58 | `NOODLE_FREE_EXPLORE` | Giữ E001 ở page trống và mở page Leo riêng trong thời gian khám phá/ném tuyết trên Map038 |
| Switch | 59 | `NOODLE_PARTY_CONTINUE` | Leo kết thúc free roam và kích hoạt E118 phần sau của tiệc mì cay |
| Variable | 41 | `ENDING_HINT_ID` | `18` = Best Ending route mì cay cho Leo |

## Route sách dịch chuyển cho Shylvie

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 52 | `ATL_BOOK_SHY_STAGE` | `1` checkout; `2` chuẩn bị xong; `3` free roam; `4` tiếp tục tiệc; `5` trao quà xong; `6` hoàn tất |
| Switch | 61 | `ATL_BOOK_SHY_ACTIVE` | Route sách Shylvie đang chạy; điều kiện Map049/038/050 |
| Switch | 62 | `ATL_BOOK_SHY_FREE_EXPLORE` | Page free roam riêng trên Map038 |
| Switch | 64 | `ATL_BOOK_SHY_PARTY_CONTINUE` | Leo kết thúc free roam và kích hoạt Map038 E119 |
| Switch | 65 | `ATL_BOOK_SHY_DONE` | Đã hoàn tất hậu truyện |

Switch 63 thuộc `Grid Coords`; route này cố ý bỏ qua ID 63 và không dùng Control Switches theo dải 61–65.

## Route sách Ma Vương Cổ Đại cho Hakase

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 53 | `ATL_BOOK_HAK_STAGE` | `1` checkout; `2` chuẩn bị xong; `3` free roam; `4` tiếp tục tiệc; `5` trao quà xong; `6` hoàn tất |
| Switch | 66 | `ATL_BOOK_HAK_ACTIVE` | Route sách Hakase đang chạy; điều kiện Map051/038/052 |
| Switch | 67 | `ATL_BOOK_HAK_FREE_EXPLORE` | Page free roam riêng trên Map038 |
| Switch | 68 | `ATL_BOOK_HAK_PARTY_CONTINUE` | Leo kết thúc free roam và kích hoạt Map038 E120 |
| Switch | 69 | `ATL_BOOK_HAK_DONE` | Đã hoàn tất hậu truyện |
| Variable | 41 | `ENDING_HINT_ID` | `20` = hint B2746–B2760 sau hậu truyện Ma Vương Cổ Đại |

## Route nói với chủ tiệm sách trước

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 54 | `ATL_OWNER_ABYSS_STAGE` | `1` rời tiệm sách; `2` tự phong ấn; `3` Wanderer bắt đầu cứu viện; `4` hoàn tất giải cứu |
| Switch | 70 | `ATL_OWNER_ABYSS_ACTIVE` | Giữ autorun xuyên Map053–055; tắt trước khi sang ending hint |
| Switch | 71 | `ATL_OWNER_ABYSS_DONE` | Đã hoàn tất ending tạo vật Vực Sâu |
| Variable | 41 | `ENDING_HINT_ID` | `21` = cuộc trò chuyện Drosalya/Bully Quỳ B2761–B2809 |

## Route hỏi Leo

| Loại | ID | Tên runtime | Ý nghĩa |
|---|---:|---|---|
| Variable | 55 | `LEO_SHOP_BRANCH` | `1` cà phê Luminous/Kohi; `2` viên đá–khiên/Shylvie; `3` áo choàng tàng hình/Hakase |
| Variable | 56 | `LEO_SHOP_STAGE` | `1` rời Map013; `2` đã mua quà; `3` vào tiệc; `4` free roam; `6` hoàn tất |
| Switch | 72 | `LEO_SHOP_ACTIVE` | Giữ autorun xuyên Map056–060 và page mở đầu riêng trên Map038 |
| Switch | 73 | `LEO_SHOP_FREE_EXPLORE` | Mở free roam và ném tuyết trên Map038 |
| Switch | 74 | `LEO_SHOP_PARTY_CONTINUE` | Leo kết thúc free roam và kích hoạt Map038 E121 |
| Switch | 75 | `LEO_SHOP_DONE` | Đã hoàn tất nhánh hỏi Leo |
| Variable | 41 | `ENDING_HINT_ID` | `22` cà phê; `23` khiên; `24` áo choàng/Drosalya |

Map056 chỉ route ba giá trị tường minh: `1 → Map058`, `2 → Map059`, `3 → Map057`; trạng thái khác sẽ mở lại lựa chọn thay vì mặc định sang ma thuật. Map057/058/059 lần lượt chuẩn hóa Variable 55 thành `3/1/2` ngay đầu autorun. Không đặt điều kiện Variable 55 trên page autorun của các map này: bản thân map đích đã xác định duy nhất nhánh, còn điều kiện lặp lại có thể làm cutscene bị khóa nếu dữ liệu lựa chọn chưa kịp ghi.

Các state mới khác cần cấp ID riêng sau khi map được tách: `ATL_READ_LETTER`, `ATL_BOOK_ID`, `ATL_CHASE_STARTED`, `ATL_CHASE_CLEARED`. Không dùng lại Variable 2/3/4/20/40 cho các state này.
