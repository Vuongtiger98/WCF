# Giữ vị trí khi góp ý thoại — 19/11/2026

Tester gửi đề xuất rồi quay lại danh sách bị đưa lên đầu, phải tìm lại đoạn đang test. App dùng hash routing, dựng lại danh sách từ đầu và chưa nhớ bộ lọc hoặc vị trí cuộn. Khôi phục cuộn mặc định của trình duyệt cũng có thể chạy trước khi danh sách mới được dựng xong.

## Bản sửa

- Giữ vị trí cuộn và ba trường tìm kiếm/nhóm/trạng thái theo trang trong bộ nhớ của lượt mở app.
- Chụp trạng thái trước khi nhấp liên kết; khôi phục bộ lọc trước khi dựng danh sách và đặt lại vị trí sau khi DOM được dựng. Áp dụng cho Back/Forward của trình duyệt và liên kết quay lại danh sách.
- Không sửa các file dữ liệu thoại/checklist/frames, ID khung, STORAGE_KEY, cách chuẩn hóa hoặc schema kết quả. Tiến độ OK, vị trí khung, báo lỗi, đề xuất và định dạng xuất báo cáo giữ nguyên.
- Không ghi trạng thái cuộn vào localStorage của tester. Reload app vẫn giữ kết quả test như trước; vị trí cuộn/bộ lọc chỉ nhớ trong lượt mở hiện tại.

## Kiểm tra

`node tools/test_qa_navigation.js` dùng Chrome/Edge headless với profile QA mới bên trong Save; không mở profile trình duyệt của người dùng. Công cụ dùng CDP pipe, không cần npm package. Có thể truyền `--browser` khi trình duyệt nằm ở đường dẫn khác.

Trước sửa (`Save/QANavigationQA-ZyIckG/results.json`): Back và breadcrumb đều đưa cuộn từ 12.847 px về 32 px; từ khóa và bộ lọc trạng thái bị xóa. Sau sửa (`Save/QANavigationQA-zlIxW0/results.json`): đều trở lại 12.847 px với bộ lọc cũ.

12 kiểm tra đạt: vị trí sau lưu đề xuất; Back và bộ lọc; Tiếp tục khung; báo lỗi/hủy; breadcrumb và bộ lọc; giữ dữ liệu OK/vị trí cũ; giữ báo lỗi/đề xuất cũ; lưu đề xuất mới đúng item/khung; dữ liệu còn nguyên sau reload; không có lỗi script. Đây là kiểm tra trình duyệt thật với dữ liệu QA giả lập, không truy cập dữ liệu của tester.

## Cài bản vá, giữ tiến độ

Gói `dist/wcf-qa-scroll-fix-2026-11-19.zip` chỉ chứa `app/app.js` và `README.txt`. Giải nén chép đè vào folder app đang dùng, tại nơi có index.html, rồi tải lại trang trong cùng trình duyệt. Giữ nguyên tên/vị trí index.html, không xóa dữ liệu trình duyệt. Chuyển sang đường dẫn khác có thể khiến trình duyệt dùng vùng lưu khác; nếu phải chuyển, xuất báo cáo ở app cũ rồi nhập vào app mới như hướng dẫn hiện hành.

Bản vá web app được phân phối riêng; gói cập nhật game không chứa web app QA. Backup source trước sửa ở `Data/codex_backup_startup_minimum_20261119/`.
