# Thư viện vật phẩm — 17/11/2026

Ứng dụng **Túi đồ** trong điện thoại mở `Scene_ItemLibrary`, thay cho túi đồ sử dụng vật phẩm mặc định. Đây là bộ sưu tập những vật phẩm đã gặp qua các lượt chơi; không phải số vật phẩm hiện người chơi đang giữ.

## Giao diện

- Điện thoại ngang 460×336, lưới **6 cột × 3 hàng = 18 ô mỗi trang**, có số đã khám phá và số trang. Ô ảnh 62×62; tên món đang chọn hiện riêng dưới lưới. Trang cuối giữ ô trống để bố cục ổn định, không chọn được ô ngoài danh mục.
- Mục chưa khám phá chỉ hiện dấu hỏi và “Chưa khám phá”, không lộ tên hay ảnh.
- Mũi tên chọn (↑↓ di chuyển sáu ô), Q/W đổi trang, Z mở chi tiết. Chi tiết ngang có ảnh cận vật phẩm bên trái và mô tả bên phải; Z xem ảnh gốc toàn màn hình, X quay lại từng bước.
- Mở từ menu: điện thoại xoay dọc→ngang trong 24 frame, khóa input và ẩn nội dung trong lúc xoay. X ở lưới xoay ngang→dọc rồi mới trở về menu, không lặp slide-in. Caller trực tiếp dùng ngang tĩnh, không xoay về dọc khi trả về. Xem vật phẩm không sử dụng, cấp thêm hoặc trừ vật phẩm trong gameplay.
- Thumbnail cắt cận vật phẩm thay vì thu nhỏ nguyên ảnh có nhiều nền trống. `LIB_FOCUS` định vùng riêng cho CG2–CG5; các ảnh quà còn lại dùng vùng phía trong khung trưng bày 640×480, tự tỉ lệ theo kích cỡ bitmap. Chỉ thay vùng nguồn khi vẽ UI, không sửa file ảnh; chế độ ảnh gốc vẫn giữ đầy đủ hình.
- Có 44 ảnh vật phẩm đã đăng ký (CG2–CG5 và các mã ảnh cũ 42–81), item 18 RAM và bốn thẻ biến hình TFCard1–4: tổng mặc định **49 mục**. Item 17 là đèn thử cơ chế KUL và bị loại khỏi thư viện, kể cả khi đã nhận/đã lưu trong dữ liệu thư viện cũ. Các vật phẩm Database khác chỉ thêm vào danh mục sau khi thực sự nhận được; không bày toàn bộ item/equipment RTP mặc định như các mục khóa.
- 45 mục quà/RAM có mô tả đã duyệt; bốn thẻ có mô tả do tác giả cung cấp ngày 20/11/2026, lưu trong `WCFItemLibrary::DESCRIPTIONS`. Tên hiển thị đổi thành **Bánh phô mai cam** và **Kim cương hình hạt cà phê** cho đúng bản chất vật phẩm; file ảnh/key giữ nguyên. [Danh sách mô tả đã duyệt](../production/item-library-descriptions-draft-2026-11-17.md).
- Một số ảnh đã có tài nguyên nhưng chưa có cảnh tham chiếu vẫn giữ khóa. Không tự chèn cảnh hoặc bịa điều kiện mở để làm đầy bộ sưu tập.

## Điều kiện khám phá

1. `Game_Party#gain_item` với số lượng dương: mở mục Database tương ứng (item/weapon/armor), ngoại trừ `item:17`; gọi tiếp toàn bộ logic gốc gồm cơ chế RAM.
2. `Game_Picture#show`: nếu ảnh là một trong 44 ảnh vật phẩm đã đăng ký thì mở mục ảnh đó.
3. `GlobalGallery.unlock(ID)` và `enable_picture(ID)` cũ: nếu ID thuộc ảnh vật phẩm thì chuyển sang thư viện, không mở slot ảnh đó trong Gallery và không phát thông báo “CG mới”. Điều này giữ nguyên các điểm mở khóa event đang có, kể cả CG có khung đen dùng `WCFGalleryScene`.
4. Khi mở thư viện, vật phẩm trong inventory và các thẻ biến hình đã mở trong save được ghi nhận để phù hợp trạng thái lượt chơi hiện tại.
5. `TransformMagic.unlock` ghi nhận TFCard tương ứng. Riu mở ở New Game; Gamemerr qua 1.000 điểm Invaders siêu thị, Sanic qua 1.000 điểm CattoPetting phòng Kohi, Diana sau cuộc gặp 10 RAM tại Map038. Thẻ vẫn giấu ảnh/tên trước khi khám phá, không nằm trong Gallery. Lưới/chi tiết crop mặt trước của thẻ, xem ảnh gốc giữ đủ bố cục TFCard.

“Đã gặp” đối với ảnh nghĩa là được hiện trong cảnh/điểm mở khóa đã có, không bắt buộc còn sở hữu món đó. Chỉ đọc tên trong một dòng thoại không tự mở mục; không đoán theo từ khóa. Tải bitmap vào Cache để dựng menu không mở khóa mục. Vật phẩm đã tặng, dùng hoặc tiêu hao vẫn được giữ trong bộ sưu tập.

API cho event/script bổ sung sau này:

```ruby
WCFItemLibrary.encounter_picture("CG2")
WCFItemLibrary.encounter_item($data_items[18])
WCFItemLibrary.unlocked?("picture:cg2")
WCFItemLibrary.unlocked?("item:18")
```

Ảnh dùng key ổn định theo tên file viết thường; Database dùng loại và ID (`item:18`, `weapon:1`, `armor:1`). Không gộp vật phẩm Database chỉ vì trùng ID giữa các loại.

## Lưu chung giữa các lượt chơi

`Save/ItemLibrary.rvdata2` chứa phiên bản cấu trúc và danh sách key đã khám phá. File tách khỏi `Game_System` và save từng lượt; New Game hoặc load một save cũ không làm mất khám phá. Các mở khóa ảnh vật phẩm có sẵn trong `GlobalGallery` được nhập sang thư viện khi khởi tạo, không thay ID ảnh hoặc xóa Gallery cũ.

Ghi qua file tạm, giữ bản trước ở `.bak`; nếu file chính hỏng thì đọc bản sao lưu. Mỗi mục chỉ ghi khi mở mới; nếu ghi lỗi, game tiếp tục và thư viện báo “Chưa ghi được bộ sưu tập lên đĩa”. Gặp lại mục sau khi sửa được quyền ghi sẽ thử ghi lại. Bộ cập nhật game đã bảo vệ toàn bộ `Save/`, nên cũng giữ dữ liệu thư viện này.

`EXCLUDED_KEYS` chứa `item:17`. Khi đọc file thư viện cũ, lọc riêng key này và giữ nguyên mọi khám phá khác; không đánh dấu cả file là hỏng. Database item 17 và công dụng thử nghiệm KUL vẫn giữ nguyên. Loại trừ theo đầy đủ loại/key nên không ảnh hưởng `weapon:17` hoặc `armor:17`.

## Tách khỏi Gallery

Giữ bảng ID/filename hiện có để event và `WCFGalleryScene.show(ID)` tiếp tục dùng được. Gallery điện thoại chỉ hiển thị `GALLERY_VISIBLE_IDS`: 41 ảnh cảnh, ending và album. CG2–CG5 cùng ID 42–81 không xuất hiện trong lưới hoặc bộ đếm Gallery, kể cả trước đây đã mở khóa. Không đánh số lại ID các CG còn lại; trang cuối chứa ID 85.

Ảnh vẫn ở `Graphics/Pictures`, ending ở `Graphics/Gallery`. Không di chuyển, nhân đôi hoặc sửa bitmap tài nguyên. `docs/gallery-assets.md` ghi dải ID chi tiết.

## Kiểm tra và phạm vi

Backup ban đầu: `Data/codex_backup_item_library_20261117/`; trước khi đổi sang ngang: `Data/codex_backup_library_landscape_20261117/`. Chỉ đổi slot 198 `Custom Menu`, giữ nguyên 222 slot/ID/tên/thứ tự và CSV; 78 file Data khác giữ nguyên. Không sửa tọa độ event, Database item, cơ chế farm RAM hoặc web app.

```text
ruby tools/test_item_library.rb
ruby tools/test_phone_menu_animation.rb
ruby -W0 tools/script_inventory.rb check
ruby -W0 tools/script_inventory.rb semantic
```

54 case / 2.055 assertion đạt (15 thư viện, 8 Settings, 31 Save/Load). Thử khám phá ảnh, gain/loss item, equipment khác loại, lưu/đọc lại, nhập Gallery cũ, phục hồi file hỏng, lỗi ghi và thử lại, không mở khóa khi chỉ xem mục khóa, phân trang, cleanup và không tiêu hao item. Kiểm tra thêm lọc đèn KUL từ file cũ/nhận mới, giữ khám phá khác, đủ mô tả cho 45 mục và tên hiển thị đã duyệt. Các ca xoay/lưới kiểm tra từng frame luôn nằm trong màn hình, khóa input, xoay về dọc trước return, 18 thumbnail được crop đúng vùng và điều hướng sáu cột. Bộ animation/layout trước đó đạt 32 case / 803 assertion, gồm quay về từ ứng dụng thư viện mới.

Native RGSS301 trong bản sao dưới `Save/PhoneSaveLoadQA_20261117_023759/` xác minh New Game thật và load save trước khám phá đều giữ bộ sưu tập; cả CG có khung, Picture trực tiếp và gain RAM đều mở đúng mục. Kiểm tra góc ngang khi mở/góc dọc trước return, xem chi tiết/ảnh gốc/icon RAM, dọn tài nguyên, quay lại menu và các chức năng Settings/Save/Load. Bản sao QA được mở khóa các ảnh vật phẩm để kiểm tra cả ba trang crop; dữ liệu người chơi thật không được mở khóa bởi bước này. Đã xem `14-library-grid.png`, `14b-library-page-two.png`, `14c-library-page-three.png`, `15-library-detail.png`; ảnh dựng từ bitmap RGSS, không phải điều khiển phím thật.

Lượt mô tả đã duyệt dùng `Save/PhoneSaveLoadQA_20261117_192552/`: 243 kiểm tra native đạt và kết thúc `COMPLETE`. Đã render cả 45 thẻ, đo wrap bằng font RGSS thật ở 170 px/font 17/tối đa 7 dòng (thực tế dài nhất 5 dòng), xác minh đèn KUL không vào thư viện kể cả khi nhận item, rồi quay lại điện thoại/Settings/Save/Load. Backup trước cập nhật: `Data/codex_backup_item_descriptions_20261117/`. Chỉ cập nhật slot 198 `Custom Menu`; giữ nguyên các slot khác, CSV, map và Database.

## Mô tả cách hiện thoại

Settings đổi tên mục thành **Cách hiện thoại**, giá trị **Cả câu** hoặc **Từng ký tự**. Mô tả thay theo trạng thái: **“Hiện cả câu ngay lập tức.”** hoặc **“Hiện dần từng ký tự.”**. ← chọn từng ký tự, → chọn cả câu, Z đổi chế độ; vẫn dùng tùy chọn `instantmsg` của Yanfly, không đổi cách chuyển khung thoại.

Cập nhật thẻ 20/11/2026: bốn TFCard làm tổng mặc định thành 49. Bộ test hiện đạt 56 case / 2.076 assertion; kiểm tra native đo đủ bốn mô tả bằng font thật và xem các ảnh `library-cards-card-*.png` trong `Save/TransformCardRewards/verified/captures`. [Chi tiết biến hình và các mốc mở](transform-review-2026-11-20.md).
