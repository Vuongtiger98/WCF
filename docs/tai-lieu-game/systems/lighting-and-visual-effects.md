# Hệ thống ánh sáng và hiệu ứng hình ảnh

Tài liệu này mô tả các script đang có trong runtime RPG Maker VX Ace, phạm vi sử dụng phù hợp và các điểm dễ xung đột. Với cảnh tối có nguồn sáng thật, ưu tiên Khas Ultra Lighting; không dùng `Map Effects` hoặc `Tint Screen` để giả lập toàn bộ hệ thống ánh sáng.

## Khas Ultra Graphics / Ultra Lighting

Các slot liên quan được load liên tiếp theo thứ tự:

1. `KUL Core Library`: đọc tag/command trong note của map và comment của event; xây dữ liệu height/building phục vụ shadow.
2. `KUL Graphics Library`: lớp đồ họa và shader nền tảng.
3. `KUL Graphics`: hệ thống darkness overlay, light source động/tĩnh và bóng đổ. Asset nằm trong `Graphics/Lights`.
4. `KUL Graphics Menu Add-on`: đưa tùy chọn shadow, light size và light opacity vào menu cấu hình.
5. `KUL Item Lantern Add-on`: cho Player đổi nguồn sáng bằng item có note `[light ID]` khi nhấn Q.
6. `KUL Fog Add-on`: fog riêng của Khas, cấu hình bằng note map.

### Lệnh và tag chính

Trong note của map:

```text
[lighting on]
[opacity 235]
[color 000000000]
```

- `lighting on/off`: bật hoặc ẩn darkness overlay.
- `opacity 0..255`: độ tối; số càng cao thì vùng không có nguồn sáng càng tối.
- `color RRRGGGBBB`: màu ánh sáng môi trường theo ba nhóm ba chữ số. `000000000` tạo nền tối trung tính.

Trong comment đầu page của event nguồn sáng:

```text
[light torch]
[static]
[shadows]
```

- `[light ID]`: dùng cấu hình trong `Light_Core::Lights`.
- `[static]`: nguồn đứng yên, ít tốn hiệu năng hơn.
- `[dynamic]`: nguồn di chuyển/cập nhật shadow mỗi frame.
- `[shadows]` hoặc `[no_shadows]`: bật/tắt bóng do nguồn đó tạo.
- `[group name]`: gán nhóm ánh sáng nếu cần điều khiển opacity theo nhóm.

Script call cho nhân vật:

```ruby
$game_player.give_light("small")
$game_player.give_light("player_small")
$game_player.give_light("flashlight")
$game_player.drop_light
```

Script call điều khiển darkness:

```ruby
$game_map.shadows.set_color(0, 0, 0)
$game_map.shadows.set_opacity(235)
$game_map.shadows.set_opacity(0, 30)
```

Tham số thứ hai của `set_opacity` là thời gian chuyển đổi theo frame. Preset mới `player_small` dùng asset `small.png` 128×128 nhưng đặt `static: false`, nên ánh sáng và shadow cập nhật đúng khi Hải Quỳ di chuyển. `small` gốc là nguồn tĩnh, chỉ nên đặt trên event đứng yên; `flashlight` là đèn định hướng theo hướng quay của Player.

### ID cấu hình phải giữ

| Loại | ID | Tác dụng |
|---|---:|---|
| Switch | 17 | `Light_Sw`: ẩn toàn bộ light source nhưng vẫn giữ darkness overlay |
| Switch | 18 | `UlSys_Sw`: tắt toàn bộ Ultra Lighting |
| Switch | 19 | `Lantern_Sw`: cho phép dùng phím Q để đổi lantern từ item |
| Switch | 4 | `Fog_Sw`: ẩn Khas Fog |

Không dùng các switch này làm cờ cốt truyện. Switch 39 `HQ_STORAGE_LIGHT` là state riêng của phòng kho và không xung đột.

### Khi nào nên dùng

- Phòng tối, hang động, mất điện: darkness overlay cộng nguồn sáng theo Player.
- Đèn bàn, đèn đường, cửa sổ: light event dạng `static`.
- Đuốc, đèn pin, nhân vật phát sáng: light dạng `dynamic`.
- Cảnh cần bóng đổ theo vật cản: Khas height/building data và `shadows`.

## Galv Character Effects

Script này tạo bóng sprite của nhân vật theo một hoặc nhiều điểm sáng, reflection, mirror và icon. Nó không làm map tối và không tạo vùng sáng.

Các lệnh đáng chú ý:

```ruby
shadow_source(x, y, id)
shadow_source(event_id, id)
shadow_options(80, 10, false)
shadow(event_id, true)
actor_shadows(true)
```

Chỉ dùng khi cần bóng nhân vật kiểu sprite đơn giản. Không bật đồng thời bóng Galv và bóng Khas cho cùng một cảnh nếu không chủ ý, vì nhân vật có thể xuất hiện hai bóng.

## Map Effects

`Map effects` chụp màn hình map rồi áp dụng hậu kỳ: zoom, tone, color, blur, wave, pixelize và motion blur. Nó phù hợp với camera/cutscene, ký ức, glitch và chuyển cảnh; không phải hệ thống nguồn sáng.

Ví dụ:

```ruby
map_effects.set_tone(-80, -80, -80, 0, 30)
map_effects.setup_blur(8, 100, -1, 12)
map_effects.clear
```

Không dùng tone tối của Map Effects chồng lên Khas darkness trong gameplay, vì vùng sáng Khas cũng bị hậu kỳ làm tối và không còn đọc rõ. Common Event camera hiện vẫn dùng Map Effects cho zoom/blur/tone ngắn hạn.

## Tint Screen mặc định

`$game_map.screen.start_tone_change(Tone.new(...), frames)` hoặc event command `Tint Screen` đổi tone toàn viewport. Phù hợp với thời gian trong ngày hoặc fade màu toàn cảnh. Giống Map Effects, nó không tạo light source và sẽ nhuộm cả vùng sáng Khas.

## Fog và weather

- `KUL Fog Add-on`: fog tích hợp với Khas, note map `[fog simple]`; phù hợp map đang dùng Ultra Lighting.
- `Victor Fog`: nhiều layer fog độc lập, tone và chuyển động; dùng cho map không phụ thuộc Khas fog hoặc cần cấu hình phức tạp.
- `MOG Weather EX`: weather trang trí mở rộng trên map/battle.
- `Particles` + `Particles Weather`: particle tùy biến như mưa, glow, meteor và fire rain.
- Weather mặc định VX Ace: rain, storm, snow qua `Change Weather`.

Không bật nhiều hệ weather/fog cho cùng một hiệu ứng. Chúng cùng tạo sprite/viewport layer, làm tăng chi phí render và có thể sai Z-order với parallax, Fixed Pictures và Khas overlay.

## Áp dụng tại Map026 — phòng kho Hải Quỳ

- Note map bật Khas Lighting với opacity 235 và nền tối trung tính.
- Nếu Switch 39 OFF, E001 gắn light `player_small` vào Hải Quỳ; chỉ vùng nhỏ quanh Player nhìn thấy được.
- E014/E015 bật Switch 39, bỏ light khỏi Player và fade darkness từ 235 về 0 trong 30 frame.
- Nếu quay lại khi Switch 39 đã ON, E001 giữ phòng sáng và không gắn lại player light.
- E002 và E020 page đọc thư dọn player light trước khi transfer để ánh sáng phòng kho không theo Hải Quỳ sang map khác.
- Map Effects tại E001 được reset về tone trung tính; blur tua ngược của E002 vẫn được giữ nguyên vì đó là hậu kỳ chuyển cảnh, không phải ánh sáng gameplay.
