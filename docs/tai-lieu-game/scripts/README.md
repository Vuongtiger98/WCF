# Script trong Wonder Christmas Fiesta

Kiểm kê ban đầu ngày 30/10/2026, cập nhật runtime và hiệu năng ngày 15/11/2026 từ `Data/Scripts.rvdata2` và bản đọc trong `Scripts/`. Runtime là nguồn quyết định script nào được nạp và thứ tự thực thi. Tác giả được xác định từ header, sau đó mới đối chiếu trang của tác giả; thiếu bằng chứng thì ghi chưa rõ.

| Tài liệu | Dùng để làm gì |
|---|---|
| [catalogue.md](catalogue.md) | Công dụng, tác giả, dependency và tình trạng của từng script bổ sung |
| [runtime-inventory.md](runtime-inventory.md) | Toàn bộ 222 slot, đường dẫn export và hash để đối chiếu phiên bản |
| [authors-and-sources.md](authors-and-sources.md) | Nguồn gốc, credit, điều khoản ghi trong header và nguồn đã kiểm tra |
| [usage-and-dependencies.md](usage-and-dependencies.md) | Cách gọi hệ thống đang có, thứ tự phụ thuộc và các vùng ID cần giữ |
| [compatibility-audit.md](compatibility-audit.md) | Lỗi đã xác nhận/đã sửa, chỗ có thể xung đột và giới hạn kiểm tra |
| [performance-audit-2026-11-15.md](performance-audit-2026-11-15.md) | Tối ưu chung, số thao tác trước/sau, công cụ đo và các đoạn cần playtest trên laptop |
| [phone-ui-review-2026-11-15.md](phone-ui-review-2026-11-15.md) | Bố cục điện thoại, danh bạ/chat/Gallery và kết quả kiểm tra trong engine |
| [rgss3-writing-guide.md](rgss3-writing-guide.md) | Quy tắc viết script phù hợp Ruby/RGSS3 và kiến trúc dự án |
| [feature-proposals.md](feature-proposals.md) | Đề xuất chức năng mới, lợi ích và cách tích hợp |

Thư mục này bổ sung cho [05-technical-scripts.md](../05-technical-scripts.md). Registry state nằm trong [flags-and-variables.md](../systems/flags-and-variables.md); các lỗi từng gặp nằm trong [rgss3-runtime-pitfalls.md](../production/rgss3-runtime-pitfalls.md).

## Cách đọc tình trạng script

- **Có mã**: slot chứa token Ruby có thể thực thi. Không có nghĩa tính năng đang được một event gọi tới.
- **Tắt**: thân script đã nằm trong comment block; không tính vào chuỗi override runtime.
- **Công cụ**: có trong danh sách nhưng mode hiện tại không thực hiện import/export.
- **Project/custom**: có code phục vụ WCF; không mặc nhiên suy ra tác giả hoặc giấy phép nếu header thiếu.

Theo snapshot hiện tại có 189 slot có nội dung: 182 slot có mã và 7 slot chỉ chứa comment/tài liệu. Phần còn lại là separator/rỗng. Bảy slot không chạy code gồm `( Insert here )`, `Theo Anti Lag`, `Map Effects User Guide`, `Disable key`, `KUL Graphics Menu Add-on`, `Galv's Region Effects`, `Galv's Cam Slide Control`.

`HP Bar Over Player` chỉ còn lệnh đăng ký cờ `$imported`; thân chức năng đã comment. Vì vậy slot được bộ đếm token xếp “Có mã”, nhưng không có thanh HP hay hook cập nhật từ thân script đó đang chạy.

`Scripts/!script_order.csv` đã được khớp với thứ tự runtime, gồm 221 dòng sau slot 0. `Scripts/load_order.txt` là danh sách chữ cái cũ, không được importer KK20 hoặc game dùng để quyết định thứ tự. Tuyệt đối không sort Script Editor theo danh sách này.

## Cập nhật lần sau

```text
ruby -W0 tools/script_inventory.rb
ruby -W0 tools/script_inventory.rb semantic
ruby -W0 tools/script_inventory.rb overrides
ruby tools/test_script_graphics_lifecycle.rb
ruby tools/test_performance_optimizations.rb
ruby tools/test_rgss_performance_probe.rb
ruby tools/test_phone_menu_layout.rb
ruby tools/test_phone_menu_animation.rb
ruby tools/test_phone_save_load.rb
ruby -W0 tools/script_inventory.rb check-performance-scope
ruby -W0 tools/script_inventory.rb check-native-performance-scope
ruby -W0 tools/script_inventory.rb check-phone-ui-scope
ruby -W0 tools/script_inventory.rb check-phone-open-scope
ruby -W0 tools/script_inventory.rb check-phone-save-scope
ruby -W0 tools/script_inventory.rb check-phone-landscape-scope
ruby -W0 tools/script_inventory.rb check-phone-labels-scope
ruby -W0 tools/script_inventory.rb check-phone-transition-scope
ruby -W0 tools/script_inventory.rb check-phone-shortcuts-scope
```

`markdown` xuất nội dung inventory ra stdout; `order` xuất thứ tự đề xuất ra stdout. Công cụ chỉ đọc, không tự ghi đè map, script runtime hoặc file export. Review nội dung trước khi áp dụng. `-W0` tránh trộn warning regex của script legacy vào dữ liệu xuất ra.

Khi thay script runtime, chỉ thay source nén của đúng slot đã xác định theo tên. Giữ nguyên số slot, ID, tên và thứ tự; tạo backup trước khi sửa và kiểm tra các slot ngoài phạm vi không thay đổi.

Save/Load theo theme điện thoại và cách kiểm tra: [phone-save-load-2026-11-16.md](phone-save-load-2026-11-16.md).
