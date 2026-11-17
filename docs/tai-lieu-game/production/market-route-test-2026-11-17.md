# Kiểm tra nhóm route siêu thị — 17/11/2026

**Kết quả:** 16 tổ hợp quà/người nhận và 4 lượt cà phê Atlantis đều tới đúng ending rồi Title, không ghi nhận crash hoặc đổi nhầm route. Tuy nhiên, nhóm này **chưa đạt toàn bộ phạm vi khám phá**: có một cửa ra bị chặn và một NPC không thể tương tác. Có các khác biệt nội dung cần writer review trước khi sửa.

Đây là lượt kiểm tra bằng lệnh trong `Game.exe`/RGSS301, trên các bản sao QA độc lập. Không sửa Data, script runtime, vị trí event, Test Hub hoặc web app. Hash toàn bộ Data gốc và các file xuất trong Scripts vẫn khớp manifest đầu lượt. Những thay đổi chưa commit từ công việc trước được giữ nguyên.

## Phạm vi và cách chạy

- Mỗi case nền: New Game → tương tác Test Hub E004 → checkpoint xe bus → chọn **Tới siêu thị**. Sau đó đi bằng collision/passability thật, tương tác event, lựa chọn, chat, chuẩn bị quà, tiệc/free roam, hậu truyện, hint và Title. Không teleport để vượt đoạn bị chặn.
- Không chạy lại Silver Wing ở từng case. Đây là lượt tiếp tục từ checkpoint bus, không phải kiểm tra New Game thường xuyên suốt từ phần mở đầu.
- Bốn lượt Atlantis gọi API trả kết quả câu tôm `10` trong bản sao QA. **Không kiểm tra minigame câu tôm.** Ném tuyết chỉ thử lời mời/hủy; không chơi hoặc đánh giá thắng/thua.
- Dùng tùy chọn hiện chữ ngay để chạy ma trận. Message, interpreter, forced movement, camera, KUL và renderer vẫn chạy; vòng trình chiếu/focus được bỏ chờ. Không dùng kết quả này để kết luận FPS, độ mượt, nhịp thoại, âm lượng hoặc cảm giác chơi bằng bàn phím thật.
- Kiểm tra bổ sung: các quầy/NPC siêu thị, hủy xem quà, chọn tiếp, phòng phụ sau tiệc, nhặt RAM, menu và hai checkpoint đan khăn trong Test Hub. Các phần dùng chung được kiểm tra sâu trên một tổ hợp; không nhân kết luận đó thành mọi cách tương tác ở cả 16 tổ hợp.

## Ma trận tuyến chính

Mỗi ô là **đạt luồng chính — Hint ID**. Tất cả giữ đúng V42/V43, S45 hoàn tất tiệc, S46 mở ending và ảnh nền Title tương ứng.

| Quà | Leo | Kohi | Shylvie | Hakase |
|---|---|---|---|---|
| Máy pha cà phê, chọn cà phê thường | Đạt — 2 | Đạt — 3 | Đạt — 4 | Đạt — 5 |
| Dao/chảo | Đạt — 6 | Đạt — 7 | Đạt — 8 | Đạt — 9 |
| Đan khăn | Đạt — 10 | Đạt — 11 | Đạt — 12 | Đạt — 13 |
| Bộ phá khóa | Đạt — 14 | Đạt — 15 | Đạt — 16 | Đạt — 17 |

Bốn lượt máy pha cà phê → đi câu → giả lập kết quả 10, lần lượt Leo/Kohi/Shylvie/Hakase, cũng đạt đúng ending; S52 bật. Bốn lượt cà phê thường giữ S52 tắt. Không coi hai lựa chọn này là tám ending độc lập.

Log chính ghi **6.085 lần dừng thoại** trong các map 019/037/038/039/040/036. Không tìm thấy cửa sổ trong tập này vượt 4 dòng hoặc giới hạn 33/40 ký tự hiển thị; đếm Unicode sau NFC và bỏ mã điều khiển. Face được gọi đều có file và index 0–7 hợp lệ. Điều này chưa chứng minh mọi biểu cảm được chọn là phù hợp về diễn xuất, hoặc mọi đoạn thoại không đi qua `input_pause` đều đã kiểm tra.

## Lỗi đã tái hiện

### MKT-001 — Không thể ra khỏi phòng chế tạo Map063

**Ưu tiên cao:** vào phòng phụ này trong free roam thì không quay về văn phòng qua cửa được.

1. Trong free roam Map038, đi vào phòng chế tạo qua E131.
2. Player tới Map063 tại `(5,10)`.
3. Đi về cửa E002 tại `(4,10)` để ra ngoài: player không đi vào ô đó được; event không chạy.

E002 hiện là **Below Player / Player Touch**, nhưng ô `(4,10)` bị chặn cả bốn hướng. Dò đường theo `Game_Player.passable?` không tìm được đường tới ô cửa. Probe độc lập đặt đúng state/điểm đến cũng tái hiện: đi sang phải rồi quay lại được, đi vào cửa không được. Bấm xác nhận không khởi động E002.

Ảnh: [player ở cạnh cửa nhưng không thể đi vào](../../../Save/MarketQA_20261117/boundary_room63_v2/captures/04_boundary_final.png). Dữ liệu: `boundary_room63_v2/boundary-probe.marshal`; lượt đi liên tục đã gặp lỗi trong `pilot3_g3_t3`.

**Hướng sửa cần review vị trí/hitbox:** làm ô cửa có thể bước vào, hoặc dùng vùng kích hoạt ở ô đi được. Không tự di chuyển cửa hoặc chỉnh tileset trong lượt test này. Cần test lại cả vào/ra và giữ đúng office variant sau sửa.

### MKT-002 — Không thể nói chuyện NPC E005 ở siêu thị

**Ưu tiên vừa:** mất hội thoại phụ, không chặn thanh toán hay ending.

NPC `NPC-CASHIER-A`, Map019 E005, nằm tại `(16,19)`, page đầu **Same as Player / Action Button**. Từ khu đi bộ phía trước quầy, ví dụ `(16,21)`, không thể tiếp cận NPC. Ô quầy `(16,20)` bị chặn và không có cờ **Counter**, nên xác nhận từ phía trước không nói chuyện xuyên quầy được. Các ô cạnh NPC không có đường đi hợp lệ từ khu player đang đứng.

Đã thử trong lượt khám phá thật và probe ở trước quầy; E005 không được khởi động. Không nhầm NPC này với E008 dùng trong luồng thanh toán: thanh toán vẫn chạy được.

Ảnh: [bố trí quầy và NPC](../../../Save/MarketQA_20261117/boundary_cashier_v2/captures/01_boundary_initial.png). Dữ liệu: `boundary_cashier_v2/boundary-probe.marshal` và job E005 trong `survey_safe2_g3_t3`.

**Hướng sửa cần review:** chọn hitbox nói chuyện phù hợp hoặc cấu hình counter đúng ô quầy. Page tiếp theo còn cần kiểm tra lại khả năng tương tác lặp sau khi mở được page đầu; hiện chưa chơi tới page đó bằng đường hợp lệ.

## Nội dung cần writer review

Đối chiếu compact V2 và **9.015 đoạn văn của 8 DOCX** thuộc bốn nhóm quà. Bộ so khớp đánh dấu 47 mảnh chưa khớp nguyên văn, nhưng chúng bao gồm nhiều bản lặp của cùng Common Event và khác biệt dấu câu. **Không phải 47 câu bịa hoặc 47 lỗi.**

| Mục | Quan sát | Đề nghị |
|---|---|---|
| Common Event 019 — thanh toán | Những câu như “Xin chào! Quý khách đã chọn xong quà Giáng sinh rồi chứ?”, mô tả máy quét/túi quà và lời chúc chưa tìm được câu tương ứng trong các nguồn đã đối chiếu. Đây là lời nối phục vụ flow thanh toán đang có. | Writer xác nhận hoặc cung cấp câu thay thế; không tự xóa luồng thanh toán. |
| Map040 E001 — lấy cà phê | Phần dẫn về Momo, thông báo quái vật/mái nhà thị chính, quán hết cà phê và hướng dẫn câu tôm có lời viết khác hoặc chưa khớp nguồn. DOCX `Route Mayphacaphe`, đoạn 459–475 và các nhánh tương ứng, dùng điều kiện đã/chưa đọc tin Momo; runtime hiện chọn cà phê thường/đi câu và dùng S52. | Xác nhận thiết kế đã đổi, điều kiện Momo còn cần hay không, và duyệt lời hiện tại trước khi sửa. Kết quả test chỉ xác nhận flow đang có chạy được. |
| Cà phê tặng Kohi | DOCX có đoạn đang trong nhánh Kohi nhưng ghi tặng **Leo** (ví dụ đoạn 834/860). Runtime đã ghi **Kohi**. | Giữ phân biệt lỗi nguồn và lỗi runtime; không chép lỗi tên trong DOCX trở lại game. |
| Khăn Shylvie/Hakase | `Route Khanlen` đoạn 576 nói khăn xanh nhưng tiếp tục “màu đỏ”; đoạn 597 trong nhánh Hakase lại nhắc Leo/khăn đỏ. Runtime hiện dùng xanh/Shylvie và tím xám/Hakase. | Không tái hiện lỗi nhầm người nhận cũ. Màu tím xám vẫn nên được tác giả chốt nếu chưa phải màu đã duyệt. |
| Các mảnh còn lại | Ví dụ câu Pokemon đổi dấu phẩy thành dấu chấm; câu máy ép MK25 bị ngắt bởi mô tả sprite trong DOCX; dấu gạch ngang ở “Xin lỗi mọi người”. | Không xếp thành lỗi nội dung chỉ vì bộ so khớp nguyên văn báo khác. |

Ảnh kẹp mở trong thư viện ở bốn nhánh khăn lần lượt đúng: Leo `CG2`, Kohi `CG5`, Shylvie `CG3`, Hakase `CG4`. Các đoạn chuẩn bị được quan sát không còn kể đang đan khăn cho người khác.

## Những phần bổ sung đã kiểm tra

- **Chuẩn bị/ngủ:** cả 20 case có giai đoạn Hải Quỳ ở `(11,7)`, về `(8,5)`, chuyển `HQ_Room_Sleep`, player ẩn và graphic event Hải Quỳ được bỏ. Event giữ giấc ngủ thêm 180 frame logic sau fade-in. Không gặp màn hình đen chặn việc đi tới văn phòng.
- **CG:** ảnh đánh thức hiện cùng khung đen ở giữa màn hình; chuỗi sau tiếp tục tới thay đồ. Không ghi nhận cửa sổ thường ra ngoài màn hình hoặc backdrop pop còn sót trong các lượt được quan sát. Ảnh mẫu: [đánh thức](../../../Save/MarketQA_20261117/visual_g3_t3/captures/15_message_70.png).
- **Vùi tuyết:** ảnh renderer chỉ có Hải Quỳ bị vùi, Kohi và Shylvie; không có sprite Hải Quỳ thường đứng chồng. Sau đó mới tới CG cười và chuỗi kéo tuyết. Xác nhận hình ảnh sâu trên case khăn/Shylvie, dùng cùng hàm staging cho các tổ hợp. Ảnh: [trước CG](../../../Save/MarketQA_20261117/visual_g3_t3/captures/55_message_140.png), [CG cười](../../../Save/MarketQA_20261117/visual_g3_t3/captures/56_message_141.png).
- **Chuẩn bị bàn/đắp tuyết:** trace layer của lượt hình ảnh ghi `prepare` → `snowbuild_2/1` luân phiên **10 vòng** → `Party_Before`. Camera snowbuild có display gần `(24,16)`, focus `(34,23)`; ảnh thấy Leo/Quỳ ở giữa khu đắp tuyết. [Ảnh mẫu](../../../Save/MarketQA_20261117/visual_g3_t3/captures/86_layer_phase_59.png). Lượt observer đầu đọc sai cấu trúc mảng layer; đã sửa observer và chạy lại case hình ảnh, không dùng dữ liệu layer cũ để kết luận.
- **Trả NPC:** phase vào free roam của 20 case thống nhất: player `(14,21)` hiện sprite Giáng sinh, E002 không có graphic/được ẩn; Shylvie `(15,19)`, Kohi `(11,22)`, Leo `(14,18)`, Hakase `(9,20)`. Không tái hiện việc thiếu Leo/Hakase hoặc nhân đôi Hải Quỳ ở các mốc này.
- **Đi phòng phụ:** lượt khám phá vào/ra được Map042/043/044/045/046, bếp Map014 và phòng họp Map062 rồi tiếp tục route. Map063 bị chặn như MKT-001; không đánh dấu đạt.
- **Hủy/khám phá:** xem và hủy các quà không làm đổi món/người nhận; lựa chọn đi chọn tiếp giữ free roam, sau đó vẫn thanh toán được. Từ chối lời mời ném tuyết của bốn NPC không làm bắt đầu minigame.
- **RAM/menu:** nhặt đủ 10 RAM qua E008–017, nhận thoại và quan sát cutscene Diana ở lần đạt 10. Sau đó mở thư viện, Save, Settings, Load thật tại tiệc; tải lại giữ vị trí, route và quyền di chuyển rồi đi tới ending. Chưa kiểm tra farm bằng ném tuyết, spam tương tác sau nhiều lần reload hoặc mọi thao tác ghi đè/xóa save.
- **Test Hub:** chạy E018 chọn Shylvie và Hakase tới ending tương ứng. Nội dung chat người nhận khớp lượt đi từ bus sau khi bỏ ID tin nhắn nội bộ. Sprite player ở frame transfer đầu khác giữa Hub/tuyến bus, nhưng sau setup player bị ẩn và dùng cùng event cảnh; chưa thấy khác biệt hình ảnh do trạng thái đó. Không coi hai case này là đã kiểm tra mọi checkpoint Hub.

## Đính chính flow tài liệu

Map040 có đường vào hợp lệ qua **Common Event 019**, không phải qua Map039:

```text
Bus → Map019 → CE019 thanh toán/chọn người nhận
  Máy pha cà phê → Map040 → Map037
  Ba quà còn lại ─────────→ Map037
→ Map038 → Map039 → Map036 → Title
```

Lượt lập kế hoạch trước chỉ dò transfer trực tiếp trong map nên chưa thấy đường vào. Đã sửa mô tả route cho đúng sự kiện đang chạy; không nối thêm map hoặc sửa phân nhánh game.

## Bằng chứng và chạy lại

Thư mục dữ liệu cục bộ: `Save/MarketQA_20261117/` (được Git ignore, không phải nội dung đã push).

- [Tổng hợp 20 case](../../../Save/MarketQA_20261117/summary.json), [6085 bản ghi thoại](../../../Save/MarketQA_20261117/observed-messages.json).
- [Probe, job, checkpoint và layer](../../../Save/MarketQA_20261117/supplementary-summary.json), [state staging 20 case](../../../Save/MarketQA_20261117/staging-summary.json).
- Case nền lấy từ `cases.txt`. Các case `pilot*`, `flow_g1_t1`, `survey_safe_g3_t3` là lượt phát triển observer, không nằm trong ma trận được chấp nhận. Lỗi observer/điều khiển đã loại không được báo thành crash game.
- Công cụ: `tools/qa_market_build.rb`, `tools/qa_market_native.rb`, `tools/Run-MarketQA.ps1`, `tools/qa_market_summary.rb`. Builder thêm observer vào **bản sao** trước Main, giữ nguyên mọi entry script gốc. Khi chạy lại phải dùng thư mục case mới, không ghi đè log cũ.

Nguồn đọc: [compact V2](../../kich%20ban/GAME_SCRIPT_AI_COMPACT_V2.md); [Route máy pha cà phê](../../kich%20ban/Route%20Mayphacaphe.docx), [khăn](../../kich%20ban/Route%20Khanlen.docx), [dao/chảo](../../kich%20ban/Route%20DaovaChao.docx), [phá khóa](../../kich%20ban/Route%20Bophakhoa.docx) và bốn bản `Kịch bản Wonder Christmas Fiesta_*` tương ứng. Số đoạn trong bảng là thứ tự đoạn XML được trích, không phải số trang Word. Các DOCX chỉ được đọc nội dung, không sửa.

## Tiếp theo khi sửa lỗi được yêu cầu

1. Review hitbox/ô cửa rồi sửa MKT-001; chạy lại round trip Map038 ↔ Map063.
2. Review vùng nói chuyện rồi sửa MKT-002; kiểm tra cả page đầu và tương tác lặp.
3. Writer chốt phần cà phê/Momo và lời nối thanh toán. Chỉ thay nội dung sau khi chốt, không tự khôi phục lỗi tên/màu của DOCX.
4. Chạy lại các case chịu ảnh hưởng và bổ sung playtest người thật cho nhịp animation, âm thanh và cảm giác điều khiển. Các nhóm route khác trong kế hoạch sau bus vẫn chưa chạy ở lượt này.
