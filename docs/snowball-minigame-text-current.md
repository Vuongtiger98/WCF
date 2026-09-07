# Text hiện tại — Minigame ném tuyết

Nguồn đối chiếu: `Scripts/WCF Snowball Rhythm.rb`.

Điền nội dung muốn thay vào cột **Text mới**. Ghi `bỏ` nếu muốn xóa. Các placeholder trong dấu `{}` cần được giữ lại nếu text mới vẫn cần giá trị động.

## HUD

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-001 | Tên người chơi | Hải Quỳ | |
| SNOW-002 | Tên đối thủ | `{opponent}` | |
| SNOW-003 | Bộ đếm lượt | LƯỢT `{round}` | |
| SNOW-004 | Thống kê | PERFECT `{perfects}`   MISS `{misses}` | |
| SNOW-005 | HP | `{hp}/100` | |

Tên đối thủ hiện có: `Shylvie`, `Kohi`, `Leo`, `Hakase`.

## Mở trận và phòng thủ

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-006 | Banner mở trận | CHUẨN BỊ! | |
| SNOW-007 | Hướng dẫn mở trận | Bấm phím mũi tên trên cầu tuyết khi nó gần chạm Hải Quỳ. | |
| SNOW-008 | Tên phase | PHÒNG THỦ | |
| SNOW-009 | Phán định đúng | PERFECT! | |
| SNOW-010 | Phán định sai | MISS | |

## Intro phase phản công

| ID | Đối thủ/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-011 | Tiêu đề chung | PHẢN CÔNG! | |
| SNOW-012 | Shylvie | Chuẩn bị phản đòn cầu tuyết của Shylvie | |
| SNOW-013 | Kohi | Nhập đúng ít nhất 50% chuỗi trước khi hết thời gian | |
| SNOW-014 | Leo | Chuẩn bị đối phó các nhát chém không gian của Leo | |
| SNOW-015 | Hakase | Chuẩn bị đấu ma lực với Hakase | |

## Phản công Kohi

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-016 | Tên phase nhập chuỗi | NÉM TRẢ | |
| SNOW-017 | Bấm đúng một note | OK! | |
| SNOW-018 | Hoàn thành toàn bộ | PERFECT! | |
| SNOW-019 | Mô tả Perfect | Hải Quỳ ném một quả cầu tuyết khổng lồ | |
| SNOW-020 | Hoàn thành ít nhất 50% | GOOD | |
| SNOW-021 | Mô tả Good | Hải Quỳ ném một quả cầu tuyết bé | |
| SNOW-022 | Dưới 50% | MISS | |
| SNOW-023 | Tiêu đề ném trượt | NÉM TRƯỢT! | |
| SNOW-024 | Mô tả ném trượt | Hải Quỳ ngắm lệch tỉ độ | |
| SNOW-025 | Sát thương lên đối thủ | -`{damage}` HP | |

## Phản công Shylvie

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-026 | Tên phase | PHẢN ĐÒN | |
| SNOW-027 | Hướng dẫn | Phản PERFECT cho tới khi Shylvie không đỡ nổi | |
| SNOW-028 | Phản thành công | PERFECT! | |
| SNOW-029 | Phản thất bại | MISS | |
| SNOW-030 | Sát thương lên Shylvie | -`{damage}` HP | |

## Phản công Leo

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-031 | Tên phase | NHÁT CHÉM KHÔNG GIAN | |
| SNOW-032 | Hướng dẫn | Bấm phím ngay khi phím hiện ra để cast phép bảo vệ cầu tuyết khỏi lưỡi kiếm của Leo | |
| SNOW-033 | QTE thành công | PERFECT! | |
| SNOW-034 | Sát thương lên Leo | -`{damage}` HP | |

## Phase Hakase

### Phòng thủ ma pháp tuyết

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-035 | Tên phase | MA PHÁP TUYẾT | |
| SNOW-036 | Hướng dẫn | Các quả cầu tuyết sẽ có tốc độ và kích cỡ ngẫu nhiên! | |

### Phản công đấu lực

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-037 | Tên phase | ĐẤU MA LỰC | |
| SNOW-038 | Hướng dẫn | Giữ đúng phím để đẩy cầu tuyết về phía Hakase | |
| SNOW-039 | Đẩy cầu tới Hakase | PERFECT! | |
| SNOW-040 | Cầu bị đẩy về Hải Quỳ | MISS | |
| SNOW-041 | Sát thương lên Hakase | -`{damage}` HP | |

## Chuyển lượt

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-042 | Tiêu đề | LƯỢT TIẾP THEO | |
| SNOW-043 | Mô tả | Đối thủ đang chuẩn bị tuyết | |

## Finisher khi Hải Quỳ thua

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-044 | Bắt đầu finisher | FINISHER! | |
| SNOW-045 | Cảnh báo | Đối thủ chuẩn bị một núi tuyết… | |
| SNOW-046 | Hải Quỳ bị vùi | HẢI QUỲ ĐÃ THÀNH NGƯỜI TUYẾT! | |
| SNOW-047 | Mô tả người tuyết | …ít nhất cũng có thể dùng trang trí Giáng sinh | |
| SNOW-048 | Chữ kết liễu | FATALITY | |
| SNOW-049 | Thông báo người thắng | `{OPPONENT}` WINS | |
| SNOW-050 | Mô tả kết quả | Hải Quỳ bị chôn vùi trong tuyết | |

## Finisher khi Hải Quỳ thắng

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-051 | Bắt đầu finisher | HẢI QUỲ FINISHER! | |
| SNOW-052 | Dừng hình | … | |
| SNOW-053 | Chữ hoạt hình | SMASH!! | |
| SNOW-054 | Kết quả cú đánh | KNOCKOUT! | |
| SNOW-055 | Mô tả cú đánh | Hải Quỳ đấm bay đối thủ | |
| SNOW-056 | Chữ kết liễu | FATALITY | |
| SNOW-057 | Thông báo người thắng | HẢI QUỲ WINS | |
| SNOW-058 | Mô tả kết quả | Một chiến thắng áp đảo | |
| SNOW-059 | Tiêu đề màn kết quả | HẢI QUỲ CHIẾN THẮNG! | |

## Thoát và màn kết quả

| ID | Vị trí/ngữ cảnh | Text hiện tại | Text mới |
|---|---|---|---|
| SNOW-060 | Người chơi chủ động thoát | ĐÃ DỪNG TRẬN | |
| SNOW-061 | Hướng dẫn sau khi thoát/thua | Z/Enter hoặc X/Esc: quay lại | |
| SNOW-062 | Hướng dẫn sau khi thắng | Z/Enter: quay lại bữa tiệc giáng sinh | |

## Ký hiệu không phải câu chữ

- Mũi tên input: `←`, `↓`, `↑`, `→`.
- Các text động cần giữ placeholder tương ứng: `{opponent}`, `{OPPONENT}`, `{round}`, `{perfects}`, `{misses}`, `{hp}`, `{damage}`.
