# Tối ưu hiệu năng chung — 15/11/2026

Đã sửa các thao tác thừa trong năm script dùng chung và đồng bộ vào `Data/Scripts.rvdata2`. Báo cáo lag trên laptop chưa có bản đo trực tiếp; các kết quả dưới đây chứng minh lượng công việc thừa được loại bỏ, **không phải mức tăng FPS đo trên laptop**.

Các số đếm redraw/fill và ảnh đối chiếu trong báo cáo này thuộc lượt tối ưu trước khi đổi bố cục điện thoại. Lượt [chỉnh giao diện sau đó](phone-ui-review-2026-11-15.md) thay nội dung bảng và vẫn giữ 1 lần redraw cho 600 frame dữ liệu đứng yên; bảng mới dùng 1.765 lệnh fill ở lần redraw, thay vì 504 của bố cục cũ.

## Các vấn đề đã xác nhận và sửa

| Script / slot | Vấn đề trong code trước sửa | Thay đổi |
|---|---|---|
| Custom Menu / 198 | `refresh_main_panel` xóa và vẽ lại toàn bộ bảng widget mỗi frame, kể cả khi dữ liệu đứng yên | Chỉ vẽ lại khi một trong 10 giá trị hiển thị thay đổi hoặc bitmap của bảng bị thay. Snapshot sao chép chuỗi để nhận biết cả chỉnh chuỗi tại chỗ |
| Custom Menu / 198 | Mỗi phép đo chữ tạo/hủy một bitmap; sáu highlight tạo sáu ảnh tròn giống nhau bằng vòng lặp từng pixel | Dùng lại một bitmap đo chữ trong vòng đời menu và một ảnh highlight cho sáu sprite. Opacity của từng sprite vẫn độc lập; bitmap riêng được dọn khi đóng menu |
| KUL Graphics / 179 | Dynamic light có shadow dựng lại mask Region mỗi frame dù nguồn sáng không đổi | Dùng lại mask khi vị trí thế giới, hướng, height, bitmap nguồn và caster không đổi. Di chuyển, đổi hướng/height, thay caster, thêm caster hoặc `restore` đều làm dựng lại mask. Áp dụng cả nguồn sáng thường và nguồn sáng nhiều hướng; `dispose` bỏ toàn bộ tham chiếu cache tới bitmap/caster để lưu game an toàn |
| KUL Graphics / 179 | `refresh_xyh` đọc lại một trong hai điểm height trong phép chọn giá trị lớn hơn | Mỗi nguồn sáng chỉ đọc đúng hai điểm, thay vì ba lần đọc |
| Game_Map / 31 | Truy vấn va chạm và event đang khởi động gọi `@events.values`, tạo bản sao mảng toàn bộ event cho mỗi truy vấn | Duyệt `each_value` trực tiếp. Vẫn kiểm tra vị trí/through hiện tại và giữ thứ tự event; không lưu một bảng tọa độ dễ bị cũ khi event di chuyển |
| Text Over Event / 186 | Method cleanup bị viết nhầm `termminate`, không được gọi theo hook `terminate` | Sửa tên hook, dọn từng window an toàn và xóa danh sách sau cleanup; bỏ qua window đã dispose |
| MOG_Weather_EX / 133 | Mỗi sprite thời tiết hủy bitmap lấy từ `Cache.weather`, dù nhiều sprite đang cùng dùng ảnh đó; cleanup chạy thêm vòng lặp thừa | Sprite bỏ tham chiếu ảnh và tự dispose; cache tiếp tục sở hữu bitmap dùng chung. Bỏ vòng lặp dispose trùng |

KUL vẫn giữ cấu hình shadow, màu, kích thước và flicker hiện có; phần vẽ ánh sáng vẫn chạy mỗi frame. Mask được lưu theo tọa độ thế giới nên camera di chuyển không yêu cầu tính lại hình học bóng. Không thêm bitmap mask thứ hai cho mỗi đèn: dùng lại bitmap riêng vốn đã có. API `wcf_invalidate_shadow_cache` có thể dùng nếu một script tương lai sửa hình học caster trực tiếp ngoài `Shadow_Casters#push`.

Không giảm frame rate, không tắt shader/animation/AI, không bật Theo Anti Lag, không bỏ cập nhật event ngoài màn hình. Các event sensor, clone, gai, đá lăn và autorun vẫn hoạt động theo nhịp cũ. Không chỉnh map/event, vị trí, animation flag, lựa chọn, thoại, state điện thoại hay webapp trong lượt tối ưu này.

## Kết quả kiểm tra trước và sau

`tools/test_performance_optimizations.rb` trích method/class thật từ source và dùng Bitmap/Sprite/KGL giả lập có bộ đếm. Chế độ `--baseline` đọc các export đã backup trước lượt sửa. Cùng bộ kiểm tra: trước sửa có 9 failure / 0 error; sau sửa có **13 case, 395 assertion, 0 failure/error**. Case bổ sung sau lượt native mô phỏng Bitmap không thể Marshal để kiểm tra đèn thường và đèn nhiều hướng có thể lưu/nạp sau dispose, rồi dựng lại mask.

| Tình huống giả lập | Trước | Sau |
|---|---:|---:|
| 600 lần refresh điện thoại, widget không đổi | 600 lần vẽ bảng | 1 lần vẽ bảng |
| Lệnh `fill_rect` trong các lần vẽ bảng trên | 302.400 | 504 |
| 600 frame một dynamic light đứng yên, shadow bật | 600 lần clone/dựng mask | 1 lần clone/dựng mask |
| 120 frame nguồn sáng di chuyển mỗi frame | 120 lần dựng mask | 120 lần dựng mask |
| 200 lần đo chữ trong một menu | 200 bitmap tạm | 1 bitmap dùng lại |
| Sáu highlight khi mở menu | 6 bitmap tròn | 1 bitmap tròn dùng chung |
| Nhóm truy vấn event trong fixture | 9 bản sao mảng toàn bộ event | 0 bản sao |

Các case còn kiểm tra: dữ liệu widget thay đổi và chuỗi bị sửa tại chỗ; thay bitmap bảng; đổi hướng/height/caster; `restore`; đèn nhiều hướng; event di chuyển/through/thứ tự khởi động; cleanup nhiều lần; texture thời tiết dùng chung; dọn nhãn qua nhiều lần rời scene. Đây là kiểm tra hành vi và số thao tác, không xác minh pixel native của KGL.

Kiểm tra lifecycle của lần sửa trước cũng đạt **7 case, 18 assertion, 0 failure/error**. Runtime/export khớp token, parse không lỗi; CSV giữ nguyên và 222 slot không bị thêm, xóa, đổi ID, đổi tên hoặc đảo thứ tự. So với backup 15/11, chỉ năm slot trong bảng trên thay source. So với backup 30/10, tổng cộng tám slot bao gồm ba bản sửa lifecycle trước đó.

Các audit hiện có đều đạt:

- Transfer: 262 chuyển cảnh, 64 map, không error/warning.
- KUL handoff: 49 black transfer, 148 entry page, không failure.
- Cú pháp script trong các map đã review, Test Hub, prototype mê cung, sáu page preparation và layer scene Giáng sinh: không error.

Lần thử fixture ban đầu không thu được log. Sau khi người dùng yêu cầu thử lại, đã chạy được engine thật và bổ sung các kết quả dưới đây. Chưa có phép đo trên laptop báo lag và chưa có cặp đo FPS toàn game trước/sau.

## Playtest bổ sung bằng engine thật

Ngày 15/11/2026, chạy `Game.exe` với RGSS301, **Ruby 1.9.2 / KGL 2.0**. Đã nhìn thấy màn hình chính của game gốc, sau đó dùng bản sao riêng tại `Save/PerformancePlaytest_20261115_r1/current`. Data/script được copy; asset dùng junction đọc chung, config và save của bản test nằm riêng. Harness chỉ cài trong bản sao, không thêm slot hoặc event vào game làm việc.

Phím gửi qua Computer Use không được game nhận ổn định. Vì vậy phần vào checkpoint, mở menu và lưu/nạp dùng harness gọi các API engine thật; Computer Use quan sát màn hình. Đây là kiểm tra tích hợp tự động có quan sát hình ảnh, chưa thay thế việc tự điều khiển chơi hết các route.

**Lỗi tìm thấy và đã sửa:** bản cache đầu tiên giữ `@wcf_shadow_bitmap` và `@wcf_shadow_source` sau `Light_Source#dispose`. RGSS Bitmap không thể Marshal ngay cả khi đã dispose, nên cả serialize đèn và serialize dữ liệu lưu từ menu đều báo `TypeError: no marshal_dump is defined for class Bitmap`. Đã sửa `dispose` của cả Light_Source và Light_MKSource để vô hiệu cache và bỏ các tham chiếu bitmap/caster. Lần chạy lại xác nhận:

- 60 mẫu bóng tại Map028, mỗi mẫu so 289 điểm ảnh giữa method mới và method trước tối ưu: **khớp toàn bộ**, có 60 mask khác nhau khi đổi vị trí/hướng và restore.
- Bảng điện thoại so 289 điểm ảnh với method cũ: **khớp toàn bộ**.
- Serialize đèn sau dispose và serialize dữ liệu game từ menu: **PASS**.
- Gọi `DataManager.save_game(0)` và `DataManager.load_game(0)` trong bản sao: **đều true**. Sau nạp, quan sát Map028 vẫn hiện sprite, đèn vàng, thùng lửa và các vùng sáng môi trường.
- Đã chạy chuỗi Hub → Map028 → điện thoại → lưu/nạp → Map028; không thấy hộp lỗi/crash trong chuỗi này.

Đo riêng 120 lần vẽ bảng cũ mất khoảng **1.327 ms**, so với khoảng **1 ms** cho 120 lần refresh mới khi dữ liệu không đổi. Đây là thời gian của nhóm thao tác trên máy hiện tại, không phải thời gian một frame và không suy ra tỷ lệ tăng FPS. Đo KUL mới có mẫu quá ngắn dưới độ phân giải `Time.now`; không diễn giải kết quả 0 ms là không có chi phí.

Hai mẫu 600 frame ổn định ghi nhận điện thoại khoảng **59 FPS**, mê cung sau nạp khoảng **60 FPS**, p95 frame khoảng **18 ms** trên máy đang kiểm tra, mục tiêu engine là 60 FPS. Các mẫu transfer/khởi tạo ngắn không dùng làm số FPS ổn định. Chưa có benchmark trên laptop cấu hình thấp hay kiểm tra chơi dài qua mọi map.

Log trước lỗi lưu: `Save/PerformancePlaytest_20261115_r1/current/native-before-save-fix.txt`. Log sau sửa: `native-report.txt` cùng thư mục; các capture frame nằm trong `current/Save/Performance_*.txt`. Đây là dữ liệu playtest local, đang được `.gitignore` loại khỏi Git. Backup trước sửa cleanup bổ sung nằm tại `Data/codex_backup_performance_native_20261115/`.

## Đo trên game thật khi playtest

Thêm công cụ phát triển `tools/rgss_performance_probe.rb`, tương thích cú pháp Ruby RGSS3. Công cụ không nằm trong Script Editor, không được game tự nạp, không có hotkey và không sửa save/map. Muốn lấy một mẫu, chạy hai dòng sau từ lệnh Script của một event test tạm thời:

```ruby
load 'tools/rgss_performance_probe.rb'
WCFPerformanceProbe.start(600)
```

Tiếp tục chơi hoặc mở điện thoại trong 600 lần `Graphics.update`; công cụ tự dừng và ghi `Save/Performance_YYYYMMDD_HHMMSS.txt`. Có thể dừng sớm bằng `WCFPerformanceProbe.stop`, hoặc đọc đường dẫn mới nhất từ `WCFPerformanceProbe.last_report_path`. Chỉ load một lần trong một phiên playtest; mở lại game để trở về trạng thái hoàn toàn không có wrapper đo.

Log có FPS trình bày trung bình trong mẫu, p95 thời gian frame và thời gian/call của event, character, layers, weather, KUL, mask shadow, Map Effects và menu. Các thời gian thành phần có thể lồng nhau: không cộng tổng các hàng. FPS phụ thuộc cả thời gian chờ render và lịch chạy của Windows; chính wrapper đo cũng có overhead. So sánh trên cùng máy, cùng checkpoint và cùng thao tác.

Công cụ đo có **3 case, 35 assertion** đạt: không tự cài hook khi load, tự dừng đúng số frame, ghi số liệu theo map, giữ return/block/visibility của method gốc, khởi động lại không bọc lặp và không ghi thêm sau khi dừng. Đây vẫn là kiểm tra bằng lớp giả lập, không phải xác nhận native.

Các đoạn nên lấy mẫu:

1. Đứng yên rồi đi lại tại map nhiều đèn Region; quan sát bóng khi quay hướng và gần tường/gương.
2. Mở/đóng điện thoại nhiều lần, xem Contacts/Gallery, cập nhật timeline/tin nhắn rồi mở lại; bảng phải đổi ngay khi dữ liệu đổi.
3. Chuyển map và vào/ra menu khi có thời tiết, layer và nhãn event; kiểm tra texture không mất và bộ nhớ sau nhiều vòng.
4. Cảnh bàn tiệc, snowbuild, kéo khỏi tuyết, rơi và zoom/blur có Map Effects.
5. Mê cung: clone chạm player, gai, thùng lửa làm lớn ánh sáng, đá lăn, cửa/nút và hồi phục sau bốn lần choáng.
6. Load save cũ rồi chuyển map/đổi preset đèn; các instance cũ chưa có field cache sẽ tự dựng mask ở lần dùng đầu tiên.

## Điểm còn cần số liệu

Map Effects có đường chụp bitmap màn hình khi hiệu ứng tổng hợp đang bật; nhiều layer lớn và nhiều đèn di động vẫn có chi phí thực. Chưa thay nhịp hiệu ứng hoặc giảm chất lượng khi chưa có phép đo và kiểm tra hình ảnh. Bitmap layer/weather/particle được giữ theo cache có lợi cho việc dùng lại nhưng cần theo dõi bộ nhớ khi chơi lâu; không dispose hàng loạt ảnh đang có sprite mượn.

## Lệnh kiểm tra và backup

```text
ruby tools/test_performance_optimizations.rb
ruby tools/test_performance_optimizations.rb --baseline
ruby tools/test_script_graphics_lifecycle.rb
ruby tools/test_rgss_performance_probe.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
ruby -W0 tools/script_inventory.rb check-performance-scope
ruby -W0 tools/script_inventory.rb check-native-performance-scope
ruby -W0 tools/script_inventory.rb check-patch-scope
```

`--baseline` cố ý báo failure ở những kỳ vọng dành cho bản tối ưu. `check-performance-scope` đối chiếu đúng năm slot với `Data/codex_backup_performance_20261115/Scripts.rvdata2`. `check-patch-scope` kiểm tra tổng tám slot từ backup 30/10. Backup 15/11 còn giữ năm file export và CSV trước sửa; các chỉnh sửa có sẵn của dự án được giữ nguyên.

Ở thời điểm kiểm tra native bổ sung, chỉ slot 179 KUL Graphics đổi source; ba bộ kiểm tra khi đó đạt **23 case / 448 assertion**. Sau lượt sửa giao diện, `check-native-performance-scope` đối chiếu cùng backup và cho phép thêm slot 198 Custom Menu; `check-phone-ui-scope` kiểm tra riêng lượt giao diện, chỉ cho phép slot 198 đổi. Toàn bộ identity/order được giữ nguyên.
