# Review route mì cay, hỏi Shylvie và hỏi Leo

Ngày cập nhật: 2026-09-10

Tài liệu này ghi lại cấu trúc đã được kiểm tra trong dữ liệu game. Tên map được viết kèm nội dung dễ nhận biết để tránh phải suy luận từ ID nội bộ.

## Route mì cay cho Leo

Luồng chính: Map10 (Trong xe buýt) → Map20 (Quán mì cay) → lựa chọn tin tưởng Aira đi qua Map19 (Siêu thị), hoặc tự mua mì mang về → Map37 (phân nhánh chuẩn bị mì cay trước đây ở Map47) → Map14 (Nhà bếp Văn phòng Wanderer) → Map38 (Văn phòng Wanderer Giáng sinh) → Map36 (Ending hint).

Map20, phân nhánh mì cay trên Map37 và cảnh nấu ăn ở Map14 dùng KUL cho chuyển sáng/tối. Camera lần lượt tập trung vào Hải Quỳ ở quán, cảnh chuẩn bị cạnh giường và khu vực nấu ăn. Cảnh ngủ chuyển qua `HQ_Room_Sleep`, ẩn sprite trong lúc nhân vật được vẽ trực tiếp trên parallax, rồi trở về phòng thường trước thoại thức dậy.

Map38 có phần chuẩn bị tiệc, CG6 hoặc CG7 tùy trạng thái Hải Quỳ, sau đó cho người chơi tự do khám phá văn phòng, vào các phòng riêng, nhà bếp, phòng họp và phòng chế tạo. Người chơi có thể mời Shylvie, Kohi, Leo hoặc Hakase chơi minigame ném tuyết. Chọn tiếp tục với Leo mới chạy cảnh trao mì cay, bình Sting 20 lít dạng placeholder, phần trao quà còn lại, cập nhật Gallery và ending hint.

## Route hỏi Leo

Luồng chính: Map13 (Văn phòng Wanderer) tương tác Leo lần thứ ba → Map56 (Trạm xe buýt và tin nhắn Leo) → một trong ba map cửa hàng → Map37 (phân nhánh chuẩn bị theo gợi ý Leo trước đây ở Map60) → Map38 (Văn phòng Wanderer Giáng sinh) → Map36 (Ending hint).

Ba lựa chọn được nối độc lập:

- Cửa hàng cà phê → Map58 (Cửa hàng cà phê Luminous) → quà cho Kohi.
- Cửa hàng vũ khí → Map59 (Cửa hàng vũ khí) → món khiên/đá cho Shylvie.
- Cửa tiệm dụng cụ ma pháp → Map57 (Cửa tiệm dụng cụ ma pháp) → áo choàng tàng hình cho Hakase.

Tin nhắn lựa chọn được lưu vào menu điện thoại sau khi giao diện đóng. Mỗi cửa hàng có camera mở cảnh riêng và trả camera về player trước khi chuyển map. Map57 tiếp tục dùng `$VapeEden` cho chủ tiệm. Các ảnh vật phẩm mở khóa Gallery tại cảnh xuất hiện. Phân nhánh gợi ý Leo trên Map37 dùng KUL, chờ tối hoàn toàn trước khi đổi sprite ngủ hoặc trang phục, rồi mới chuyển sang Map38.

Tại Map38, camera trở về follow player khi bắt đầu free roam. Cấu trúc khám phá phòng và minigame ném tuyết giống các route hoàn chỉnh khác. Chọn tiếp tục bữa tiệc chạy đúng nhánh món quà đã mua, đặt ending hint tương ứng rồi đi Map36.

## Route hỏi Shylvie

Luồng chính: Map13 (Văn phòng Wanderer) tương tác Shylvie lần thứ ba → Map64 (Tiệm đá phong thủy) → Map37 (phân nhánh chuẩn bị đá phong thủy trước đây ở Map65) → Map38 (Văn phòng Wanderer Giáng sinh, free roam) → Map66 (Trao quà đá phong thủy) → Map67 (Hậu truyện) → Map36 (Ending hint).

Tin nhắn riêng của Shylvie được hiển thị bằng giao diện điện thoại và lưu lại trong menu. Camera mở ở lối vào tiệm rồi pan lên các kệ đá trước khi hiện lựa chọn. Bốn lựa chọn và ảnh tương ứng là:

- Leo: Purple Garnet, Gallery 75.
- Kohi: Diamond Coffee, Gallery 56.
- Shylvie: Congo Tourmaline, Gallery 53.
- Hakase: Rainbow Fluorite, Gallery 76.

Phân nhánh đá phong thủy trên Map37 hiển thị Hải Quỳ trong phòng thay vì chỉ để màn hình kể chuyện. Sau cảnh gói quà, route đi vào Map38 để dùng đầy đủ phần chuẩn bị tiệc, CG6/CG7, cửa các phòng, free roam và ném tuyết. Camera tự trả về player khi bắt đầu tự do di chuyển. Chọn tiếp tục với Leo mới chuyển trong bóng tối tới Map66.

Map66 giữ nguyên map art hiện có, dùng lớp bàn tiệc đã hoàn thành, zoom nhẹ quanh bàn và chỉ dùng thoại thường trong lúc ảnh vật phẩm đang hiện. Toàn bộ bốn phân đoạn trao quà và các thoại chính từ compact B1845–B1917 đã được phục hồi. Hiệu ứng khi khiên Congo Tourmaline xuất hiện có rung camera để nhấn cảm xúc.

Map67 chứa đủ bốn hậu quả ngày hôm sau từ compact B1920–B1959: chuông gió Purple Garnet, ác mộng do kim cương thanh trừng Quỷ, chiếc khiên nhân bản hũ kem và các phép kỳ quặc của Rainbow Fluorite. Mỗi nhánh đặt đúng ending hint 25–28 trước khi sang Map36.

## Quy tắc kỹ thuật đã áp dụng

- Các controller/page thuộc ba route không còn lệnh Fade Screen hoặc Tint Screen legacy; chuyển tối/sáng dùng KUL. Những page route khác cùng nằm trên Map38 không bị ghi đè trong lần review này.
- `map_effects` chỉ được dùng cho zoom, không dùng để chỉnh ánh sáng hoặc tone.
- Camera cutscene luôn được reset về follow player trước free roam hoặc trước khi chuyển map.
- Ảnh đang hiện chỉ đi cùng thoại thường, không dùng popup message.
- Ảnh vật phẩm và CG gọi qua hệ thống Gallery khi có thể, nhờ đó vừa hiển thị vừa mở khóa mà không cần bản sao tài nguyên.
- Các thay đổi chỉ tác động controller/page của route; không thay tile, kích thước map, parallax hoặc event tương tác khác do người dùng chỉnh tay.
- Các cảnh chuẩn bị trước đây tách ở Map47, Map49, Map51, Map60 và Map65 dùng cùng tile table/parallax nên đã được gom thành các page điều kiện của Map37. Biến 83 (`HQ_PREP_SCENE_VARIANT`) chọn đúng phiên bản trước khi transfer; các map cũ không còn đường transfer runtime đi vào và được xếp dưới group `ARCHIVED — Map chuẩn bị cũ` (Map68) trong cây Map của RPG Maker.

Lệnh dựng/vá đã dùng trong quá trình phát triển (không chạy lại sau khi chỉnh map bằng tay):

```text
ruby tools/rvdata2_audit.rb polish-wanderer-routes
ruby tools/rvdata2_audit.rb finalize-wanderer-route-review
```
