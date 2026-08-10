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

Variable 40 vẫn chỉ dùng làm target Event ID cho Common Event camera. Switch 40 là một ô dữ liệu khác nên không xung đột với Variable 40. Variable 34/35 không xung đột với Switch 34/35 vì hai bảng dữ liệu độc lập.

Các state mới khác cần cấp ID riêng sau khi map được tách: `ATL_READ_LETTER`, `ATL_BOOK_ID`, `ATL_CHASE_STARTED`, `ATL_CHASE_CLEARED`. Không dùng lại Variable 2/3/4/20/40 cho các state này.
