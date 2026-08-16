# Timeline điện thoại

Custom Menu không đọc đồng hồ máy tính thật. Ngày, giờ, pin và widget là trạng thái cốt truyện được lưu trong `$game_config`, nhờ vậy save/load luôn khớp với route.

## Cách hoạt động

`PhoneTimeline` nằm trong `Custom Menu` và giữ các preset theo thứ tự. Lệnh chuẩn:

```ruby
PhoneTimeline.advance(:bus)
```

`advance` chỉ cho phép tiến tới mốc bằng hoặc mới hơn mốc hiện tại. Khi Player quay lại map cũ, điện thoại không bị lùi thời gian hoặc hồi pin.

Chỉ dùng khi debug hoặc sửa save:

```ruby
PhoneTimeline.apply(:prologue, true)
PhoneMenuScript.force_timeline(:christmas_gift)
```

## Preset hiện tại

| Stage | Common Event | Mốc truyện | Ngày giờ | Pin |
|---|---:|---|---|---:|
| `prologue` | 12 | Văn phòng Silver Wing | 21/12 08:45 | 87% |
| `city` | 13 | Ra thành phố | 21/12 17:35 | 54% |
| `bus` | 14 | Trên xe buýt | 21/12 18:05 | 48% |
| `atlantis_gate` | 15 | Điểm xuống Atlantis | 21/12 19:00 | 43% |
| `home` | 16 | Về nhà Hải Quỳ | 21/12 19:20 | 38% |
| `book_shop` | 17 | Tiệm sách cũ Atlantis | 21/12 20:10 | 31% |
| `christmas_gift` | 18 | Bắt đầu trao quà | **25/12 19:00** | 76% |

Pin tại ngày 25 tăng trở lại vì đã có khoảng thời gian giữa phần chuẩn bị và bữa tiệc. Đây là giá trị trình bày, không phải resource gameplay và không tự giảm theo frame.

## Map đã nối

- Map003 E001 → CE12.
- Map006 E002 → CE13.
- Map010 E002 → CE14.
- Map021 E001 → CE15.
- Map022 E001 → CE16.
- Map023 E001 → CE17.

CE18 chưa gắn vào map vì scene hội tụ trao quà chưa được dựng. Khi tạo event tặng quà, gọi CE18 ngay trước khi bắt đầu vòng trao quà, không gọi từ lúc bước vào Wanderer Office nếu nhân vật còn đang chuẩn bị tiệc.

## Quy tắc mở rộng route

- Route mới đi qua cùng mốc thời gian thì gọi lại CE hiện có.
- Nếu một route thực sự kéo dài sang thời điểm khác, thêm stage mới vào cả `ORDER` và `PRESETS`, sau đó tạo Common Event tương ứng.
- Không gọi trực tiếp ba hàm widget rời rạc cho một mốc timeline; nếu chỉ đổi giờ mà quên pin/ngày, UI sẽ tự mâu thuẫn.
- Weather/location text có thể khác giữa route, nhưng ngày tặng quà phải hội tụ về CE18.

