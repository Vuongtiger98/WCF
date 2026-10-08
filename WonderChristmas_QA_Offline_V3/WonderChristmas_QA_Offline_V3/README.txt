WONDER CHRISTMAS FIESTA — OFFLINE PLAYTEST

Mở index.html bằng Chrome hoặc Edge.

CẬP NHẬT NỘI DUNG 2026-09-30
- Đã sinh lại toàn bộ thoại từ dữ liệu game hiện tại; thoại, lựa chọn, face,
  chỉ số face, pop message và xuống dòng cũ không còn trong game đã bị loại.
- Đã thay checklist Map28 bằng các bài test chi tiết cho ánh sáng/Region,
  clone, thùng lửa, gai, đá lăn, cửa–nút và cơ chế bốn lần choáng.
- Ánh sáng nút và hiệu ứng choáng được kiểm tra riêng để tránh chớp đen và
  hiệu ứng camera mạnh kéo dài gây chóng mặt.

GIỮ NGUYÊN TIẾN ĐỘ KHI CẬP NHẬT
- Chép đè nội dung bản mới vào đúng thư mục app cũ và giữ nguyên tên/vị trí
  index.html. Không cần xóa dữ liệu trình duyệt.
- Bản cập nhật giữ nguyên mã lưu và toàn bộ ID route/khung cũ. Các khung mới
  chỉ được nối vào cuối route nên kết quả OK, lỗi, đề xuất và vị trí đang xem
  trước đây không bị xóa.
- App tự giữ thêm một bản sao dữ liệu cũ trong localStorage trước lần mở đầu
  tiên của nội dung mới. Nếu buộc phải chuyển app sang đường dẫn khác, hãy
  Xuất báo cáo ở bản cũ rồi Nhập báo cáo ở bản mới để trình duyệt chuyển dữ
  liệu an toàn.

Thư mục file lỗi:
- evidence/screenshots
- evidence/videos
- evidence/saves

Thư mục face tham chiếu:
- faces

Luồng test mới:
- Mỗi lần chỉ đối chiếu một khung mô tả hoặc một khung thoại.
- OK xác nhận khung hiện tại, Tiếp tục sang khung kế tiếp.
- Báo lỗi và Đề xuất luôn tự gắn đúng route/scene/map và đúng mã khung.
- Đề xuất thoại cho phép sửa xuống dòng, face và cờ pop message; app kiểm tra
  tối đa 4 dòng, 40 ký tự/dòng khi không có face; khi có face, 33 là mức
  khuyến nghị và 34 là mức tối đa. Chữ Việt có dấu chỉ được tính là 1 ký tự.

Khi gửi kết quả, đặt report.html và result.json đã xuất ở thư mục gốc rồi gửi
nguyên folder. result.json là bản dữ liệu có mã item/khung để sửa game dễ dàng.

Toàn bộ thoại:
- Mục "Toàn bộ thoại" chứa thoại từ Show Text, Scrolling Text, Choices trong
  các map và Common Event, cùng nội dung Cutscene Group Chat.
- Scene và Map tương tác có số map cũng tự nối các khung thoại của map đó.
- Mỗi khung lưu Map/Event/Page/Command hoặc file/dòng script trong phần Nguồn.
- Sau khi sửa thoại trong game, chạy lại:
  ruby tools/generate_dialogues.rb
