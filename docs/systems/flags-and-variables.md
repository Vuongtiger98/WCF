# Flags, variables và điều kiện event

## Nguyên tắc

Switch/Variable trong bảng này là tài nguyên global. Không tái sử dụng ID chỉ vì nó “chỉ dùng ở một map”. Các tên route như `READ_MOMO_MESSAGE` là tên tài liệu, chưa phải switch runtime.

## Runtime script registry

| Loại | ID | Chủ thể | Ghi chú |
|---|---:|---|---|
| Switch | 1 | Galv Double Message | Disable skip |
| Switch | 4 | KUL Fog | Fog toggle; Map019 cũng dùng |
| Switch | 17/18 | KUL Graphics | Light/ultra-light |
| Switch | 19 | KUL Lantern | Lantern; Map019 cũng dùng |
| Switch | 21/25/94/98/99 | Yanfly/KUL/Galv/Fixed Pictures | Xem `05-technical-scripts.md` |
| Switch | 238/239 | Stop Movement | NPC/player lock |
| Variable | 4 | Transform Form Selection | Không dùng chung với route |
| Variable | 6 | Fixed Pictures | Picture Z |
| Variable | 19/20 | BulletHell | Score/high score |
| Variable | 0 | Catto Petting | Tắt ghi kết quả |

## Map usage đã đọc

| ID | Map/event usage |
|---:|---|
| Switch 2 | Map003 event conditions/control |
| Switch 3 | Map013 page conditions; Map015 Smart Toilet |
| Switch 4–8 | Map019 shop/event logic |
| Switch 19 | Map019 event 43 |
| Variable 1 | Map003 |
| Variable 2/3/4 | Map013; Variable 4 còn Map008 |
| Variable 20 | Map019 event 4 |
| Variable 40 | Map001 event 15 |

## Route flag đề xuất

Chưa ghi vào project. Khi route đầu tiên được duyệt, tạo registry theo namespace, ví dụ `WCF_ROUTE_*`, thay vì dùng ID rời rạc:

```text
WCF_ROUTE_GROUP        — nhóm route đã chọn
WCF_GIFT_ID            — món quà
WCF_RECIPIENT_ID       — người nhận
WCF_TALKED_LEO         — đã hỏi Leo
WCF_TALKED_SHYLVIE     — đã hỏi Shylvie
WCF_ATLANTIS_OWNER     — đã nói với chủ tiệm
WCF_GIFT_WRAPPED       — đã hoàn thiện quà
WCF_PARTY_STARTED      — đã vào tiệc
```

Các flag này cần được ánh xạ sang ID thật sau khi kiểm kê toàn bộ Database.

