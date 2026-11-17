# Kiểm tra và sửa từ mở đầu tới hết xe bus — 16/11/2026

Đã push mốc trước khi sửa lên `origin/master`: **8f76ac6**, `Unify phone save-load theme and streamline confirmations`. Các thay đổi trong báo cáo này được thực hiện sau mốc đó, hiện ở workspace.

## Các lỗi đã sửa

| Lỗi | Nguyên nhân và cách sửa |
|---|---|
| Map/pop lệch sau khi chuyển từ map nhỏ sang map lớn | Yanfly cập nhật viewport map, nhưng Map Effects giữ bản sao kích thước cũ `(48,32,544,416)`. Renderer nay đồng bộ rect trước mỗi update, kể cả khi effect đang tắt, và làm mới snapshot khi đổi kích thước kể cả refresh bị đóng băng. |
| Đuôi pop không trỏ đúng nhân vật khi camera zoom | Pop dùng chung phép đổi tọa độ với renderer, gồm offset viewport, zoom, mirror và rotation; không thêm offset riêng vào event Silverwing. |
| Điểm neo xoay ngược chiều Sprite thật | Probe native phát hiện công thức cũ dự đoán Y=376 trong khi marker thật ở Y=168 tại góc 90°. Đổi dấu góc trong cả phép đổi tọa độ và phép đổi ngược; sửa cả fallback Pop Message. |
| Balloon trên Hải Quỳ bị cắt sát mép trên | `Sprite_Character` giới hạn balloon theo cả viewport nguồn lẫn khung sau biến đổi. Chỉ dịch balloon; không di chuyển nhân vật/camera. NPC ngoài màn hình không bị kéo balloon vào mép; event không có graphic vẫn dùng được làm neo cho NPC trên parallax. |
| Chữ pop khó đọc trên nền bàn làm việc | Thêm nền tối riêng trong pop, theo vị trí/kích thước/openness. Nền ẩn ngay khi chuyển sang thoại thường hoặc Group Chat, và giải phóng bitmap thuộc sở hữu khi dispose. Không đổi windowskin dùng chung. |
| Các trang thoại chỉ còn một vài từ cuối câu | Chia lại dòng/trang tại 4 nhóm ở Map003 và 7 nhóm ở Map010, dùng grapheme Unicode, tối đa 4 dòng và 33/40 ký tự tùy face. Không thay từ, face, background, vị trí message hay các lệnh hành động. |
| Lỗi chữ tại Silverwing | `kỳ nghi vui vẻ` → `kỳ nghỉ vui vẻ`; thống nhất `Beta-M34` → `Beta M-34`. |
| Không đọc được bảng thống kê E13 | Event nằm trên ô tường không đi vào được nhưng priority là Below Player. Chuyển riêng page này sang Same as Player, tương tự bảng bên cạnh, để đọc từ phía trước; đã tương tác thành công bằng luật va chạm thật. |

Phần cất hồ sơ: tuyến vào thật từ Map004 đặt Hải Quỳ ở `(5,3)`, hướng lên tủ E10 `(5,2)`. Vì vậy giữ nguyên vị trí và các lệnh balloon/âm thanh hiện có; không thêm một đoạn đi tới tủ khác.

`CV_Normal` trong phần giới thiệu Shylvie trên xe bus đã được mở kiểm tra: đúng graphic nhân vật tóc xanh. Không đổi face chỉ dựa vào tên file.

## Kết quả chạy trong engine

Dùng **Game.exe/RGSS301, Ruby 1.9.2**, bắt đầu từ Title → Game mới → checkpoint mở đầu trong Test Hub → Map004 → Silverwing. Lệnh Input logic điều khiển player theo passability thật, xác nhận message và chọn nhánh. Không dùng chuột/phím thật, không bỏ qua interpreter, forced move, camera, KUL, va chạm hay thời gian chờ của event. Các lựa chọn bus được chạy trong các phiên mới độc lập.

Harness chỉ bỏ vòng trình chiếu/focus của `Graphics.update`, transition và fade của cửa sổ ẩn; thời gian logic vẫn tăng. Ảnh dùng trực tiếp **`Graphics.snap_to_bitmap`**, không ghép lại bố cục. Frame ở bảng dưới là frame logic, không phải số liệu FPS hoặc đánh giá độ mượt trên laptop.

| Lựa chọn bus | Điểm đến đã chạy | Pauses quan sát | Điểm kết thúc kiểm tra |
|---|---|---:|---|
| Tới siêu thị | Map019 `(26,35)`, hướng xuống | 134 | Free roam, player movable, không transparent/through |
| Tới văn phòng Wanderer | Map013 `(4,4)`, hướng xuống | 73 | Đã sáng và hiện thoại vào văn phòng |
| Xuống Atlantis | Map022 `(10,39)`, hướng lên | 67 | Đã sáng và hiện thoại tới Atlantis |
| Mua mì cay | Map020 `(15,12)`, hướng lên | 69 | Đã sáng và hiện thoại tới quán mì cay |

Ba nhánh sau kết thúc ở thoại của cutscene đón vào map; `movable=false` tại thời điểm đó là vì message đang chạy. Không coi đây là bằng chứng đã kiểm tra free roam của các route phía sau.

- **343 lần dừng thoại**, trong đó **85 pop**: tất cả rect message nằm trong `640×480`; viewport nguồn và Map Effects khớp tại các mẫu; sai số ngang đuôi pop lớn nhất **0,4 pixel**.
- **3.300 frame có balloon**: không phát hiện clipping trong viewport được quan sát.
- Tất cả mẫu thoại thường đều không còn nền pop; toàn bộ thoại Silverwing dùng player sprite `!$HaiQuy`. Thành phố chuyển sang thường phục theo event hiện có.
- Có lượt đi qua hành lang Map017; lượt đọc fax hai lần bật Switch 2 rồi rời văn phòng bỏ qua hành lang theo đúng điều kiện hiện tại. Đã xác nhận cả lựa chọn `Chưa xong` và `Xong rồi` ở cửa ra.
- Chat điện thoại lưu **49 tin nhắn** trong cả bốn phiên; trở lại map và tới bus được. Không ghi nhận crash native trong các lượt đạt.
- Các điểm kết thúc đều có screen brightness `255`, KUL opacity `0`, player không transparent/through và không bị khóa bởi StopPlayer/StopNPC. Passability thật tìm được bước đi ra khỏi ô đến.
- Lượt siêu thị đọc thành công **50 tương tác tùy chọn** tại Silverwing, gồm E13 sau sửa.

Probe Sprite riêng tại `projection_fixed/` dùng marker màu và đọc pixel từ native snapshot: góc 90°, 31°, 31° kèm mirror và mirror không xoay. Sau sửa, sai số centroid lớn nhất **1,31 pixel** do raster hóa; hai ca 90° và mirror không xoay khớp chính xác. Các ca này kiểm tra chiều xoay/offset thật của engine, bổ sung cho kiểm tra nghịch đảo bằng toán.

## Phần giữ lại để review thiết kế

E17 và E47 là hai mô tả cây nguy hiểm. Trong lượt tìm đường an toàn, vị trí đọc chúng chỉ tiếp cận được qua trigger cây/bad ending E18 hoặc E64. Không tự dời event hay gỡ bad ending để làm chúng đọc được. Nếu muốn người chơi có cơ hội đọc lời cảnh báo trước khi bị cây tấn công, cần quyết định riêng về hitbox/thứ tự kích hoạt.

Chưa đánh giá độ mượt thực tế, cảm giác nhập phím hay âm lượng/cách phối nhạc bằng tai. Chưa kiểm tra toàn bộ diễn biến sau các điểm đến bus, load save cũ giữa cutscene hoặc vị trí neo khi dùng wave/distortion. Đây là kiểm tra native bằng lệnh và ảnh, không phải playtest điều khiển thật.

## Phạm vi và cách tái hiện

Chỉ ba slot script đổi: **44 Sprite_Character, 150 Map effects, 203 Pop Message**. Giữ nguyên toàn bộ 222 slot, ID, tên, thứ tự và CSV. Map003 chỉ đổi thoại và priority E13; Map010 chỉ đổi chia dòng/trang. Audit đối chiếu 117 event trên sáu map xác nhận giữ nguyên vị trí, graphic, điều kiện, move route, walk/step, tile/parallax và các lệnh ngoài message. Map004/006/017/069 giữ nguyên byte. Không cập nhật webapp test.

Backup: `Data/codex_backup_prologue_20261116/`. Bằng chứng native nằm trong `Save/PrologueQA_20261116/accepted0` … `accepted3`; mỗi thư mục có `native.log`, captures PNG và dữ liệu Marshal. Tổng hợp tại `verified-summary.json`. Probe bổ sung dùng `tools/qa_map_projection_native.rb`, chỉ thay observer trong pack bản sao.

```powershell
ruby tools/qa_prologue_summary.rb
ruby tools/audit_prologue_scope.rb
ruby tools/test_prologue_rendering.rb
ruby tools/test_pop_message_width.rb
ruby tools/test_script_graphics_lifecycle.rb
ruby tools/test_phone_menu_animation.rb
ruby tools/test_phone_save_load.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
ruby -W0 tools/rvdata2_audit.rb audit-bus-route-choice-branches
ruby -W0 tools/rvdata2_audit.rb audit-kul-transfer-handoffs
```

Bộ rendering/performance: **22 case / 420 assertion**; lifecycle: **7/18**; phone animation/layout/performance: **32/801**; Save/Load: **29/758**; năm kiểm tra pop độc lập đều đạt. Inventory/semantic/choice audit không có lỗi; KUL audit 49 black transfer/148 entry page không failure.

Để tạo phiên native mới, dùng `ruby tools/qa_prologue_build.rb Save/<thư-mục-mới> <nhánh-0..3>`, tạo junction `Graphics`, `Audio`, `System` trỏ tới thư mục tương ứng ở project, rồi chạy Game.exe bản sao với working directory của bản sao. Builder chỉ chèn một observer trước Main trong pack bản sao; không viết lại map sản xuất. Chạy lần lượt để tránh tranh tài nguyên khi không cần nhiều phiên đồng thời.
