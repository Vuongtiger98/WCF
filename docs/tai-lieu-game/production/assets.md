# Asset checklist

## Menu điện thoại và Group Chat

Các file được script tham chiếu trong `Graphics/PhoneMenu/` gồm nền điện thoại, icon item/save/load/settings/contacts/gallery, avatar contact, `Contact_WandererGroup`, `Cursor`, `Button`, `MessageBackground` và các ảnh hội thoại. Cần kiểm tra tồn tại thực tế trước khi đóng gói.

## Gallery

- `Graphics/Gallery/0`: thumbnail khóa.
- Gallery đọc ảnh từ cả `Graphics/Gallery` và `Graphics/Pictures`; không copy cùng một bitmap sang hai thư mục. Bảng ID và trạng thái gắn scene nằm tại `../../gallery-assets.md`.
- `Graphics/Gallery` dành cho thumbnail khóa, UI và ending art vốn chỉ dùng trong Gallery/Title. CG và hình vật phẩm dùng trực tiếp bản duy nhất trong `Graphics/Pictures`.
- Giữ dải mã 90 slot để tương thích event; Gallery chỉ hiển thị 41 ảnh cảnh/ending/album. ID 2–5 và 42–81 chuyển sang Thư viện vật phẩm. ID 82–85 là `Album_1`–`Album_4`; ID 86–90 còn dự phòng. Bảng `../../gallery-assets.md` là registry có thẩm quyền khi phạm vi ID thay đổi.
- `Save/GlobalGallery.rvdata2` là dữ liệu unlock toàn cục, không phải asset.

## Các hệ thống đồ họa

- `Graphics/Layers/`: layer cho Galv Layer Graphics, bao gồm `Bathroom_top` ở Map015.
- `Graphics/Lights/`: tài nguyên KUL Graphics. Bộ mê cung Atlantis gồm `maze_amber_clear` 288×288, `maze_amber_clear_wide` 384×384, `maze_cyan_clear` 320×320, `maze_cyan_clear_wide` 384×384 và `maze_violet_clear` 320×320; giữ nền RGB đen đục vì KUL nén alpha khi cache light.
- `Graphics/Fog/` hoặc thư mục fog cấu hình: KUL/Victor fog.
- `Graphics/Parallaxes/`: animated/parallax lock.
- `Graphics/Weather/`: MOG Weather EX.
- `Graphics/System/`: weather, message và effect system.
- `Graphics/Invaders/`: backdrop, alien0–4, alien4S, lazor/elazor, orbit bullet, powerup và player của BulletHell.
- `Graphics/Catto/`, `Graphics/Pictures/`, `Graphics/Characters/`, `Graphics/Faces/`: asset gameplay, CG, sprite và portrait còn lại.
- Bộ rơi Map024 không còn nằm trong `Graphics/Pictures`. `falling_base` là parallax của map; `falling_path`, tám frame `falling_HQ_ded_1`–`ded_8` và bảy frame `falling_HQ_faint_1`–`faint_7` nằm trong `Graphics/Layers`. Tất cả dùng chung gốc 544×544 và không được crop/căn lại từng file. Runtime tạm ẩn parallax trong shot sprite Hải Quỳ xoay, phục hồi `falling_base` trước chuỗi layer, rồi chỉ hiện `falling_path` sau khi kết thúc animation và hiện lại player tại `(8,6)`.

## Face còn thiếu sau lượt gắn portrait route

- Bà chủ `NPC-SHOP-OWNER` trên Map023: 50 Show Text bubble `\bm[2]` chưa gắn face vì không có sheet khớp nhân vật tóc xám đã bake trong `Old_Book_Shop_Base`.
- Quái vật Vực Sâu trên Map025: 21 bubble `\bm[2]` chủ ý chưa gắn face; cần quyết định dùng portrait quái vật hay giữ giọng nói vô diện.
- NPC/cashier trên Map019: 79 Show Text thuộc các event ID ngoài player chưa có mapping face đáng tin cậy. Không dùng `Traveller_Emote`, `Face1` hoặc `30` để lấp chỗ trống khi chưa xác nhận danh tính.
- Các nhân vật có asset xác định trong route Atlantis và Máy pha cà phê đã được gắn face; Pop Message hiển thị qua `Window_MessageFace` vì `default_face = false`.

## Nhà Hải Quỳ — cảnh ăn mì

- `Graphics/Parallaxes/HaiQuy_Parent_House_Ramen_Glitch.png`: nền 704×1376 cho E048 khi Switch 40 đang OFF.
- `Graphics/Parallaxes/HaiQuy_Parent_House_Ramen_NoGlitch.png`: nền 704×1376 cho E048 sau khi E016 bật Switch 40.
- Cả hai ảnh đúng kích thước Map022 `22×43` tile và đã vẽ sẵn Hải Quỳ/Paulie; không chồng thêm charset hiển thị lên ảnh.

## Atlantis clone/chase

- `$Clone1`–`$Clone11`: vòng vây Map034.
- `$Clone1`–`$Clone11`: vừa là vòng vây Map034 vừa được dùng làm đủ 11 chướng ngại QTE riêng trên Map029.
- `$Clone12`–`$Clone17`: đã nhập và vẫn khả dụng cho các cảnh clone bổ sung, nhưng không còn là pool QTE chính của Map029.
- `$Clone7.png`: bản PNG một frame chuyển từ `$Clone7.gif` để tương thích RGSS3.
- `$OniOnii_landing`: Paulie nhảy xuống trong Map025; sau landing đổi sang `$OniOnii`.
- `Monster1.png`: atlas chase 4×7, dùng 6 frame đầu.
- `Monster.png`: atlas trúng phép khống chế 4×7, dùng 26 frame.
- Hai atlas Monster được cắt bằng script overlay, không dùng trực tiếp trong ô Graphic của event.

## Atlantis — ending chủ tiệm sách

- `$Cage_1`, `$Cage_2`, `$Cage_3`: ba sheet liên tiếp của kết giới nguyên vẹn, nứt vỡ và tan rã trên Map053/055. Runtime giữ lâu các frame nứt đầu rồi tăng tốc phần vỡ.
- `Monster.png`: tái sử dụng overlay `AtlantisMonsterDisplay` ở chế độ `:bound`; event map chỉ là anchor mang tên `ABYSS-MONSTER`.
- Chưa có CG đúng chỉ dẫn `[CG Hải Quỳ mỉm cười]`; Map055 để dòng placeholder rõ cho artist thay sau, không unlock nhầm CG khác.
- Chưa có sprite/face Drosalya; Map036 hint 21/24 dùng pop giọng ngoài khung hình, không có đuôi và không gán face nhân vật khác. Các câu Bully Quỳ vẫn dùng face của Bully Quỳ. Xem [đồng bộ hint 19/11](../scripts/ending-hints-2026-11-19.md).
- Chưa có parallax tiệm sách đổ nát/đấu trường riêng; Map053/055 tạm dùng nền Atlantis tối đã có.

## Route hỏi Leo

- `$VapeEden`: chủ tiệm ma pháp trên Map057. Sheet 126×220; dùng ba frame hàng đầu, mỗi frame giữ 60 tick rồi lặp.
- `!$Falling`: sheet 126×220, lưới single-character 3×4 với ô 42×55. Hai frame đầu của hàng 1/2/3 lần lượt là Hải Quỳ/Shylvie/Leo rơi tự do; cột thứ ba và hàng thứ tư trong suốt. Map050 lặp đúng hai frame/người bằng forced Move Route và dùng thuộc tính `angle` của MOG Character Effect để dao động độc lập trong khoảng ±8°.
- Thiếu face Eden, chủ tiệm cà phê, chủ tiệm vũ khí và sprite/face Drosalya. Runtime hiện placeholder text tại đúng vị trí; không mượn face nhân vật khác.
- `Magic_Store_Base/Top`, `Isekai_Caffe_Base/Top` và `Cuahangvukhi_bas3/Cuahangvukhi_top` là ba cặp nền/layer chính thức. `Crafting_Room_Base` không thuộc route này.

## Phòng dùng chung Wanderer Office

- `Meeting_Room_Base` — 1152×800, Map061 phòng họp thường.
- `Meeting Room_MovieNight_base` — 1152×800, Map062 phòng họp trong các bản office Giáng sinh.
- `Crafting_Room_Base` — 1088×768, Map063 phòng chế tạo; interaction lấy từ compact B2540–B2584.

Tên được script gọi chưa chứng minh file tồn tại. Trước mỗi route cần checklist sprite/face/emote/CG/BG/BGM/SFX/voice; chỉ kiểm tra tree/tên file, không cần đọc bitmap. Phân bổ BGM hiện hành nằm tại `../systems/audio-map.md`; scene chưa có nhạc phải fade out thay vì kế thừa BGM map trước.

## Placeholder route siêu thị

- `$Gift_Coffee.png`, `$Gift_Cookware.png`, `$Gift_Knitting.png`, `$Gift_Lockpick.png`: bản đổi màu từ `$Presents.png`, giữ đúng kích thước/alpha để thay graphic production trực tiếp về sau.
- `ED_MKT_{COFFEE|COOKWARE|KNITTING|LOCK}_{LEO|KOHI|SHYLVIE|HAKASE}.png`: 16 placeholder được đổi màu từ `EDRuotDuoi.png` và đăng ký Gallery ID 10–25.
- Vertical slice hiện dùng `$Gift_Coffee.png` và `ED_MKT_COFFEE_KOHI.png` (Gallery ID 11). Không xem placeholder là artwork cuối.
- Quy tắc placeholder mới: khi cần biến thể tạm, chỉ copy tài nguyên nguồn và đổi tên file; không cần đổi màu vì artwork sẽ được thay sau.
- Route Máy pha cà phê dùng bốn placeholder ending `ED_MKT_COFFEE_LEO/KOHI/SHYLVIE/HAKASE.png`, Gallery ID 10–13.

## Route mì cay — placeholder demo

- Chưa có ảnh bình Sting 20 lít. Map038 E118 hiện một dòng cảnh báo màu trong đúng nhịp Show Picture: `[ẢNH BÌNH STING 20 LÍT]` để artist xác định vị trí thay asset. Map048 chỉ giữ bản donor/rollback.
- Chưa có sprite sheet nấu ăn riêng. Map014 E025 dùng sprite Giáng sinh hiện có cùng animation Cast Magic/Fire làm bản demo, rồi hiện `Mibullyquy` hoặc `Mihaiquy`.
- Bộ layer Map038 đã có đủ: `Wanderer_Party_prepare`; `snowbuild_1..2`; `snowkitchen_1..5`; `snowmeet1..5`; `phuchoi` + `phuchoi_1..6`. Tất cả là PNG trong suốt 1440×1344 căn theo tọa độ Map038, không cắt như charset. Bếp Giáng sinh dùng parallax 1440×1344 `Map_Wanderer_Office_Kitchen__Chrismast_base`.

