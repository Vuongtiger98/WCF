# Route implementation

`04-route-map.md` là cây route; thư mục này là lớp chuyển route thành map/event.

| Route | Map liên quan | Hiện trạng |
|---|---|---|
| Siêu thị: 4 món × 4 người nhận | Map006, Map019, Map037–039, Map036 | Đã dựng đủ 16 tổ hợp |
| Mì cay: tin/không tin Aira | Map010, Map020, Map019/047, Map014, Map038, Map036 | Hai nhánh hội tụ ở văn phòng chung, có free roam/ném tuyết |
| Hỏi Leo | Map013, Map056–060, Map038, Map036 | Đã dựng đủ ba nhánh và free roam/ném tuyết |
| Hỏi Shylvie | Map013 | Có không gian; cần xác định event thoại |
| Atlantis | Map010 → Map022 → Map021/026 → Map023 hoặc Map024 | Nhánh chase đã dựng; route sách dịch chuyển cho Shylvie đã hoàn chỉnh |

Route đầu tiên đã được chốt là ending Atlantis. Tuy nhiên map Atlantis chưa dựng; trước khi dựng route sẽ kiểm kê tuần tự các map hiện hữu, bắt đầu từ Map003 Văn phòng Silver Wing. Map generic được bỏ qua.

Map019 được giữ làm map test siêu thị, không thuộc route Atlantis. Flow đã đối chiếu V2 bắt đầu Map010 → Map022. Pha mì/nghỉ ngơi dẫn qua Map021 (điểm xuống Atlantis, không có thoại placeholder) rồi tới Map023 tiệm sách. Tìm chìa khóa, vào Map026 và đọc thư dẫn tới ký ức Map024 → Map028 do người dùng tự dựng → Map034 clone bao vây → Map029 chase QTE → Map025 đối đầu Vực Sâu → Map035 epilogue phòng ngủ/Group Chat → Map036 after-ending hint → Title. Map025 không phải scene Aira; đây là cảnh Hải Quỳ tự khẳng định tên Dahria. Không gộp nhánh tiệm sách và nhánh thư/chase nếu chưa có điều kiện hội tụ rõ trong nguồn.

Mỗi route cần ghi entry condition, transfer, flag đọc/ghi, gift/recipient, scene hội tụ, trao quà và ending. Không dùng `EVxxx` làm traceability; cần đổi tên event theo `SCN-xxx` sau khi route được duyệt.

## Route mì cay cho Leo

Flow runtime: Map010 → Map020 → nhánh Aira ghé montage Map019 hoặc nhánh Hải Quỳ đi thẳng → Map047 → Map014 → Map038 → Map036 → Title. Người nhận luôn là Leo; Group Chat không mở menu chọn bốn người.

Hai nhánh giữ riêng người mua nguyên liệu, cảnh ngủ/dậy và người nấu. Chúng hội tụ tại tiệc, nồi mì cay, Sting 20 lít, gag đá bào, vòng tặng quà và cuộc gọi khẩn từ Silver Wing. Route kết thúc đúng nguồn ngay khi Hải Quỳ rời tiệc; không thêm epilogue sáng hôm sau.

Map047 vẫn là map chuẩn bị riêng. Map038 dùng page theo Switch 55/58/59 để giữ route mì cay tách khỏi ma trận `MKT_GIFT`/`MKT_TARGET`: E001 chạy phần mở đầu, Switch 58 mở free roam/ném tuyết, page riêng của Leo bật Switch 59 và E118 chạy phần còn lại. Map048 chỉ giữ làm donor/rollback, không còn incoming transfer runtime. Map019 chỉ chạy E045 montage; Map014 E025 tự khóa bằng Self Switch A sau lần nấu đầu để người chơi có thể quay lại bếp trong free roam mà không lặp cutscene.

## Route sách dịch chuyển cho Shylvie

Flow runtime: Map023 E012 chọn sách → E002/E003 mang sách ra quầy → Map037 page `HQ_PREP_SCENE_VARIANT=49` chuẩn bị/ngủ quên → Map038 tiệc chung và free roam/ném tuyết → E119 trao sách → Map050 hậu truyện → Map036 ending hint ID 19 → Title. Map049 chỉ còn là map archive, không nằm trên runtime flow.

Map023 đóng KUL về opacity 255 trước khi transfer no-fade. Trên Map037, KUL kế thừa được hạ về 0 và hide trong lúc Fade Out native đầu tiên đang che việc dựng phòng. Ở cuối Map037, Fade Out native vẫn phủ được cả CG; trong lúc màn hình đã đen, event bật KUL opacity 255, ẩn CG rồi Fade In native lại dưới lớp KUL trước khi transfer. Vì vậy `Game_Screen` sang Map038 có brightness 255 nhưng khung hình vẫn được KUL che kín. Map038 dựng Player/NPC xong rồi mới reveal KUL `255 → 0`, chờ đủ 30 frame và sau đó mới hiện câu chào.

Map023 chỉ khóa E036 sau khi `ATL_BOOK_ID = 2`, không thay đổi nhánh nói chuyện chủ tiệm trước. Vì Hải Quỳ tỉnh muộn, page riêng trên Map038 chỉ giữ câu chào `Quỳ!! Hello!` ở B3044 rồi mở free roam; không chạy lại đoạn đến sớm/lập trình Sierra/chuẩn bị tiệc của route khác. Switch 61/62/64 và E119 giữ tile, vị trí NPC, hệ cửa phòng/bếp, route siêu thị và route mì cay nguyên vẹn. Nội dung trao quà và hậu truyện dùng compact B3033–B3044, B3074–B3091 và B3131–B3149. Map036 dùng nguyên ending hint B2740–B2745 với `ENDING_HINT_ID = 19`; nguồn không chỉ định ending CG cho nhánh này nên không tự gán ảnh.

## Route Ma Vương Cổ Đại cho Hakase

Flow runtime: Map023 E036 chọn sách → E002/E003 checkout → Map037 page `HQ_PREP_SCENE_VARIANT=51` chuẩn bị/ngủ quên → Map038 free roam/ném tuyết → E120 trao sách → Map052 hậu truyện → Map036 ending hint ID 20 → Title. Map051 chỉ còn là map archive, không nằm trên runtime flow.

Route dùng state riêng: Switch 66/67/68/69 và Variable 53, không dùng chung state của sách Shylvie. Nội dung lấy từ B3027–B3032, B3037–B3044, B3045–B3073, B3110–B3130 và hint B2746–B2760. `VayCV` (Gallery/Picture 80) và `Oplung` (74) xuất hiện đúng lúc trong vòng trao quà. Không có asset Hakase dạng mới hoặc ending CG trong project, nên giữ graphic hiện hữu và không tự thay bằng tài nguyên khác.

Quy tắc handoff ánh sáng giống route Shylvie: Map023 đóng KUL; Map037 dùng native fade để phủ cả lúc thay asset/CG, cài KUL đen khi native screen đang đen rồi Fade In native trước transfer; Map038 reveal KUL sau khi dựng nhân vật. Các page không dùng Tint Screen, CE03/CE05 hoặc tone của Map Effects. Nhánh nói chuyện chủ tiệm trước và ending Vực Sâu không bị nhập vào route tiêu chuẩn này.

## Route nói với chủ tiệm sách trước

Flow runtime: Map023 E002/E003 lần ba → Map053 phong ấn → Map054 Wanderer truy tìm → Map055 giải cứu → Map036 hint ID 21 → Title.

Route dùng compact B2925–B2952, B3092–B3108, B3150–B3186 và after-ending B2761–B2809. Đây là timeline riêng: không đi qua Paulie chase, không chạy chuẩn bị tiệc tiêu chuẩn và không mở free roam/ném tuyết. Switch 70/71 cùng Variable 54 giữ state riêng, không dùng state của hai route chọn sách.

Map053 chỉ dựng diễn biến hình ảnh để nối thách đấu với kết quả tự phong ấn đã được thoại Map055 xác nhận; không thêm lời thoại ngoài nguồn. Map055 làm vỡ `$Cage_1`–`$Cage_3` theo nhịp chậm ở vết nứt đầu rồi tăng tốc. Tất cả điểm chuyển dùng KUL opacity 255 và transfer no-fade; không gọi Fade Screen, Tint Screen hay common event camera/lighting legacy.

Hai placeholder đã được ghi rõ trong game: CG Hải Quỳ mỉm cười và phần hiển thị Drosalya. Khi asset thật được bổ sung, thay đúng hai điểm này, không dùng `Game_CG1/2` hoặc CG hiện có khác.

## Route hỏi Leo

Flow runtime: Map013 E097 tương tác lần ba → Map056 tin nhắn riêng với Leo → Map057 tiệm ma pháp, Map058 cà phê hoặc Map059 vũ khí → Map060 chuẩn bị/ngủ quên/thay đồ → Map038 free roam và ném tuyết → E121 trao quà → Map036 hint 22–24 → Title.

Ba kết quả giữ đúng compact: áo choàng tàng hình cho Hakase, cà phê Luminous cho Kohi và viên đá nứt thành khiên huyền thoại cho Shylvie. `Datangcv`/Gallery 54 xuất hiện lúc mua viên đá; `Khienriset`/65 và CG15/32 chỉ xuất hiện khi đá vỡ ở tiệc. Áo choàng dùng Gallery 43, cà phê dùng 51.

Map057 dùng `$VapeEden` tại quầy. Ba frame hàng đầu được điều khiển bằng custom Move Route theo nhịp 60 frame mỗi hình; không dùng stepping animation mặc định. `!$Falling` được dành riêng cho hậu truyện sách dịch chuyển trên Map050, không dùng trong Map057.

Toàn flow mới dùng KUL để tối/sáng và transfer no-fade sau khi KUL đã đen. Không dùng Fade Screen, Tint Screen hoặc tone của Map Effects. Các face/chân dung chưa có được ghi placeholder text thay vì mượn asset sai nhân vật.

## Route siêu thị: Máy pha cà phê

Flow hiện tại: Map019 chọn quà → E042 thanh toán → Group Chat bắt buộc chọn Leo/Kohi/Shylvie/Hakase → nếu chọn máy pha cà phê thì Map040 xuống Atlantis và chọn mang cà phê thường về hoặc câu đủ 10 tôm vàng để lấy cà phê Atlantis → Map037 chuẩn bị quà/ngủ quên → Map038 tiệc Giáng sinh → Map039 epilogue riêng → Map036 hint riêng → Title. Lựa chọn Map040 tạm thay điều kiện check tin Momo: Switch 52 OFF dùng nguyên nhánh `[không check Momo]`, ON dùng nguyên nhánh `[check Momo]`. Ba món quà khác vẫn đi thẳng từ Map019 sang Map037.

Đã triển khai đủ ma trận 4×4 của nhánh siêu thị: máy pha cà phê, dao/chảo, khăn len và bộ phá khóa đều có bốn người nhận. Map037 chọn cảnh chuẩn bị bằng `MKT_GIFT` + `MKT_TARGET`; Map038 chọn nguyên Scene 9 tương ứng; Map039 dùng Scene 13 riêng của dao/chảo và bộ phá khóa, cảnh kết chung của khăn len, cùng hậu truyện cà phê có/không Atlantis. Map036 có 16 hint Bully Quỳ và Gallery dùng ID 10–25.

Variable 43 xuyên suốt route: `1 Leo`, `2 Kohi`, `3 Shylvie`, `4 Hakase`. Gallery tương ứng dùng ID 10–13 và `ED_MKT_COFFEE_LEO/KOHI/SHYLVIE/HAKASE`. `ENDING_HINT_ID` nhận 2–5 theo cùng thứ tự.

Đã đối chiếu lại với `GAME_SCRIPT_AI_COMPACT_V2`: lựa chọn máy pha cà phê có đủ phần Hải Quỳ cân nhắc bốn người nhận; Map037 giữ nguyên cảnh lo lắng ban đêm nhưng phần sáng Giáng sinh đã phục hồi đúng PoV Aira; Map038 đã phục hồi đoạn Aira đến văn phòng sớm, phủ tuyết, gặp cả nhóm, bữa ăn, hội thoại về bộ giáp và board game. Điểm khám phá tự do/ném tuyết vẫn nằm trước khi tiếp tục phần trao quà.

- Variable 42 lưu món quà và Variable 43 lưu người nhận; không dùng lại các switch 4–7 cũ của Map019.
- Hai cụm E005–E007 và E008–E010 là hai NPC thu ngân cùng các ô bàn tương tác, không phải event trùng cần xóa.
- Cả bốn tổ hợp Máy pha cà phê/Leo–Kohi–Shylvie–Hakase đã có cảnh chuẩn bị, trao quà, epilogue, gallery và hint. Mười hai tổ hợp thuộc ba loại quà khác vẫn chưa phải ending hoàn chỉnh.
- Nhánh epilogue hiện dùng biến thể “không check tin nhắn Momo”, vì menu điện thoại chưa lưu trạng thái đã mở riêng tin nhắn đó.
