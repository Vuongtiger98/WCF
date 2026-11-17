# Kế hoạch kiểm tra sau xe bus — 17/11/2026

Trạng thái: **đã chạy nhóm siêu thị; các nhóm khác chưa chạy**. Xem [báo cáo siêu thị 17/11/2026](market-route-test-2026-11-17.md): 16 tổ hợp chính + 4 lượt cà phê Atlantis giả lập kết quả minigame, hai lỗi tương tác và các mục nội dung cần review. Loại trừ minigame. Lượt lập kế hoạch ban đầu chỉ đọc dữ liệu; lượt test tiếp theo cũng không sửa runtime, map, checkpoint hoặc web app.

Giả định phạm vi để review: phần thử thách mê cung/rượt đuổi (clone, bẫy, choáng, QTE) cũng để ngoài đợt này, nhưng các đoạn truyện và chuyển cảnh bao quanh vẫn nằm trong kế hoạch. Không dùng cách phân loại này để bỏ qua cả route phòng kho.

## Điểm bắt đầu và kết thúc

Báo cáo `scripts/prologue-review-2026-11-16.md` đã xác nhận Title → Silver Wing → thành phố → xe bus và bốn điểm đến. Chỉ nhánh siêu thị đã tới free roam; ba nhánh còn lại dừng ở thoại vào map. Không coi các đoạn phía sau là đã đạt.

Đợt tiếp theo bắt đầu từ state ngay trước bốn lựa chọn bus; kết thúc khi các tuyến trong phạm vi tới epilogue/ending, hint và Title. Tuyến có minigame được chia thành đoạn trước và sau, kết quả kiểm tra chỉ áp dụng cho các đoạn đã chạy.

Không chạy lại toàn bộ Silver Wing cho từng case. Chỉ quay lại một đoạn cũ nếu sửa script dùng chung làm phát sinh nhu cầu regression.

## Ma trận nền

| Nhóm | Số kịch bản nền | Tuyến cần kiểm tra |
|---|---:|---|
| Siêu thị | 16 | Map019 → chọn quà/người nhận → Map037 → Map038 → Map039 → Map036/Title |
| Mì cay | 2 | Map020; tin/không tin Aira → mua nguyên liệu nếu có → Map037 → Map014 → Map038 → ending |
| Hỏi Leo | 3 | Map013 → Map056 → ma pháp/cà phê/vũ khí (057/058/059) → Map037 → Map038 → ending |
| Hỏi Shylvie | 4 | Map013 → Map064 → bốn đá/bốn người nhận → Map037 → Map038 → Map066/067 → ending |
| Mua sách Atlantis | 2 | Nhà Hải Quỳ/Atlantis → Map023 → sách dịch chuyển hoặc Ma Vương → Map037/038 → Map050/052 → ending |
| Chủ tiệm trước | 1 | Map023 → Map053/054/055 → ending Vực Sâu |
| Phòng kho/ký ức | 1 | Map022/026 → Map024 → các đoạn truyện trước/sau mê cung và chase → Map025/035 → ending |
| **Tổng** | **29** | Chưa tính các ca phụ, hủy, đi lại phòng, điều kiện thoại và kết quả giả lập tại ranh giới minigame |

Ma trận siêu thị phải bao phủ bốn món × Leo/Kohi/Shylvie/Hakase. Không dùng một người nhận đại diện để kết luận cho cả nhóm. Leo phải có đủ ba cửa hàng/người nhận; đá có đủ bốn đá/người nhận; hai nhánh mì được kiểm tra riêng dù dùng chung ending.

Các điều kiện phụ cần tách case sau khi đọc event: đã/chưa đọc tin Momo; cà phê thường/Atlantis khi flow hiện tại thực sự có nhánh; thứ tự nói chuyện Leo/Shylvie; lặp tương tác NPC; điều kiện chìa khóa; Hủy/thanh toán/tiếp tục khám phá. Không tự tăng số route bằng một trạng thái chưa có đường đi hợp lệ.

## Trình tự thực hiện

### Đợt 0 — Chốt nền và expected

1. Ghi hash Data, thứ tự script và cấu hình của workspace hiện tại, vì có sửa đổi chưa commit. Dùng bản sao QA riêng với save và dữ liệu Gallery/Thư viện vật phẩm riêng.
2. Đối chiếu route thực tế, điều kiện page, choice, đường chuyển map và điểm kết thúc với tài liệu. Runtime xác định nhánh hiện có; compact/DOCX dùng đối chiếu thoại và ý đồ kịch bản. Mâu thuẫn nội dung cần review, không tự viết lời thay thế.
3. Lập case có lựa chọn và expected cụ thể; phân biệt variant map/page với một route độc lập. Không đưa map chuẩn bị archive vào đường chính.
4. Đánh dấu ranh giới minigame và cách chuẩn bị state sau trò chơi trong bản sao QA. Không thay code minigame hoặc biến việc giả lập kết quả thành bằng chứng minigame đã đạt.

**Điểm đã giải quyết khi test siêu thị:** đường vào Map040 nằm trong Common Event 019 sau thanh toán/chọn người nhận, trước Map037. Map039 đi tới Map036 là đúng flow hiện tại. Đã sửa mô tả route cũ; không nối lại map. Phần nội dung cà phê và điều kiện Momo trong nguồn vẫn cần writer review như báo cáo.

### Đợt 1 — Sau bus, khám phá và chốt quà

- Chạy tiếp từ cả bốn đích bus, kiểm tra hết đoạn đón vào map và thời điểm trả quyền di chuyển.
- Siêu thị: tương tác các quầy/NPC, chọn lại món, thanh toán/hủy, chat chọn người nhận và đủ 16 tổ hợp. Theo dõi đồng bộ món/người nhận tới checkpoint chuẩn bị.
- Wanderer thường: các lần nói chuyện dẫn tới gợi ý Leo/Shylvie, phòng phụ, cửa ra/vào và điện thoại. Kiểm tra lặp tương tác có mở lại đoạn sai hoặc làm nhảy route không.
- Ma pháp, cà phê, vũ khí và đá: giới thiệu → free roam → tương tác món → ảnh/thoại → mua hoặc tiếp tục khám phá. Không chấp nhận intro biến toàn map thành cutscene nếu có thiết kế free roam.
- Quán cà phê: các hitbox cùng NPC dùng chung tiến độ thoại, camera/balloon trỏ đúng neo NPC trên parallax; đi lại hitbox khác không làm lặp hoặc bỏ page.
- Nhà Hải Quỳ/tiệm sách: tương tác và thứ tự gặp chủ tiệm/chọn sách; điều kiện cửa kho, hint, event bổ sung và lấy chìa khóa; tách đường vào phòng kho khỏi đường mua sách.

### Đợt 2 — Chuẩn bị, ngủ, tới tiệc và free roam

Chạy đủ các tổ hợp đang dùng Map037, không chỉ khởi động từng variant một lần:

- Tên quà, màu/đặc điểm quà, người nhận, cách xưng hô và face đúng nhánh; không còn câu lặp hoặc sót nội dung từ route khác.
- Hải Quỳ ở vị trí chuẩn bị được tác giả đặt, đi về giường, fade, đổi parallax ngủ, ẩn sprite đã vẽ trên parallax; đủ thời gian dừng ngủ theo event. KUL không làm tối thêm phòng đã tô màu tối.
- CG đánh thức giữ liên tục tới chuỗi thay trang phục, không lộ phòng/sprite dưới nền. Khung đen đi cùng vòng đời CG.
- Đi từ phòng ngủ tới đúng office variant; không màn hình đen/ trắng treo, không lộ frame chuyển trạng thái sai.
- Tuyết: chỉ có một biểu diễn Hải Quỳ bị vùi; đúng graphic/frame Snowman; Kohi/Shylvie ở vị trí phù hợp; đúng thứ tự cảnh thường → CG cười → kéo khỏi tuyết → tối/chạy thoại.
- Chuẩn bị bàn tiệc → camera focus Leo/Quỳ đắp tuyết và lặp hai layer → chuyển sang free roam với bàn tiệc hoàn tất.
- Sau cutscene: player hiện đúng, NPC về vị trí thường, Leo/Hakase có mặt, camera/KUL/effect đã trả về state khám phá. Ra/vào bếp và phòng phụ không tạo thêm sprite Hải Quỳ hoặc khôi phục staging kéo tuyết.
- Nhặt RAM bằng các event, nhận thông điệp và kiểm tra cutscene Diana một lần; không chơi ném tuyết để farm trong đợt này.

### Đợt 3 — Trao quà, hậu truyện và kết thúc

- Mỗi tổ hợp chạy đúng vòng trao quà và phản ứng, quà nhận lại, ảnh vật phẩm, chat/cuộc gọi và ending. Không kết luận nhánh đạt chỉ vì tới đúng map.
- Siêu thị: đối chiếu đầy đủ 16 hậu truyện; đặc biệt đồ len/người nhận và hai trạng thái cà phê ở các câu thực sự có điều kiện.
- Đá: bốn người nhận, các hành động hậu truyện như mở tủ lạnh, đi vào bếp, vị trí nhân vật, camera/balloon và đường ra kết thúc.
- Hai sách: đúng người nhận, hiệu ứng/cảnh sau tiệc và hint; tài nguyên thiếu/placeholder hiện hữu phải ghi rõ, không tự thay hoặc che đi trong báo cáo.
- Nhánh chủ tiệm: cảnh sự cố/giải cứu và ending độc lập, không rơi sang một route mua sách.
- Đủ hint/Title theo route, không treo sau cuối thoại hoặc giữ âm thanh/ảnh/layer từ cảnh trước.

### Đợt 4 — Phòng kho, ký ức và các đoạn truyện bao quanh thử thách

- Kết thúc đọc nhật ký quay về kho; balloon, animation sàn, parallax rời màn hình và được ẩn sớm để không lặp.
- Hải Quỳ rơi/xoay liên tục và rời hẳn màn hình; parallax `falling_base` chỉ xuất hiện ở đúng thời điểm; layer chạy đúng thứ tự, không dùng ảnh/face cũ đã bỏ.
- Sau đứng dậy: hiện player đúng sprite, `falling_path` đúng thời điểm, trả quyền đi và tới event dịch chuyển ở vị trí hiện tại do tác giả đặt.
- Mê cung: chỉ kiểm tra đầu vào/chuyển sang đoạn truyện kế tiếp; không đánh giá clone/gai/đá/cửa/nút/thùng lửa/choáng-reset hoặc độ khó tìm đường.
- Vòng vây và jumpscare: kiểm tra cutscene, layer/sprite/scale, thoại, ánh sáng và handoff vào chase; không kiểm tra AI hoặc QTE.
- Bắt đầu từ state hậu chase chuẩn trong bản sao để kiểm tra Paulie/Oni Onii, các frame rơi/hạ cánh, đoạn kết và phòng đêm muộn. Không ghi là đã vượt maze/chase tự nhiên.

## Minigame ngoài phạm vi

Không chơi hoặc đánh giá cơ chế, AI, điểm, độ khó, nhịp, thời gian phản xạ, thắng/thua của ném tuyết, câu tôm, bắn súng, vuốt mèo, board game hay các minigame khác phát hiện trong route. Phần thử thách mê cung và chase/QTE cũng tách khỏi đợt này; chỉ giữ các đoạn truyện và chuyển cảnh liên quan như trên.

Vẫn kiểm tra được tính toàn vẹn của ranh giới: sự kiện mời chơi/cách hủy và state/thoại/transfer khi nhận kết quả. Nếu cần trạng thái thắng/thua/thoát để đi tiếp, chuẩn bị bằng API kết quả hoặc checkpoint trong bản sao QA và ghi rõ **giả lập kết quả**, không sửa game sản xuất, không tính minigame đã pass.

## Những kiểm tra dùng chung ở mọi nhóm

| Hạng mục | Expected |
|---|---|
| KUL, fade, tone | Đúng ý đồ cảnh; sau khi trả free roam không còn tối/trắng ngoài ý muốn, effect/đèn cũ không rò sang map mới. Không coi mọi frame đen có chủ ý là lỗi. |
| Transfer và điều khiển | Đúng map/variant/hướng; ô đến có lối đi thật; thử bước ra được khi tới free roam. Không sót through, transparent, StopPlayer/StopNPC hoặc autorun khóa vĩnh viễn. |
| Pop, thoại thường, face | Cửa sổ/đuôi pop/balloon đúng neo sau camera; chuyển pop→thường không lệch; face/file/index đúng người, không thiếu asset. |
| Nội dung và xuống dòng | Đúng người nói/quà/người nhận, không sót/lặp/bịa; tối đa 4 dòng và 33/40 ký tự hiển thị theo face, đếm grapheme Unicode và xử lý mã escape. |
| CG/layer/sprite | Đúng file, thứ tự, timing và dọn ảnh; khung đen chỉ hiện khi có CG; không nhân đôi player/NPC hoặc lộ staging. |
| Âm thanh | File BGM/BGS/SE tải được, đúng nhạc/điểm dừng/thay nhạc; không crash ở lệnh âm thanh. Chưa đánh giá cảm giác phối âm bằng tai. |
| Điện thoại | Tin/chat/lựa chọn và dấu chưa đọc khớp route; mở/đóng app không làm nhảy state hoặc phá camera, không lặp slide-in khi resume. |
| Save/Load/Settings | Lưu ở các mốc được phép, tải lại giữ đúng state rồi đi tiếp; hủy không đổi dữ liệu. Thử tại map đang có camera/ánh sáng đặc biệt, không chỉ fixture UI. |
| Bộ sưu tập | Ảnh quà vào Thư viện vật phẩm, CG cảnh vào Gallery; giữ mở khóa qua New Game/load, xem không cấp/tiêu hao item. Toàn bộ dữ liệu thử ở bản sao. |
| Lifecycle | Qua nhiều lần đổi map/mở menu không giữ sprite/map/effect cũ, không dùng tài nguyên đã dispose và không tăng tài nguyên do dọn thiếu. |

## Phương pháp và giới hạn bằng chứng

- Dùng Game.exe/RGSS301 với harness lệnh như lượt prologue: chạy event interpreter, message, forced move, collision/passability và logic camera/KUL thật. Ghi choice theo nhãn và kiểm tra state sau chọn, không mặc định luôn chọn index 0.
- Dùng snapshot trước choice bus trong bản sao để chia phiên độc lập. Các tuyến thông thường cần có lượt đi liên tục từ bus qua các điểm trong phạm vi; không chỉ teleport trực tiếp tới scene cuối.
- Test Hub là bộ kiểm tra bổ sung: vào checkpoint tương đương và đối chiếu state với lượt đi liên tục. Pass từ checkpoint không thay cho pass từ tuyến thật. Tuyến qua minigame có nhãn ngoại lệ rõ ràng.
- Quan sát từng lần dừng thoại, lựa chọn, chuyển map, trả free roam và kết thúc. Lưu log, state map/event/page/command, switch/variable liên quan và snapshot RGSS tại các mốc quan trọng/lỗi.
- Không dùng chuột/phím vật lý. Không suy FPS, độ mượt, độ chóng mặt hoặc cảm giác chơi từ frame logic khi bỏ vòng trình chiếu/focus. Những phần đó để playtest người thật sau này.

## Tiêu chí kết luận và báo cáo

Mỗi case có mã, điểm xuất phát (tuyến thật/checkpoint/giả lập kết quả minigame), lựa chọn, expected, observed, điểm đã đi tới và bằng chứng. Phân biệt **đạt trong phạm vi**, **lỗi tái hiện**, **chưa kiểm tra**, **bị chặn bởi lỗi trước đó**, **cần review nội dung/thiết kế**. Không gộp đoạn bị bỏ qua thành đã đạt.

Thứ tự xử lý khi có yêu cầu sửa sau test:

1. Crash, treo, không đi tiếp, sai route/người nhận.
2. KUL/visibility/camera/pop/điều kiện lặp và thoại sai nhánh.
3. Xuống dòng, face, timing và trình bày.

Ưu tiên sửa nguyên nhân ở script dùng chung và regression các route liên quan. Sửa kỹ thuật phải giữ nguyên thứ tự script và các chỉnh sửa map/event của tác giả. Đổi tọa độ, hitbox, hành vi/canon chưa rõ, lời thoại bổ sung hoặc thay asset cần review; không dựng lại map hoặc tự cập nhật web app.

Báo cáo theo từng đợt: ma trận case đã chạy, lỗi gốc và phạm vi ảnh hưởng, ảnh/log tái hiện, phần đã sửa nếu được yêu cầu, phần còn cần tác giả review và checklist playtest trực tiếp. Không đợi tới hết 29 kịch bản mới báo một lỗi chặn chung.
