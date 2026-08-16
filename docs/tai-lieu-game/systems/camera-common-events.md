# Camera và Common Events

Common Events 1–10 là bộ effect/camera dùng lại. Common Events 12–18 điều khiển timeline điện thoại.

| ID | Tên | Chức năng |
|---:|---|---|
| 1 | CAM Zoom Player 130 | Focus player, zoom 130 trong 20 frame |
| 2 | CAM Zoom Event 130 | Đọc Variable 40 làm event ID, focus và zoom |
| 3 | CAM Reset Screen Effects | Reset zoom, tone, color, wave, pixelize, blur, weather và camera |
| 4 | FX Soft Dialogue Player | Focus player, zoom 120, tone nhẹ |
| 5 | FX Dramatic Event Focus | Đọc Variable 40, focus event, zoom/tone mạnh |
| 6 | FX Shock | Zoom/zoom blur nhanh |
| 7 | FX Horror Tension | Zoom 110, tone/color tối, gaussian blur |
| 8–10 | chưa đặt tên | Chưa có logic đáng kể |
| 12–17 | PHONE — Route timeline | Cập nhật ngày, giờ, địa điểm và pin từ Silver Wing tới tiệm sách Atlantis |
| 18 | PHONE — Christmas Gift | Mốc hội tụ trao quà: 25/12 lúc 19:00 |

## API đang được sử dụng

- Enhanced Camera: `ms_pro_cam_center_at`, `ms_pro_cam_center_at_char`, `ms_pro_cam_focus_on`, `ms_pro_cam_unlock_camera`, `ms_pro_cam_ignore_player`, `ms_pro_cam_wait_for_scrolling`, `ms_pro_cam_reset_str`.
- Map Effects: `map_effects.set_zoom`, `set_tone`, `set_color`, `set_wave`, `set_pixelize`, `setup_blur`, `set_gaussian_blur`, `set_zoom_blur`, `set_radial_blur`, `set_motion_blur`, `clear`.
- Mỗi Common Event dùng `trigger=0` (call từ event), không tự chạy theo switch.

## Đề xuất mở rộng

Tạo các Common Event chuẩn hóa theo vai trò, không theo map:

1. `CAM_FocusPlayer` — focus player, có tham số duration.
2. `CAM_FocusEventByVar40` — giữ Variable 40 làm target event tạm thời.
3. `CAM_FocusCoordinate` — focus tọa độ cố định cho cutscene.
4. `CAM_ResetAll` — dùng sau mọi cutscene hoặc khi player lấy lại quyền điều khiển.
5. `FX_DialogueSoft`, `FX_Dramatic`, `FX_Shock`, `FX_Horror` — preset hiệu ứng.

Không nên tạo thêm script camera mới ngay. Hãy gom preset vào Common Events, kiểm tra reset sau mỗi cutscene, rồi mới quyết định có cần mở rộng engine hay không.
