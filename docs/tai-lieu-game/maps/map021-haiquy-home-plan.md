# Kế hoạch Map021 — Nhà và kho của Hải Quỳ

> **Tài liệu lịch sử.** Map022/026/041 và tuyến Atlantis đã được triển khai. Giữ file này để truy nguồn quyết định ban đầu; không dùng các transfer tạm hoặc ghi chú “Map022 chưa dựng” làm runtime spec.

## 1. Vai trò trong route Atlantis

Map021 không còn chỉ là route gate. Đây là cảnh chuyển tiếp sau khi Hải Quỳ chọn “Xuống Atlantis” trên xe bus, trước khi tới tiệm sách phép.

```text
Map010 — Xe bus
→ Map021 — Nhà/kho Hải Quỳ
→ đọc thư và nghỉ ngơi
→ cảnh chuyển tiếp/ký ức
→ Map022 — Tiệm sách phép Atlantis
```

Map019 Siêu thị vẫn là map test, không tham gia luồng này.

## 2. Mục tiêu scene

- Cho Hải Quỳ về nhà nghỉ sau khi quyết định mua sách phép.
- Tạo không gian cho PoV Hải Quỳ và các tương tác hồi ức gia đình.
- Giới thiệu Paulie/OniOnii, Dahria và Aira qua vật thể/nhật ký, không giải thích toàn bộ lore quá sớm.
- Cho người chơi đọc thư/tin dẫn tới cảnh Atlantis.
- Ghi trạng thái route để các map sau không chạy lại scene mở đầu.

## 3. Luồng đề xuất

### 3.1. Vào map

- Map010 chuyển tới Map021 tại điểm vào nhà.
- Autorun chỉ chạy khi `ATL_CHOSEN = ON` và `ATL_READ_LETTER = OFF`.
- Camera dùng Common Event 1/3; không gọi trực tiếp các chuỗi camera rải trong event.
- Tạo layer nhà/kho nếu map dùng overlay; sau scene phải dọn layer trước transfer.

### 3.2. Scene nghỉ ngơi

1. Hải Quỳ bước vào nhà.
2. PoV nhận xét đã lâu không về nhà và cần sửa Brilliant Anchor.
3. Hải Quỳ đi về khu vực bếp/kho; có movement route ngắn, `wait=true`.
4. Tương tác với kho hoặc bàn sửa chữa.
5. Có thoại/hành động của Paulie/OniOnii nếu dùng scene tương ứng trong tài liệu.

### 3.3. Tương tác tùy chọn

Các điểm tương tác lấy từ `Tương tác nhà Hải Quỳ.docx` và `Tương tác phòng kho.docx`:

- Ảnh gia đình và ảnh Hải Quỳ thời nhỏ.
- Ảnh thành phố Atlantis.
- Tủ thuốc, máy giặt, tủ đồ và vật dụng gia đình.
- Nhật ký trong kho.
- TV/băng cassette về Paulie, Aira và ký ức gia đình.
- Khu vực sửa chữa Brilliant Anchor.

Các tương tác lore phải là action button, không đặt trong Autorun chính.

### 3.4. Đọc thư và rời map

- Một event riêng cho thư/tin dẫn vào Atlantis.
- Sau khi đọc, bật `ATL_READ_LETTER`.
- Tăng `ATL_STEP` từ 1 lên 2.
- Hiện thoại chuyển tiếp: Hải Quỳ nghỉ ngơi/sửa mỏ neo rồi đi tới tiệm sách.
- Transfer sang Map022 tại vị trí đã chốt sau khi map Atlantis được tạo.
- Nếu người chơi quay lại map sau khi đã đọc thư, không chạy lại Autorun; vẫn cho phép khám phá.

## 4. Flag và variable

| ID | Tên | Map021 sử dụng |
|---:|---|---|
| Switch 30 | `ATL_CHOSEN` | Điều kiện vào route |
| Switch 34 | `ATL_READ_LETTER` | Đã đọc thư/tin dẫn route |
| Variable 30 | `ATL_STEP` | 1 = vào nhà, 2 = đã đọc thư |
| Variable 31 | `ATL_BOOK_ID` | Chưa dùng tại Map021 |

Không dùng lại Variable 2/3/4/20/40. Không dùng Switch 8 của Map013.

## 5. Camera và hiệu ứng

- Vào map: Common Event 1 — focus player.
- Đối thoại/vật thể quan trọng: Common Event 2 chỉ dùng nếu cần focus event, truyền event ID qua Variable 40.
- Kết thúc scene: Common Event 3 — reset camera/effects trước transfer.
- Không dùng movement route `wait=false` cho player trong scene chuyển map.
- Không dùng fade-out riêng nếu transfer đã dùng fade mặc định, tránh màn hình đen.

## 6. Tài nguyên cần kiểm tra

- Tileset/background nhà và kho.
- Sprite Hải Quỳ ở nhà (`HaiQuyAtHome_Base` hoặc tên runtime tương ứng).
- Sprite/biểu cảm Paulie/OniOnii nếu xuất hiện trực tiếp.
- Ảnh nhật ký, cassette, ảnh gia đình, ảnh Atlantis.
- SFX mở tủ, đóng cửa, sửa chữa, băng cassette và tiếng báo tin nhắn.

## 7. Phạm vi triển khai lần đầu

Bản đầu chỉ cần hoàn thành:

1. Map021 có bố cục nhà/kho và điểm vào.
2. Autorun vào nhà, nghỉ ngơi và sửa Brilliant Anchor.
3. Một event thư/tin dẫn route.
4. Ghi `ATL_READ_LETTER` và `ATL_STEP = 2`.
5. Transfer tạm tới điểm chờ Map022 hoặc giữ player ở map nếu Map022 chưa dựng.
6. Ba đến năm interaction lore quan trọng; các interaction còn lại để phase sau.

## 8. Điều kiện duyệt trước khi sửa map

- Chốt Map021 là một map nhà+kho hay tách nhà và kho thành hai map.
- Chốt thư/tin nào là trigger chính.
- Chốt có cho Paulie/OniOnii xuất hiện trực tiếp hay chỉ qua hồi ức/đồ vật.
- Chốt vị trí tạm của Map022 để tránh sửa transfer nhiều lần.

