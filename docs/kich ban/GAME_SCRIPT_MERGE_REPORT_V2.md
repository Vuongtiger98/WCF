# Merge report — V2

## Kết quả tổng

- Tổng input đã xử lý: **31 DOCX** (20 file trước + 11 file mới).
- Sau nhận diện file trùng/gần-trùng: **24 logical documents**.
- Lô mới giữ lại **1,383 text blocks / 91,903 ký tự** sau khi bỏ đúng các phần đã yêu cầu.
- Toàn corpus sau loại trừ: **11,826 text blocks** nếu giữ từng source riêng.
- Sau gộp các file gần-trùng ở mức logical document: **7,957 text blocks**.
- AI compact hiện dùng **3,797 block văn bản duy nhất**.
- Trong lô mới, **410/1,383 block** tái sử dụng block đã có; chỉ cần thêm **973 block mới**.
- Kích thước `GAME_SCRIPT_AI_COMPACT_V2.md`: **321,207 ký tự**.
- Kiểm tra coverage lô mới: **0 retained block bị thất lạc**.

## Nhận diện trùng ở lô mới

Không có cặp file mới nào là bản sao/gần-bản-sao đủ để merge thành một file duy nhất.

`Xuống Atlantis Mua Sách Phép(1).docx` dùng lại một phần lớn đoạn mở đầu của các route Wonder Christmas Fiesta hiện có, nhưng sau đó rẽ sang nhánh xuống Atlantis nên được giữ thành **một route riêng**. Trong bản AI compact, mọi block giống hệt đã được tham chiếu lại thay vì lưu thêm lần nữa.

`Tương tác nhà Hải Quỳ.docx` và `TƯƠNG TÁC PHÒNG HẢI QUỲ Ở NHÀ.docx` cùng thuộc khu vực nhà Hải Quỳ nhưng là **hai phạm vi tương tác khác nhau** (nhà chung và phòng riêng), nên không gộp mất nội dung.

`TƯƠNG TÁC TIỆM SÁCH CŨ.docx` có liên kết/nội dung bổ trợ cho route xuống Atlantis nhưng là tài liệu tương tác map riêng, nên vẫn giữ thành logical document độc lập. Block nào trùng chữ hoàn toàn vẫn được dedup trong registry.

## 11 logical documents mới

- **Route Xuống Atlantis Mua Sách Phép** → `Xuống Atlantis Mua Sách Phép(1).docx` — 805 retained blocks; 394 reused / 411 new.
- **Tương tác phòng ngủ Hải Quỳ — Wanderer Office** → `TƯƠNG TÁC MAP PHÒNG NGỦ HẢI QUỲ Ở VĂN PHÒNG WANDERER.docx` — 26 retained blocks; 3 reused / 23 new.
- **Tương tác nhà Hải Quỳ** → `Tương tác nhà Hải Quỳ.docx` — 76 retained blocks; 4 reused / 72 new.
- **Tương tác phòng Hải Quỳ ở nhà** → `TƯƠNG TÁC PHÒNG HẢI QUỲ Ở NHÀ.docx` — 46 retained blocks; 0 reused / 46 new.
- **Tương tác phòng Hakase** → `Tương tác phòng Hakase.docx` — 25 retained blocks; 0 reused / 25 new.
- **Tương tác phòng kho** → `Tương tác phòng kho.docx` — 96 retained blocks; 3 reused / 93 new.
- **Tương tác phòng Leo** → `TƯƠNG TÁC PHÒNG LEO.docx` — 22 retained blocks; 0 reused / 22 new.
- **Tương tác phòng ngủ Kohi** → `Tương tác phòng ngủ Kohi.docx` — 19 retained blocks; 0 reused / 19 new.
- **Tương tác phòng ngủ Shylvie** → `Tương tác phòng ngủ Shylvie.docx` — 22 retained blocks; 0 reused / 22 new.
- **Tương tác quán cà phê** → `Tương tác quán cà phê.docx` — 110 retained blocks; 0 reused / 110 new.
- **Tương tác tiệm sách cũ** → `TƯƠNG TÁC TIỆM SÁCH CŨ.docx` — 136 retained blocks; 6 reused / 130 new.

## Các nhóm merge từ lô trước

- **Route Bophakhoa**: `Route Bophakhoa(1).docx` + `Kịch bản Wonder Christmas Fiesta_Bophakhoa(1).docx`
- **Route Dao & Chao**: `Kịch bản Wonder Christmas Fiesta_DaovaChao(1).docx` + `Route DaovaChao(1).docx`
- **Route Khăn Len**: `Kịch bản Wonder Christmas Fiesta_Khanlen(1).docx` + `Route Khanlen(1).docx`
- **Route Máy Pha Cà Phê**: `Kịch bản Wonder Christmas Fiesta_Mayphacaphe(1).docx` + `Route Mayphacaphe(1).docx`
- **Tin nhắn**: `Kịch bản Wonder Christmas Fiesta_Tinnhanv2(1).docx` + `Kịch bản Wonder Christmas Fiesta_Tinnhan(1).docx` + `Kịch bản Wonder Christmas Fiesta_Tinnhanv1(1).docx`
- **Thoại tương tác Silver Wing**: `Thoại_Tương tác (4)(1).docx` + `Thoại_Tương tác_FIXED(1).docx`

## Nội dung chủ động bỏ

- Chart/image/sprite image.
- Phần `Chú thích / Tài nguyên / bảng resource / bảng hướng dẫn` ở đầu các DOCX có cấu trúc này.
- Dòng điều hướng Word `Ctrl + Click` và trạng thái `Không có`/`Chưa có` trong bảng.
- Với bảng lựa chọn nằm trong thân kịch bản, **tên lựa chọn vẫn được giữ** dưới dạng `[CHOICES] ...`.
- Khoảng trắng/line-break chỉ do Word tự xuống dòng được gom lại; không sửa văn phong, không sửa lỗi chính tả, không tự bổ sung câu chữ.

## Kiểm tra coverage

- Audit cũ của 20 source vẫn được giữ nguyên.
- 11 source mới đã được thêm vào `audit/SOURCE_COVERAGE.json`.
- Mỗi retained source block đều map tới đúng một `B####` trong compact registry.
- Tái dựng sequence từ registry cho từng source mới khớp **100% theo block** với nội dung sau các loại trừ chủ động.

## Cách dùng

- **Tối ưu token cho AI:** `compact/GAME_SCRIPT_AI_COMPACT.md`.
- **Đọc thủ công:** `GAME_SCRIPT_MERGED_READABLE.md`.
- **Chỉ đọc route:** `readable/01_ROUTES.md`.
- **Chỉ đọc tương tác map/phòng/quán/tiệm:** `readable/03_MAP_INTERACTIONS.md`.
- **Audit:** `audit/SOURCE_COVERAGE.json`.
# Quy tắc bắt buộc khi dùng bản AI Compact

`GAME_SCRIPT_AI_COMPACT_V2.md` không phải là kịch bản tuyến tính có thể đọc từ
đầu đến cuối. Khi dùng file này phải thực hiện đúng thứ tự sau:

1. Tìm route trong `DOCUMENT SEQUENCES`.
2. Đọc chuỗi `MAIN:` của route đó.
3. Mở rộng từng tham chiếu `B####`; với `B####..B####` phải chèn toàn bộ block
   trong khoảng theo đúng thứ tự.
4. Tra nội dung block trong `BLOCK REGISTRY`.
5. Đọc `VARIANTS` và ghi nhận xung đột; không tự chọn nếu hai nguồn ngang mức
   ưu tiên, trừ lỗi copy-paste đã được duyệt cho phép sửa theo logic.

Không được đọc `BLOCK REGISTRY` tuần tự theo số block. Registry là kho văn bản
đã khử trùng lặp, nên cách đọc đó sẽ làm mất ngữ cảnh, trộn route và đặt sai các
nhánh điều kiện. DOCX chỉ cần mở lại khi compact khai báo đã chủ động bỏ loại dữ
liệu cần dùng hoặc khi có xung đột chưa thể giải quyết từ `MAIN`/`VARIANTS`.
