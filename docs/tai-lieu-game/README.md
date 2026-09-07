# Wonder Christmas Fiesta — Tài liệu dự án

## Mục đích

Thư mục này là bộ tài liệu sản xuất thống nhất cho **Wonder Christmas Fiesta**. Nội dung được tái cấu trúc từ các tài liệu kịch bản trong thư mục `kich ban`, nhằm giúp đội ngũ viết kịch bản, dựng event, lập trình, thiết kế map và chuẩn bị tài nguyên cùng làm việc trên một nguồn thông tin chung.

Bộ tài liệu mới không thay thế hoặc chỉnh sửa tài liệu nguồn. Những file cũ tiếp tục được giữ làm tư liệu đối chiếu cho đến khi toàn bộ nội dung được xác nhận.

## Trạng thái hiện tại

> **Giai đoạn: Bản nháp để duyệt cấu trúc và cách diễn giải**

Bộ tài liệu hiện gồm các tài liệu tổng quan đánh số `00`–`05` và các nhóm chuyên môn `routes/`, `maps/`, `systems/`, `production/`, `archive/`. Đây là vị trí chuẩn duy nhất cho các nhóm này; không tạo bản song song trực tiếp dưới `docs/`.

Các thông tin chưa thể xác định chắc chắn từ tài liệu nguồn được đánh dấu bằng một trong các nhãn sau:

- **Cần xác nhận:** cần tác giả hoặc người phụ trách dự án quyết định.
- **Mâu thuẫn nguồn:** các tài liệu cũ đưa ra thông tin khác nhau.
- **Đề xuất:** phương án tổ chức hoặc triển khai mới, chưa phải canon.
- **Tạm hiểu:** cách diễn giải dùng để tiếp tục thiết kế trong khi chờ xác nhận.

## Nguyên tắc biên soạn

1. Giữ nguyên ý đồ, tính cách nhân vật và chất hài của kịch bản gốc.
2. Tất cả file nguồn có độ ưu tiên ngang nhau. Khi hai hoặc nhiều nguồn xung đột, phải ghi nhận xung đột và hỏi người phụ trách dự án; không được tự suy đoán hoặc tự chọn một phiên bản làm canon.
3. Tách nội dung cốt truyện khỏi chỉ dẫn kỹ thuật và danh sách tài nguyên.
4. Chỉ viết một lần đối với cảnh dùng chung; route sẽ tham chiếu lại thay vì sao chép.
5. Mỗi lựa chọn phải xác định được điều kiện, kết quả, điểm hội tụ và hậu quả.
6. Thuật ngữ, tên riêng và mã nhân vật phải được dùng nhất quán.
7. Lore bắt buộc, thoại hài, cameo và Easter egg phải được phân loại riêng.
8. Nội dung phải đủ rõ để chuyển thành event trong RPG Maker VX Ace.
9. Tên chính của nhân vật trung tâm là **Hải Quỳ**. Do năng lực biến hình, tên, danh tính hoặc hình dạng được sử dụng có thể thay đổi theo ngữ cảnh; tài liệu mới phải giữ nguyên cách gọi phù hợp với từng cảnh và không tự ý đổi tên.

## Quyết định canon đã duyệt

### DOC-001 — Độ ưu tiên của nguồn

- Trạng thái: **Đã duyệt**.
- Mọi file nguồn có độ ưu tiên bằng nhau, không phụ thuộc tên file, hậu tố `FIXED`, số phiên bản hoặc ngày chỉnh sửa.
- Khi nội dung tương thích, có thể tổng hợp nhưng phải giữ được ý nghĩa của tất cả nguồn.
- Khi nội dung xung đột về canon và không có căn cứ hợp lý để phân biệt, phải đưa vấn đề vào danh sách cần xác nhận và hỏi người phụ trách dự án trước khi viết thành canon.
- Lỗi copy–paste hiển nhiên có thể được chỉnh theo logic xuyên suốt của route, nhưng phải ghi chú nguồn và nội dung đã hiệu chỉnh để người phụ trách kiểm tra lại.
- Không được dùng ngày sửa file hoặc tên phiên bản làm căn cứ duy nhất để giải quyết xung đột.

### CHAR-001 — Tên nhân vật trung tâm

- Trạng thái: **Đã duyệt**.
- Tên chính của nhân vật là **Hải Quỳ**.
- Hải Quỳ có năng lực biến hình, vì vậy cách gọi nhân vật có thể thay đổi tùy ngữ cảnh, hình dạng, thân phận hoặc tổ chức.
- Không tự ý đổi `Dahria`, `Dahlia`, `Omega D-13`, `Aira` hoặc một cách gọi khác thành `Hải Quỳ` nếu nguồn đang cố ý dùng tên đó trong cảnh.
- Nếu không thể xác định một cách gọi là biến thể có chủ ý hay lỗi không nhất quán, phải hỏi thay vì tự sửa.

### NAR-001 — Góc nhìn kể chuyện

- Trạng thái: **Đã duyệt**.
- Câu chuyện được kể từ góc nhìn của Hải Quỳ.
- Phần dẫn truyện tập trung vào suy nghĩ, cảm nhận và cách Hải Quỳ nhìn nhận mọi thứ xung quanh.
- Không tự ý chuyển sang người kể toàn tri hoặc trình bày suy nghĩ riêng của nhân vật khác nếu Hải Quỳ không thể biết được.

### TERM-001 — Thuật ngữ đã chốt

- Trạng thái: **Đã duyệt**.
- Tên tổ chức: `Silver Wing`.
- Tên chiều không gian/hành tinh: `Luminous`.
- Tên vũ khí của Leo: `Muramasa`.

### SCOPE-001 — Route triển khai đầu tiên

- Trạng thái: **Đã duyệt nguyên tắc**.
- Chọn route có nhiều scene nhất để chuẩn hóa và triển khai tài liệu trước.
- Mọi route vẫn có độ ưu tiên canon ngang nhau; việc chọn route làm trước chỉ là quyết định về thứ tự sản xuất.
- Số scene phải được xác định từ nội dung thực tế, không dựa riêng vào tên file, số dòng hoặc ngày chỉnh sửa.
- Nếu nhiều route có cùng số scene hoặc cách đánh số scene mâu thuẫn, phải hỏi trước khi lựa chọn.

### RELEASE-001 — Hình thức phát hành

- Trạng thái: **Đã duyệt**.
- Dự án là fangame phát hành phi thương mại.
- Trong phạm vi biên soạn tài liệu, không cần loại bỏ hoặc thay thế tài nguyên chỉ vì chúng tham chiếu IP bên ngoài.

## Đối tượng sử dụng

| Vai trò | Thông tin cần từ bộ tài liệu |
|---|---|
| Biên kịch | Canon, timeline, route, giọng thoại và quan hệ nhân vật |
| Event designer | Cảnh, điều kiện, switch, variable, item và điểm dịch chuyển |
| Map designer | Danh sách map, tọa độ tương tác, NPC và trạng thái map |
| Artist | Sprite, portrait, biểu cảm, CG, background và hiệu ứng |
| Audio | BGM, ambience, SFX, voice và thời điểm phát |
| Kiểm thử | Ma trận lựa chọn, điều kiện mở khóa, điểm hội tụ và ending |

## Mục lục dự kiến

Tên và cách chia file dưới đây là cấu trúc đang được sử dụng.

| Tài liệu | Nội dung | Trạng thái |
|---|---|---|
| `README.md` | Mục lục, quy ước, trạng thái tài liệu | Bản nháp |
| `00-tong-quan-game.md` | Tầm nhìn, premise, gameplay loop, phạm vi | Bản nháp |
| `01-world-bible.md` | Thế giới, tổ chức, đa chiều, ma pháp, thuật ngữ | Bản nháp |
| `02-nhan-vat.md` | Hồ sơ, quan hệ và giọng thoại nhân vật | Bản nháp |
| `03-timeline-cot-truyen.md` | Trình tự sự kiện và các cảnh dùng chung | Bản nháp |
| `04-route-map.md` | Cây lựa chọn, nhánh, hội tụ và ending | Bản nháp |
| `route-diagrams.md` | Mã Mermaid của sơ đồ route | Bản nháp |
| `routes/` | Kịch bản chi tiết theo món quà/route | Bản đối chiếu kỹ thuật ban đầu |
| `maps/` | Nội dung và tương tác theo từng map | Bản kiểm kê map hiện có |
| `systems/flags-and-variables.md` | Switch, variable, region, terrain tag và điều kiện event | Bản registry tạm |
| `production/assets.md` | Sprite, CG, BG, BGM, SFX, voice và trạng thái | Checklist ban đầu |
| `production/open-issues.md` | Mâu thuẫn và câu hỏi cần quyết định | Đang mở |
| `production/tester-web-app-content-spec.md` | Đặc tả nội dung web app theo dõi playtest dành cho người chơi | Đang sử dụng |
| `archive/source-map.md` | Ánh xạ từ tài liệu cũ sang tài liệu mới | Bản ánh xạ ban đầu |

## Mô hình nội dung

Tài liệu mới tổ chức game theo ba tầng:

1. **Cốt truyện chung:** mở đầu tại Silver Wing, đọc tin nhắn, hình thành kế hoạch tặng quà, tiệc Giáng sinh và biến cố Vực Sâu.
2. **Nội dung phân nhánh:** địa điểm đi mua sắm, món quà, người nhận, chuỗi trao quà và epilogue tương ứng.
3. **Nội dung khám phá:** tương tác map, NPC, tin nhắn, cameo, Easter egg và lore phụ.

Cách tổ chức này tránh việc sao chép toàn bộ cốt truyện chung vào từng route như trong tài liệu nguồn.

## Quy ước cho kịch bản sau này

Mỗi cảnh chi tiết dự kiến dùng mẫu sau:

```markdown
## SCN-XXX — Tên cảnh

- Map: MAP_XXX
- Điều kiện vào: ...
- Nhân vật: ...
- BGM/Ambience: ...
- Switch/Variable đọc: ...
- Switch/Variable ghi: ...
- Cảnh tiếp theo: ...

### Diễn biến

Mô tả hành động và nhịp cảnh.

### Hội thoại

**Tên nhân vật — biểu cảm:** Lời thoại.

### Lựa chọn

1. Lựa chọn A → kết quả hoặc cảnh đích.
2. Lựa chọn B → kết quả hoặc cảnh đích.

### Tài nguyên

- Sprite: ...
- CG: ...
- SFX: ...
```

Mã định danh chính thức sẽ chỉ được đặt sau khi cây route và danh sách map được duyệt.

## Các quyết định cần duyệt sớm

1. Route triển khai đầu tiên đã chốt là ending Atlantis.
2. Kiểm kê tuần tự các map playable, bắt đầu từ Map003 Văn phòng Silver Wing; map generic/test được bỏ qua.
3. Xác định map Atlantis và hoàn thiện logic route trước khi dựng event route.

## Nguồn tài liệu

Nguồn chính hiện nằm trong thư mục `../kich ban`, bao gồm:

- Các file `Kịch bản Wonder Christmas Fiesta_*.docx`.
- Các file `Route *.docx`.
- Các nhánh bổ sung về mì cay, Atlantis và tin nhắn.
- Các tài liệu thoại tương tác theo map.
- Các phiên bản tin nhắn mở đầu game.
- Gói tài nguyên voice và hình ảnh Giáng sinh.

Danh sách ánh xạ chi tiết giữa từng file nguồn và nội dung canon sẽ được lập trong `archive/source-map.md` ở giai đoạn sau.
# Cập nhật thiết kế chờ duyệt

Các DOCX ngày 27–30/07/2026 đã mở rộng route Atlantis và lore gia đình. Bản thiết kế hiện đã ghi nhận thay đổi, nhưng Map021 chưa redesign và chưa dựng các map Atlantis tiếp theo. Cần duyệt cấu trúc mới trước khi chỉnh binary map.
