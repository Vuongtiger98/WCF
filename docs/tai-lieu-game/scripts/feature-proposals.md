# Đề xuất script cho WCF

Đây là thiết kế để lựa chọn, chưa cài các chức năng mới vào runtime. Ưu tiên mở rộng hệ đang dùng để tận dụng menu điện thoại, KUL, Galv Layers và các manager WCF, giảm số framework phải cùng hook engine.

## 1. Sổ vật phẩm và nhiệm vụ trên điện thoại

Điện thoại có mục “Yêu cầu” ghi nhiệm vụ Diana, số RAM đang giữ, gợi ý khu vực đã khám phá và phần thưởng. Một registry RAM dùng mã ổn định như `silverwing_fridge`, không phụ thuộc một Event ID có thể được di chuyển/clone trong editor.

Mỗi lần nhặt gửi chung một lệnh nhận vật phẩm; nguồn nhặt một lần lưu mã đã lấy, còn nguồn Snowball vẫn nhận lặp. Khi đạt 10 RAM, state chuyển “đủ điều kiện gặp Diana”; cutscene đợi địa điểm/thời điểm phù hợp. Cách này hỗ trợ rải RAM ở nhiều map mà không khiến event nhận item phải chứa camera/teleport riêng.

Mở rộng `Custom Menu` và CE20; lưu registry vào save, có migration cho save cũ. Không tự tiết lộ vị trí RAM chưa khám phá. Đây là đề xuất có giá trị trực tiếp nhất với yêu cầu RAM hiện tại.

## 2. Nhật ký thoại và nút chụp bằng chứng cho writer

Điện thoại hoặc phím cấu hình mở lại các khung thoại gần đây: nguyên xuống dòng, face/index, speaker, bubble target, Map/Event/Page và route state tại lúc phát. Writer chọn một khung rồi xuất report ngắn có ID để sửa đúng chỗ.

Hook nơi message thật bắt đầu hiển thị thay vì ghi lại mọi lần `update`; đặt giới hạn số khung để save không phình. Chỉ cho xem thoại đã đọc, không biến thành skip cutscene. Khớp report của web QA bằng khóa Map/Event/Page/command.

## 3. Đạo diễn chuyển cảnh dùng chung

Một API WCF quản lý tuần tự che màn hình → dọn old scene → setup map/nhân vật → đặt camera/light/layer → reveal → mở input. Có bước kiểm tra sau reveal để ghi log nếu player vẫn vô hình, screen brightness bằng 0 hoặc KUL còn đen ở free roam.

Lưu preset cho cảnh ngủ, văn phòng, cửa hàng và cutscene CG. Map037 hiện đã có handoff ổn định nên dùng làm case kiểm chứng; di chuyển từng flow một, không thay toàn bộ route cùng lúc.

Lợi ích lớn nhất là giảm tái xuất hiện màn hình đen và sprite trùng. Script cần phối hợp cả fade native/CG và KUL, không chỉ ép mọi scene vào một loại fade.

## 4. Tùy chọn hiệu ứng dễ chịu hơn

Mở rộng System Options bằng mức rung, flash, glitch và motion intensity. Mê cung vẫn giữ đủ bốn lần choáng và viền cảnh báo, nhưng biên độ rung/zoom có thể hạ xuống mà không thay độ khó.

Camera nhận damage có cú tác động ngắn rồi easing về ổn định; trạng thái nguy hiểm hiển thị bằng viền/tín hiệu khác thay vì rung liên tục. Áp dụng tương tự cho chase, jumpscare và finisher ném tuyết.

## 5. Gợi ý tương tác theo khoảng cách

Khi tới gần vật thể có tương tác, hiện icon nhỏ hoặc tên vật; chỉ hiện với event được gắn tag. Với NPC vẽ sẵn trong parallax, hitbox vẫn trỏ về anchor/controller chung.

Có chế độ “gợi ý RAM” sau khi người chơi đã nhận nhiệm vụ; không bật toàn bộ điểm nhặt ngay từ đầu. Dựa vào Text Over Event/Event Popup hiện có, chỉ cập nhật các event lân cận thay vì quét/render toàn map mỗi frame.

## 6. Preset ánh sáng theo vùng và theo hành động

KUL đã đủ khả năng cho đèn tím ở gương, ánh lửa ấm, đèn cảnh báo cửa và nguồn sáng phản ứng khi clone xuất hiện. Script điều phối thêm fade, flicker chậm, cường độ và màu theo state bẫy để người chơi đọc được nguy hiểm.

Ví dụ: gai sắp nhô có quầng lạnh tăng nhẹ; nút chưa mở sáng ổn định; clone tới lửa có rim light rồi tan. Giữ nguyên shadow true và collision do người dùng thiết kế. Không tăng số dynamic light thiếu kiểm soát trên map dài.

## 7. Preset checkpoint và replay để tester tự dùng

Một bảng cấu hình checkpoint có route branch, biến, switch, điện thoại, sprite, light và destination; event hub chỉ gọi khóa preset. Validator kiểm tra thiếu state, tile bị chặn và autorun page rỗng trước khi teleport.

Thêm “lặp lại cảnh vừa test” trong công cụ QA nếu được duyệt, dùng snapshot state trước cảnh thay vì reset toàn bộ game. Giữ tọa độ/animation flag của các event hub hiện tại. Không tự khôi phục F8, vì người dùng đã bỏ chức năng đó.

## 8. Âm thanh theo ngữ cảnh và ducking khi có thoại

Một director bọc BGM/BGS/ME/SE đang dùng: thay bài theo scene, giảm nền khi câu thoại quan trọng xuất hiện, phục hồi âm lượng khi đóng thoại và giữ tùy chọn âm lượng của Yanfly. Các nguồn môi trường có thể phát nhỏ dần theo khoảng cách.

Đi kèm log playtest cho lần đổi track, loại lệnh, tên asset và route/map. Mục tiêu là phát hiện lỗi sound bằng bằng chứng và giữ RTP fallback đúng, không tự chuyển đổi hàng loạt tài nguyên.

## Thứ tự nên làm

| Thứ tự | Chức năng | Giá trị chính | Mức ảnh hưởng |
|---:|---|---|---|
| 1 | Sổ RAM/nhiệm vụ | Giải quyết phân tán item và threshold Diana | State save + điện thoại + event nhận RAM |
| 2 | Nhật ký thoại/bằng chứng | Writer/tester báo chính xác, giảm thời gian tìm lỗi | Message + report |
| 3 | Tùy chọn hiệu ứng | Giảm chóng mặt, giữ gameplay | Options + các manager hiệu ứng |
| 4 | Director chuyển cảnh | Giảm lỗi KUL/CG/sprite lặp | Cao; migrate từng flow và playtest |
| 5 | Gợi ý tương tác | Free roam dễ đọc hơn | UI map + tag event |

Ba chức năng còn lại phù hợp sau khi state/transition có giao diện ổn định. Việc viết thêm nên bắt đầu từ API nhỏ, có một map mẫu, rồi mới áp sang tất cả route.
