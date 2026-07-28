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
