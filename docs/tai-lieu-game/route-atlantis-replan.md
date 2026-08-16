# Kế hoạch tổng thể sau khi đọc lại toàn bộ `kich ban`

## 1. Phạm vi đã kiểm kê

Đã đọc toàn bộ 30 file DOCX trong thư mục `kich ban`, gồm:

- Các bản tin nhắn: bản hiện hành, v1, v2.
- Bốn route quà: máy pha cà phê, khăn len, dao/chảo, bộ phá khóa.
- Nhắn tin Leo và Shylvie.
- Mì cay cho Leo.
- Route Atlantis và `AFTER ENDING HINT`.
- Các file tương tác Silver Wing, Wanderer, nhà/kho Hải Quỳ, phòng từng nhân vật, xưởng chế tạo, Magic Shop và quán cà phê.

Quy tắc ưu tiên vẫn giữ nguyên: file cùng độ ưu tiên nếu mâu thuẫn thì ghi chú và hỏi, không tự đoán.

## 2. Kết luận thiết kế quan trọng

### 2.1. Route Atlantis không phải một map đơn

DOCX không mô tả route Atlantis như một chuỗi tuyến tính duy nhất. Sau khi về nhà, nội dung tách thành các hướng sau:

```text
Xe bus → điểm xuống Atlantis → nhà Hải Quỳ
├─ pha mì/nghỉ ngơi → tiệm sách
│  ├─ tìm sách trước → chọn sách cho Hakase hoặc Shylvie → tiệc tiêu chuẩn
│  └─ nói chuyện chủ tiệm trước → hộp thiếc/tạo vật Vực Sâu phát nổ → ending giải cứu riêng
└─ tìm chìa khóa → phòng kho → đọc thư
   → ký ức bãi rác/gương → chase → đối đầu Vực Sâu cùng Oni Onii
   → kết thúc nhánh ở màn hình đen; điểm nối sau đó chưa được DOCX xác định tuyến tính
```

### 2.2. Map tương tác phải dùng tọa độ trong DOCX

Ký hiệu `(015, 010)` được hiểu chính xác là `x=15, y=10`. Không đặt placeholder ở đầu map nếu file đã cung cấp tọa độ.

Các event nhiều ô phải tạo theo toàn bộ vùng ghi trong tài liệu, ví dụ `(016,010),(017,010)`, hoặc dùng một event chung nếu không cần phân biệt ô.

### 2.3. Phân biệt thoại

- Suy nghĩ Hải Quỳ: `Show Text` bình thường.
- Hải Quỳ nói trong hội thoại Pop Message: `\bm[0]`.
- NPC nói: `\bm[event_id]`, với `event_id` là event đang đại diện cho NPC.
- Không tự gán Pop Message ID nhân vật toàn cục nếu kịch bản/map chưa có event đại diện tương ứng.

## 3. Bản đồ và thứ tự triển khai

### Giai đoạn A — Nhà/kho Hải Quỳ

Map022 dùng ảnh đã xác định:

- `HQ_House_Base`: Parallax.
- `HQ_House_Top`: Galv Layer Graphics.
- Kích thước: `22×43`.

Event phải lấy tọa độ từ:

- `Tương tác nhà Hải Quỳ.docx`.
- `TƯƠNG TÁC PHÒNG HẢI QUỲ Ở NHÀ.docx`.
- `Tương tác phòng kho.docx`.

Scene chính:

1. Vào nhà và suy nghĩ Hải Quỳ.
2. Được tự do khám phá.
3. Tương tác Brilliant Anchor.
4. Đọc thư/tin cảnh báo.
5. Bật `ATL_READ_LETTER`, tăng `ATL_STEP`.
6. Đọc thư lập tức chuyển sang ký ức/chase theo chỉ dẫn viết hoa trong nguồn; không chuyển sang tiệm sách.

Các tương tác ký ức quan trọng cần ưu tiên: ảnh gia đình, ảnh Atlantis, nhật ký, cassette/TV, tủ váy đỏ, ảnh thời nhỏ và khu vực sửa chữa.

### Giai đoạn B — Tiệm sách phép Atlantis

Map023 cần có:

- Khu vực tiệm sách và event tương tác khám phá.
- Chủ tiệm hoặc event đại diện chủ tiệm nếu kịch bản yêu cầu thoại Pop Message.
- Lựa chọn sách:
  - `ATL_BOOK_ID = 1`: Ma Vương Cổ Đại → Hakase.
  - `ATL_BOOK_ID = 2`: Phép Dịch Chuyển → Shylvie.
- Bật `ATL_OWNER_MET` sau scene/chủ tiệm.
- Dùng thoại suy nghĩ cho phần đọc sách và `\bm[event_id]` cho người khác nói.

### Giai đoạn C — nhánh thư/ký ức và Chase

Map024 cần được tách thành:

- Scene phát hiện Quái Vật Vực Sâu.
- Khu vực chase có collision rõ ràng.
- Clone/chướng ngại vật.
- Vùng game over khi chạm nguy hiểm.
- Điểm đích và cảnh sét đánh dọn đường theo kịch bản.

Flag:

- `ATL_CHASE_STARTED` khi chase bắt đầu.
- `ATL_CHASE_CLEARED` khi tới đích hợp lệ.

### Giai đoạn D — đối đầu sau Chase

Map025 là cảnh đối đầu cuối nhánh chase:

- Hải Quỳ tự gọi tên Dahria.
- Nghi ngờ Dahria không phải tên thật.
- Quái vật phủ nhận tên và thân phận của Hải Quỳ.
- Hải Quỳ chủ động khẳng định `Dahria…chính là ta!`; nguồn không có Aira đối thoại trong cảnh này.
- Oni Onii dùng `ECLIPSE BLOCKCHAIN`, Hải Quỳ kết liễu bằng `ANEMONE DIAMOND SHOWER`.
- Không giải thích toàn bộ nguồn gốc Poseidon.
- Bật `ATL_END_READY`, sau đó dừng ở màn hình đen vì điểm nối tiếp theo chưa rõ trong bố cục nhiều cột của DOCX.

## 4. Tương tác các map khác

Các file tương tác không chỉ dành cho Map022. Cần lập event theo tọa độ khi review từng map:

- Silver Wing: `Thoại_Tương tác_FIXED.docx`.
- Wanderer: phòng Leo, Shylvie, Kohi, Hakase và phòng ngủ Hải Quỳ.
- Xưởng chế tạo: thiết bị Nethervoid, buồng hồi phục, cổng dịch chuyển, robot.
- Magic Shop và quán cà phê: các scene phụ/điều kiện chuyển cảnh.
- Nhà/kho Hải Quỳ: lore và ký ức, ưu tiên trước route Atlantis.

Các file `FIXED` được xem là bản nội dung đã chỉnh trong cùng nhóm; nếu bản thường và bản FIXED khác nhau ở nội dung hành động, phải ghi conflict thay vì tự hợp nhất.

## 5. Tin nhắn và foreshadowing

Bản tin nhắn hiện hành bổ sung:

- Ánh Lam biết Hải Quỳ giả danh Omega D-13.
- Hải Bình đã chết trước khi Hải Quỳ gia nhập Binh Đoàn Sứa Lam.
- Hoàng Hà gửi ảnh cũ làm nổi bật sự giống nhau giữa Hải Quỳ và Hải Bình.
- OniiOnii cảnh báo Quái Vật Vực Sâu ngụy trang ở Atlantis.
- A2 phát lệnh về quái vật cấp nguy hiểm cao và hàng rào quanh Atlantis.

Các tin nhắn này nên được đặt trước hoặc trong route Atlantis, nhưng không tự động biến thành route flag nếu chưa có event trigger cụ thể.

## 6. Flag/variable chính

| ID | Tên | Vai trò |
|---:|---|---|
| Switch 30 | `ATL_CHOSEN` | Chọn route Atlantis |
| Switch 31 | `ATL_ARRIVED` | Đã tới Atlantis |
| Switch 32 | `ATL_OWNER_MET` | Đã gặp chủ tiệm |
| Switch 33 | `ATL_END_READY` | Reveal hoàn tất trước hội tụ |
| Switch 34 | `ATL_READ_LETTER` | Đã đọc thư/tin dẫn route |
| Switch 35 | `ATL_CHASE_STARTED` | Chase bắt đầu |
| Switch 36 | `ATL_CHASE_CLEARED` | Chase hoàn tất |
| Variable 30 | `ATL_STEP` | Tiến độ route |
| Variable 31 | `ATL_BOOK_ID` | Sách đã chọn |

Không dùng lại Variable 2/3/4/20/40 cho route Atlantis.

## 7. Camera và script

- `Galv's Layer Graphics`: `layer`, `refresh_layers`, `del_layer`.
- Pop Message: dùng `\bm[event_id]` đúng event đại diện người nói.
- Camera:
  - CE1 focus player.
  - CE2 focus event qua Variable 40.
  - CE3 reset trước transfer.
- Movement route của player trong scene phải `wait=true`.
- Không thêm Fadeout riêng trước transfer nếu destination dùng fade mặc định.

## 8. Các vấn đề cần người dùng can thiệp hoặc duyệt

1. Chọn sprite/event ID đại diện cho Paulie và chủ tiệm Atlantis.
2. Xác nhận Map022 là nhà+kho chung hay cần tách thành hai map.
3. Cung cấp/chốt tileset collision cho parallax nhà.
4. Chốt layout collision của Map023 và Map024.
5. Cung cấp tài nguyên clone/quái vật/chase nếu muốn chase giống kịch bản.
6. Xác nhận bản tin nhắn hiện hành là bản ưu tiên cao hơn v1/v2.
7. Xác nhận điểm nối sau màn hình đen của nhánh chase; không tự chèn Aira vào cảnh Map025.

## 9. Trạng thái triển khai hiện tại

- Map021: điểm xuống Atlantis, giữ nguyên vai trò route gate.
- Map022: prototype parallax nhà, event hiện cần thay bằng toàn bộ tọa độ DOCX.
- Map023 đã có nội dung tiệm sách; Map024/029/025 hiện tạo thành nhánh thư–ký ức–chase riêng. Map025 đã thay prototype bằng thoại Cảnh số 5 đúng nguồn, vẫn dùng visual placeholder.
- Tài liệu thiết kế đã cập nhật theo nội dung mới; binary map tiếp theo chỉ nên sửa sau khi duyệt kế hoạch này.
