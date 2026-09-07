# Gallery assets và điểm unlock

## Quy tắc lưu file

- CG và hình vật phẩm chỉ lưu một bản trong `Graphics/Pictures`.
- Ending art tiếp tục nằm trong `Graphics/Gallery` vì Title/Ending Presentation đang dùng trực tiếp thư mục này.
- `Cache.gallery(ID)` tự tra `PhoneMenu::GALLERY_PICTURE_FILES` và chọn đúng nguồn. Không tạo thêm bản đánh số `1.png`, `2.png`, ... trong `Graphics/Gallery`.
- `WCFGalleryScene.show(ID)` vừa hiện Picture ở giữa màn hình vừa gọi `GlobalGallery.unlock(ID)`; `WCFGalleryScene.hide` xóa Picture.

## Dải ID

| ID | Nội dung | Nguồn |
|---:|---|---|
| 1–8 | CG1–CG8 | `Graphics/Pictures` |
| 9 | Ending rượt đuổi | `Graphics/Gallery/EDRuotDuoi` |
| 10–25 | 16 ending siêu thị, bốn quà × bốn người nhận | `Graphics/Gallery/ED_MKT_*` |
| 26–41 | CG9–CG24 | `Graphics/Pictures` |
| 42–81 | 40 hình vật phẩm theo bảng trong `Custom Menu` | `Graphics/Pictures` |
| 82–85 | Album nhà kho `Album_1`–`Album_4` | `Graphics/Pictures` |
| 86–90 | Dự phòng | — |

## CG đã gắn vào scene

- CG1: Map006, Hải Quỳ rời Silver Wing; giữ nguyên thời lượng Show Picture cũ và bổ sung unlock.
- CG2–CG5: Map037, lần lượt tại kẹp dơi, khiên, chìa khóa và hạt cà phê.
- CG6/CG7: Map038, nhánh Hải Quỳ/Bully Quỳ bị vùi trong tuyết; giữ Show Picture cũ và unlock đúng nhánh.
- CG8/CG9: Map038, Hakase quấn khăn rồi đóng băng khăn.
- CG11–CG14: Map037, thức dậy và ba nhịp chọn trang phục Giáng sinh.
- CG15–CG18: Map038, Shylvie nhận khiên, cảnh quàng khăn, Leo/Muramasa và Kohi với các thanh gỗ.
- CG20/CG21: Map039, hai biểu cảm của Kohi trong cảnh cà phê.
- CG19: Map038 E118 route mì cay, Hải Quỳ và Shylvie hoảng hốt khi nhận ra Mặt Nạ Đá từng bị phong ấn.
- CG22: Map038, Hakase ôm Leo trong các nhánh phù hợp.
- CG23/CG24: Map038, chọn theo Switch 51 trong cảnh ăn: Hải Quỳ hoặc Bully Quỳ.
- CG23/CG24 cũng xuất hiện tuần tự trong Map038 E118 route mì cay khi Hải Quỳ ăn bánh rồi đưa phần còn lại cho Bully Quỳ.
- CG10 chưa gắn: mô tả hiện chưa đủ để xác định duy nhất một câu/event. Không tự đoán scene.

## Vật phẩm đã gắn vào scene hiện có

- Map019: `Combodaochao`, `Bomoclen`, `Dungcuphakhoa` khi kiểm tra món tại siêu thị.
- Map038: áo khoác Leo tặng Hakase, bao tay Hakase tặng Shylvie, bút vàng, đèn Hakase, kệ gỗ chưa lắp, bốn khăn theo `MKT_TARGET`, khiên rỉ, kiếm cách, Kirby, máy ép cam, Gundam/`Nhua`, ốp lưng và túi đeo.
- Map039: bao tay Kohi tặng Hakase, cà phê Luminous và Tails doll.
- Map040: cà phê thường khi chọn quay về; cà phê Atlantis khi câu đủ mười tôm vàng.
- Map014/038 route mì cay: `Mibullyquy` hoặc `Mihaiquy`; Map038 E118 còn mở `Nhua`, `Matnada`, `Bomoclen` và `Banhkemcam` đúng vòng tặng quà.

Các file còn lại đã được đăng ký trong Gallery nhưng giữ trạng thái khóa cho tới khi có scene thực sự chứa vật phẩm. Việc một tên xuất hiện trong kịch bản compact không đủ để tự chèn vào map chưa được dựng.

## Quy tắc message khi hiện ảnh

- Trong thời gian Picture/CG/vật phẩm đang hiện, message phải bắt đầu bằng `\cbm` để buộc dùng cửa sổ thoại thường và xóa trạng thái Pop Message kế thừa.
- Các cảnh cố ý che toàn bộ map/event bằng nền đen cũng chỉ dùng message thường. Map038 và Map040 được chuẩn hóa toàn cảnh theo quy tắc này.
- Ngoài khoảng hiện ảnh, Pop Message vẫn được giữ nếu còn nhân vật/event trên map làm điểm neo.
- `integrate-picture-gallery-assets` tự áp dụng quy tắc này sau khi dựng lại các lệnh hiện ảnh.

## Công cụ

Chạy lại sau khi regenerate route:

```powershell
ruby tools/rvdata2_audit.rb integrate-picture-gallery-assets
```

Công cụ xóa các lệnh có marker `WCF_GALLERY_SCENE` rồi dựng lại, nên chạy nhiều lần không nhân đôi event command.
