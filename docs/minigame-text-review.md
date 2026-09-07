# Text hiển thị trong minigame

File này liệt kê các chuỗi mà người chơi nhìn thấy trong hai minigame. Hãy sửa cột **Text mới**; giữ nguyên các placeholder trong dấu `{...}` hoặc `#{...}` nếu vẫn muốn hiển thị giá trị động.

Các tên file ảnh, BGM/SE và comment nội bộ không được đưa vào vì không phải text hiển thị.

## 1. Minigame câu tôm Atlantis

Nguồn: `Scripts/Atlantis Shrimp Fishing.rb`

### HUD và hướng dẫn

| ID | Text hiện tại | Text mới |
|---|---|---|
| FISH-001 | Câu đủ 10 tôm khi chúng chuyển màu vàng. | Kéo lên 10 tôm vào thời điểm chúng chuyển màu vàng. |
| FISH-002 | Cà phê Atlantis: `#{@caught}/#{TARGET}` | Cà phê Atlantis: `#{@caught}/#{TARGET}`|
| FISH-003 | Cần câu thường| Cần câu tôm|
| FISH-004 | Trượng phép Hải Quỳ | Găng tay của Hải Quỳ|
| FISH-005 | Dụng cụ: `#{rod_text}` | |
| FISH-006 | Z: Thả / Kéo / Bắn | Z: Thả mồi / Kéo về / Bắn beam|
| FISH-007 | Shift: Đổi dụng cụ    X/Esc: Thoát | |
| FISH-008 | << CHẠY XA | <<< |
| FISH-009 | LAO VỀ >> | >>> |

### Trạng thái câu tôm

| ID | Text hiện tại | Text mới |
|---|---|---|
| FISH-010 | Đã đổi sang cần câu thường. | Đã đổi sang cần câu.|
| FISH-011 | Trượng phép: dọn sạch và tạo lại hồ. | Găng tay: bắn beam dọn biển sạch sẽ. |
| FISH-012 | Tôm giật đứt dây rồi chạy mất! | Tôm giật đứt dây câu rồi chạy mất! |
| FISH-013 | Còn đen quá. Hải Quỳ vứt tôm trở lại hồ! | Hạt cà phê chưa chín. Hải Quỳ vứt tôm trở về biển! |
| FISH-014 | Bắt được tôm vàng! Cà phê Atlantis `#{@caught}/#{TARGET}`. | Bắt được tôm vàng! Tôm nhả ra cà phê Atlantis `#{@caught}/#{TARGET}`.|
| FISH-015 | Quá muộn rồi! | Kéo lên muộn, tôm nổ banh xác.|
| FISH-016 | Tôm đã ăn hạt! Kéo lên đúng lúc nó chuyển vàng. | |
| FISH-017 | Trượng phép Hải Quỳ đang nạp năng lượng... | Găng tay của Hải Quỳ đang nạp năng lượng... |
| FISH-018 | Hồ đã được reset một cách rất nhẹ nhàng. | Đám tôm cá cũ trong biển đã bị dọn sạch sẽ. |
| FISH-019 | Đã đủ 10 tôm vàng! Nhấn Z để quay lại quán cà phê. | Đã đủ cà phê, nhấn z quay lại quán cà phê hoặc câu thêm nữa.|

## 2. Minigame ném tuyết

Nguồn: `Scripts/WCF Snowball Rhythm.rb`

### Tên và HUD

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-001 | Hải Quỳ | |
| SNOW-002 | Shylvie | |
| SNOW-003 | Kohi | |
| SNOW-004 | Leo | |
| SNOW-005 | Hakase | |
| SNOW-006 | LƯỢT `#{@round}` | |
| SNOW-007 | PERFECT `#{@perfects}`   MISS `#{@misses}` | |
| SNOW-008 | `#{hp}/100` | |

### Bắt đầu, phòng thủ và đặc điểm đối thủ

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-009 | CHUẨN BỊ! | |
| SNOW-010 | Nhìn mũi tên trên quả cầu tuyết | Bấm phím mũi trên quả cầu tuyết khi gần chạm tới Hải Quỳ.|
| SNOW-011 | PHÒNG THỦ | |
| SNOW-012 | Shylvie ném chắc tay; hãy đỡ đúng nhịp | bỏ|
| SNOW-013 | Kohi thường ném liên hoàn; đừng mất nhịp | bỏ|
| SNOW-014 | Leo ném thấp và nhanh; nhìn kỹ hướng | bỏ|
| SNOW-015 | Hakase thay đổi kích thước và quỹ đạo liên tục | bỏ|

### Phán định khi phòng thủ

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-016 | PERFECT! | |
| SNOW-017 | MISS | |
| SNOW-018 | `-#{damage} HP` | |

`MISS` và `PERFECT!` được dùng ở nhiều vị trí nhưng chỉ cần chỉnh thống nhất một lần nếu muốn giữ cùng cách gọi.

### Phản công

Các text về chuỗi phím và mốc 50% bên dưới chỉ áp dụng cho phase phản công của Kohi. Shylvie, Leo và Hakase dùng hướng dẫn riêng theo cơ chế của từng người.

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-019 | PHẢN CÔNG! | |
| SNOW-020 | Ghi nhớ và nhập đúng toàn bộ chuỗi | Nhập đúng ít nhất 50% chuỗi trước khi hết thời gian|
| SNOW-021 | NÉM TRẢ | |
| SNOW-022 | Phá thế thủ của Shylvie bằng một chuỗi dài | bỏ|
| SNOW-023 | Kohi không cho nhiều thời gian phản công | bỏ|
| SNOW-024 | Chuỗi của Leo đổi nhịp ngang và dọc | bỏ|
| SNOW-025 | Chuỗi của Hakase phản chiếu như trong gương | bỏ|
| SNOW-026 | OK! | |
| SNOW-027 | PERFECT! | |
| SNOW-028 | Hải Quỳ ném một quả cầu tuyết khổng lồ | |
| SNOW-029 | GOOD | |
| SNOW-030 | Hoàn thành ít nhất nửa chuỗi: cú ném vẫn trúng | Hải Quỳ ném một quả cầu tuyết bé|
| SNOW-031 | MISS | |
| SNOW-032 | NÉM TRƯỢT! | |
| SNOW-033 | Chưa hoàn thành được một nửa chuỗi | |
| SNOW-034 | LƯỢT TIẾP THEO | |
| SNOW-035 | Đối thủ đang chuẩn bị tuyết | |

### Finisher khi Hải Quỳ thua

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-036 | FINISHER! | |
| SNOW-037 | Đối thủ chuẩn bị một núi tuyết… | |
| SNOW-038 | NGƯỜI TUYẾT! | bỏ|
| SNOW-039 | HẢI QUỲ ĐÃ THÀNH NGƯỜI TUYẾT! | |
| SNOW-040 | …ít nhất cũng có thể dùng trang trí Giáng sinh | |
| SNOW-041 | FATALITY | |
| SNOW-042 | `#{@opponent[0].upcase}` WINS | |
| SNOW-043 | Hải Quỳ đã bị chôn thành người tuyết | Hải Quỳ bị chôn vùi trong tuyết|

### Finisher khi Hải Quỳ thắng

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-044 | HẢI QUỲ FINISHER! | |
| SNOW-045 | Đối thủ không kịp nhìn thấy cô biến mất | bỏ|
| SNOW-046 | … | |
| SNOW-047 | Không khí như khựng lại trong chốc lát | bỏ|
| SNOW-048 | KNOCKOUT! | |
| SNOW-049 | Cú đánh bắt đầu hất văng đối thủ | Hải Quỳ đấm bay đối thủ|
| SNOW-050 | SMASH!! | |
| SNOW-051 | FATALITY | |
| SNOW-052 | Đối thủ đã bay khỏi màn hình | bỏ|
| SNOW-053 | HẢI QUỲ WINS | |
| SNOW-054 | Một chiến thắng áp đảo | |
| SNOW-055 | HẢI QUỲ CHIẾN THẮNG! | |

### Kết thúc và thoát minigame

| ID | Text hiện tại | Text mới |
|---|---|---|
| SNOW-056 | ĐÃ DỪNG TRẬN | |
| SNOW-057 | Z/Enter hoặc X/Esc: quay lại | |
| SNOW-058 | Z/Enter: quay lại bữa tiệc | Z/Enter: quay lại bữa tiệc giáng sinh|

## Ghi chú khi chỉnh

- Không xóa placeholder động như `#{@caught}`, `#{TARGET}`, `#{@round}`, `#{@perfects}`, `#{@misses}`, `#{hp}`, `#{damage}` hoặc `#{@opponent[0].upcase}` nếu vẫn cần giá trị đó.
- Các chuỗi HUD dài có thể tràn khỏi vùng vẽ cố định. Nếu muốn thay bằng câu dài hơn đáng kể, hãy ghi chú để tôi chỉnh luôn kích thước hoặc cách căn chữ.
- Có thể để trống **Text mới** nếu muốn giữ nguyên.
