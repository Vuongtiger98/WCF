# 04 — Route Map

## 1. Mô hình route

Route được xác định bởi tổ hợp:

```text
Hướng chuẩn bị → món quà/cửa hàng → người nhận → vòng trao quà → epilogue
```

Không phải route nhân vật theo kiểu tình cảm. Người nhận là biến số làm thay đổi chuỗi sự kiện trong route món quà.

## 2. Điểm phân nhánh cấp 1

| ID tạm | Hướng | Nguồn chính |
|---|---|---|
| PATH-MARKET | Siêu thị Mega Galaxy Central | Các file `Route`/`Kịch bản` theo bốn món |
| PATH-NOODLE | Mua mì cay cho Leo | `Mua Mi Cay Cho Leo.docx` |
| PATH-OFFICE | Ghé Wanderer Office hỏi gợi ý | `NhantinLeo.docx`, `NhantinShylvie.docx` |
| PATH-ATLANTIS | Xuống Atlantis mua sách phép | `Xuống Atlantis Mua Sách Phép.docx` |

## 3. Route siêu thị

### 3.1. Cấu trúc

```text
Siêu thị
├─ Bộ phá khóa ─┬─ Leo
│               ├─ Kohi
│               ├─ Shylvie
│               └─ Hakase
├─ Dao và chảo ─┬─ Leo
│               ├─ Kohi
│               ├─ Shylvie
│               └─ Hakase
├─ Khăn len ────┬─ Leo
│               ├─ Kohi
│               ├─ Shylvie
│               └─ Hakase
└─ Máy pha cà phê
                ├─ Leo
                ├─ Kohi
                ├─ Shylvie
                └─ Hakase
```

Tổng: **16 tổ hợp**.

### 3.2. ID route tạm

| Món quà | Leo | Kohi | Shylvie | Hakase |
|---|---|---|---|---|
| Bộ phá khóa | MKT-LOCK-LEO | MKT-LOCK-KOHI | MKT-LOCK-SHY | MKT-LOCK-HAK |
| Dao và chảo | MKT-COOK-LEO | MKT-COOK-KOHI | MKT-COOK-SHY | MKT-COOK-HAK |
| Khăn len | MKT-SCARF-LEO | MKT-SCARF-KOHI | MKT-SCARF-SHY | MKT-SCARF-HAK |
| Máy pha cà phê | MKT-COFFEE-LEO | MKT-COFFEE-KOHI | MKT-COFFEE-SHY | MKT-COFFEE-HAK |

### 3.3. Logic chung

1. Player tới siêu thị.
2. Bốn món được giới thiệu qua tương tác quầy hàng.
3. Player mua một món.
4. Player chọn người nhận trong nhóm chat.
5. Hội thoại Hải Quỳ–Aira thay đổi theo độ phù hợp của món.
6. Hải Quỳ chuẩn bị/gói quà tại nhà.
7. Route hội tụ ở tiệc.
8. Scene trao quà, quà nhận lại và epilogue dùng biến thể tương ứng.

### 3.4. Hậu quả mẫu đã xác định

- Bộ phá khóa tặng Leo: Leo dùng nó mở cửa cứu Hải Quỳ bị kẹt.
- Bộ phá khóa tặng Shylvie: Shylvie nâng cấp thành dụng cụ phá phép và gây rắc rối với nhóm đầu ổ khóa.
- Bộ phá khóa tặng Kohi: Hải Quỳ/Aira phải sửa sai bằng máy pha cà phê trong epilogue.
- Bộ phá khóa tặng Hakase: Hakase luyện phá khóa và bị cảnh sát hiểu nhầm là trộm.

Các món khác cũng có epilogue riêng theo người nhận; chi tiết sẽ được chuẩn hóa trong file route riêng, không chép toàn bộ vào bản đồ tổng.

## 4. Route mì cay

### 4.1. Cấu trúc

```text
Mua mì cay cho Leo
├─ Tin Aira
│  └─ Aira chọn nguyên liệu và nấu nồi mì cay “dữ tợn”
└─ Không tin Aira
   └─ Hải Quỳ ăn nhiều tô, phân tích công thức và tự nấu
```

| ID tạm | Người nhận | Điểm khác biệt |
|---|---|---|
| NOODLE-AIRA-LEO | Leo | Aira phụ trách công thức/nấu |
| NOODLE-HQ-LEO | Leo | Hải Quỳ phân tích và tự nấu |

Hai nhánh hội tụ ở tiệc, nồi mì cay, Sting 20 lít và gag đá bào mì cay. Tài liệu hiện kết thúc ở cảnh Hải Quỳ rời đi làm nhiệm vụ.

## 5. Route hỏi Leo

### 5.1. Điều kiện

Hải Quỳ ghé Wanderer Office và chọn nói chuyện với Leo. Leo không nhận ra ngay hình dạng mới của Hải Quỳ. Sau ba lần tương tác, Leo gửi danh sách cửa hàng.

### 5.2. Nhánh

| ID tạm | Cửa hàng | Quà | Người nhận |
|---|---|---|---|
| OFFICE-LEO-MAGIC | Dụng cụ ma pháp | Áo choàng luyện tàng hình | Hakase |
| OFFICE-LEO-CAFE | Cửa hàng cà phê | Cà phê đặc biệt | Kohi |
| OFFICE-LEO-WEAPON | Cửa hàng vũ khí | Khiên | Shylvie |

Chọn cửa hàng đồng thời xác định người nhận; không có menu bốn người độc lập như route siêu thị.

## 6. Route hỏi Shylvie

### 6.1. Điều kiện

Hải Quỳ ghé Wanderer Office và nói chuyện với Shylvie. Shylvie nhận ra cô qua tóc, mắt và ma lực, sau đó gửi tọa độ tiệm đá phong thủy.

### 6.2. Nhánh

| ID tạm | Người nhận | Quà | Chức năng |
|---|---|---|---|
| OFFICE-SHY-LEO | Leo | Purple Garnet | Giải bất lợi/độc tố, hỗ trợ tinh thần |
| OFFICE-SHY-KOHI | Kohi | Kim cương hình hạt cà phê | Quà thẩm mỹ hợp chủ đề |
| OFFICE-SHY-SHY | Shylvie | Congo Tourmaline | Triệu hồi khiên phép |
| OFFICE-SHY-HAK | Hakase | Rainbow Fluorite | Chứa phép ngẫu nhiên |

## 7. Route Atlantis

### 7.1. Route quà tặng tiêu chuẩn

| ID tạm | Sách | Người nhận | Epilogue |
|---|---|---|---|
| ATL-ANCIENT-HAK | Ma Vương Cổ Đại | Hakase | Hakase mở hình dạng mới; đặt câu hỏi về nguồn gốc Hải Quỳ |
| ATL-TELEPORT-SHY | Phép thuật dịch chuyển nâng cao | Shylvie | Shylvie phân tích phép hoán đổi/dịch chuyển |

### 7.2. Ending đặc biệt

| ID tạm | Điều kiện | Kết quả |
|---|---|---|
| ATL-ABYSS-END | Nói chuyện với chủ tiệm trước khi tìm sách | Tạo vật Vực Sâu phát nổ; Wanderer giải cứu Hải Quỳ/Aira |

Ending này bỏ qua tuyến tiệc tiêu chuẩn sau khi Hải Quỳ mất liên lạc.

## 8. Điểm hội tụ

### Hội tụ A — chuẩn bị tại nhà

Phần lớn route có một cảnh Hải Quỳ:

- Gói hoặc hoàn thiện quà.
- Lo lắng về phản ứng người nhận.
- Tranh luận với Aira.
- Ngủ quên hoặc ngủ tới sát Giáng sinh.

### Hội tụ B — Wanderer Office

- Hải Quỳ đến văn phòng.
- Sierra tạo tuyết.
- Nhóm chuẩn bị tiệc.
- Ăn uống và board game.

### Hội tụ C — vòng quà

Scene trao quà không được coi là hoàn toàn chung. Người nhận đầu tiên làm thay đổi:

- Người tiếp theo trong vòng.
- Vật phẩm từng người trao.
- Người tặng quà lại Hải Quỳ.
- Phản ứng và gag.

### Hội tụ D — Silver Wing

Cuộc gọi về Lỗ Hổng Vực Sâu 61 xuất hiện trong phần lớn route. Sau đó Hải Quỳ rời tiệc và route đi tới epilogue.

## 9. Biến phụ

Các trạng thái sau thay đổi hội thoại hoặc event nhỏ, không tính thành route quà tặng độc lập:

| Flag tạm | Ảnh hưởng |
|---|---|
| READ_MOMO_MESSAGE | Thay đổi đối thoại Hải Quỳ–Aira khi mua máy pha cà phê |
| HEARD_IOTA_VOICE | Thay đổi trò chuyện với Beta M-34 |
| TALKED_LEO_FIRST | Thay đổi cách Shylvie phản ứng về việc nhận ra Hải Quỳ |
| ATL_TALK_OWNER_FIRST | Kích hoạt ending Atlantis đặc biệt |
| OBJECT_INTERACTION_N | Chuyển lần thoại của vật thể/NPC |
| MET_CAMEO_X | Có thể thay đổi câu chào hoặc nhận diện |

Tên flag chỉ là đề xuất tài liệu, chưa phải tên switch trong project.

## 9A. Cấu trúc route Atlantis cập nhật

```text
Map010 xe bus
→ nhà Hải Quỳ
├─ pha mì/nghỉ ngơi → tiệm sách
│  ├─ tìm sách trước → Hakase/Shylvie → tiệc
│  └─ gặp chủ tiệm trước → tạo vật Vực Sâu nổ → ending giải cứu
└─ mở phòng kho và đọc thư → ký ức → gương → chase
   → Hải Quỳ khẳng định tên Dahria → Oni Onii hỗ trợ → màn hình đen
```

Không gộp nhánh chọn sách, nhánh chủ tiệm và nhánh đọc thư thành một đường bắt buộc. Các trạng thái cần theo dõi độc lập: đã chọn Atlantis, đã đọc thư, đã vào tiệm sách, sách đã chọn, chase đã kích hoạt và ending đã đạt.

## 10. Tổng số kết quả và đường test

| Nhóm | Số đường đi |
|---|---:|
| Siêu thị | 16 |
| Mì cay | 2 |
| Hỏi Leo | 3 |
| Hỏi Shylvie | 4 |
| Sách Atlantis | 2 |
| Tổng route quà tặng | **27** |
| Ending Atlantis đặc biệt | **1** |
| Tổng đường đi lớn có kết quả riêng | **28** |

Con số 28 ở đây đếm kết quả nội dung lớn. Phạm vi QA là **33 đường test** vì:

- 16 tổ hợp siêu thị được tách thành 20 lượt test khi bốn route máy pha cà phê có thêm biến thể cà phê thường/cà phê Atlantis.
- Route phòng kho → ký ức → mê cung → chase → Paulie được theo dõi như một đường test riêng.

Không dùng 28 và 33 thay thế nhau nếu không ghi rõ đang đếm ending nội dung hay case QA.

## 11. Trạng thái triển khai

Toàn bộ nhóm route trong bảng đã có runtime flow. Thứ tự “chọn route sản xuất đầu tiên” không còn là quyết định mở. Khi sửa tiếp, ưu tiên bug playtest và asset placeholder thay vì mở rộng route.

Các nguồn sau từng có 13 tiêu đề scene và được giữ làm thông tin lịch sử:

- Bộ phá khóa.
- Dao và chảo.
- Xuống Atlantis mua sách phép.
- Nhắn tin/hỏi Shylvie.

Chúng đồng hạng về số scene trong tài liệu nguồn; số scene không còn dùng để quyết định route nào đã/ chưa được triển khai.

## 12. Ghi chú lỗi copy–paste

Các lỗi dưới đây được hiệu chỉnh theo logic xuyên suốt của nội dung, nhưng vẫn giữ note để kiểm tra:

| Nguồn | Nhãn sai/nghi sai | Cách hiểu hợp lý |
|---|---|---|
| `Route Bophakhoa.docx` | Ghi chọn khăn len | Nội dung mua và hậu quả đều là bộ phá khóa |
| `Route DaovaChao.docx` | Ghi chọn khăn len | Nội dung route là dao và chảo |
| `Route Khanlen.docx` | Ghi chọn máy pha cà phê | Nội dung chuẩn bị và trao khăn len |
| `Route Mayphacaphe.docx` | Ghi đi Wanderer trước cảnh siêu thị | Diễn biến thực tế đi siêu thị mua máy pha cà phê |
| Một số file route | Tiêu đề chung “mua đồ móc len” | Dùng tên món quà thể hiện xuyên suốt nội dung |

Quy tắc xử lý:

1. Sửa nhãn copy–paste cho khớp hành động, vật phẩm và epilogue.
2. Không xóa dấu vết; ghi nguồn và thay đổi trong bảng này/source map.
3. Nếu nội dung hành động cũng mâu thuẫn và không xác định được route, dừng và hỏi.
