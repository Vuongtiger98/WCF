# Cách viết RGSS3 phù hợp với WCF

Các quy tắc này được rút từ code chuẩn VX Ace trong project, các lỗi thực tế và tài liệu Ruby/tác giả script. Ví dụ đánh dấu “đề xuất” chưa phải API đã cài vào game.

## Ngôn ngữ và môi trường

Runtime mục tiêu là RGSS3/Ruby 1.9.2 của VX Ace. Không đưa cú pháp Ruby hiện đại như `&.`, keyword arguments kiểu mới, endless method, `Module#prepend`, `Hash#dig` hoặc `filter_map` vào script game. Tool offline trong `tools/` có thể dùng Ruby hiện đại và không được import vào Script Editor.

Tra ngữ nghĩa alias/module bằng [Ruby Module 1.9.2](https://ruby-doc.org/core-1.9.2/Module.html). `alias_method` lưu implementation tại thời điểm alias, vì vậy chuyển slot có thể thay hoàn toàn method được giữ lại. Không dùng các tài liệu Ruby mới để mặc định mọi API sẽ tồn tại trong RGSS3.

Script của author là mẫu tham khảo có giá trị: [Galv Layer Graphics](https://galvs-scripts.com/galvs-layer-graphics/) dùng state theo map và hook lifecycle; bản WCF còn cần các sửa ownership nêu trong audit. Không coi một script có phiên bản “mới nhất” là tự động tương thích toàn bộ stack hiện tại.

## Chia trách nhiệm trước khi hook engine

Một tính năng nên có ba phần:

- Config: preset, ID, tên tài nguyên và tùy chọn.
- State: tiến độ cần lưu, chỉ gồm dữ liệu Marshal được.
- Renderer/controller: sprite, viewport, input, update và dispose; tái tạo theo scene/map hiện tại.

`Game_System`/đối tượng lưu game giữ state lâu dài; `Game_Temp` chỉ giữ dữ liệu tạm. Không lưu Sprite, Bitmap, Viewport, Fiber, Proc hoặc manager gắn scene vào save. Save cũ thiếu ivar cần accessor có fallback hoặc bước migration rõ ràng.

## Alias nhỏ, tên riêng và trả nguyên kết quả

Ví dụ đề xuất cho một hook chỉ ghi log sau transfer:

```ruby
class Game_Map
  alias_method :wcf_example_setup_before_log, :setup
  def setup(map_id)
    result = wcf_example_setup_before_log(map_id)
    WCFExample.log_map(map_id)
    result
  end
end
```

Tên alias có prefix riêng giúp tránh đụng tên; script này vẫn chỉ được nạp một lần. Trước khi override toàn bộ method, liệt kê side effect bản gốc và patch đang load sau. Lỗi Group Chat trước đây là ví dụ: chỉ lưu text mà bỏ switch/variable sẽ làm route sai dù giao diện chọn vẫn hoạt động.

## Quyền sở hữu ảnh và vòng đời

Bitmap lấy từ `Cache.*` có thể đang được nhiều sprite dùng chung. Sprite/Plane chỉ dispose chính nó; clone một bitmap nếu cần chỉnh pixel hoặc tự sở hữu và hủy bản clone đó. Bitmap tạo bằng `Bitmap.new`/ảnh snapshot riêng phải có đường dispose rõ ràng.

Với animation cache có reference count, hoãn hủy phải xét số người đang dùng tại thời điểm dọn queue. Một bitmap có thể đã về 0 reference, được queue, rồi được animation khác mượn lại. Chính vì vậy việc chỉ thêm `unless disposed?` chưa chữa hết lỗi.

Scene_Map có thể tồn tại qua transfer. Mỗi manager bám event phải kiểm tra map_id, dọn sprite/light cũ rồi bind event mới. Không giữ event có ID trùng như thể đó vẫn là cùng một nhân vật sau transfer.

## Timing và phối hợp cutscene

Dùng frame counter cục bộ cho hiệu ứng/minigame; reset khi bắt đầu lại. Dùng `update` từng frame hoặc Fiber của interpreter đúng chỗ, không dùng sleep chặn vòng game.

Một lệnh tween ánh sáng/camera không bảo đảm đã kết thúc khi method return. Khi shot phụ thuộc kết quả tween, event cần Wait hoặc API chờ. Trước khi trả free roam, phục hồi player visibility/through/speed, camera target/zoom, KUL, overlay và input lock theo thiết kế của scene.

CG 544×416 cần background đen có cùng vòng đời với CG. Handoff player → overlay phải chuẩn bị frame crop và ẩn bản gốc trước khi reveal để không lộ nguyên atlas hoặc hai sprite cùng lúc.

## Tiếng Việt và message

Giới hạn writer theo ký tự người đọc thấy, không theo số byte UTF-8. Nếu có Unicode tổ hợp, bước normalize/count ở tool writer cần được xác định riêng; không giả định Ruby 1.9.2 có API normalize hiện đại.

Độ rộng hộp thoại phải đo giống cách engine vẽ từng glyph và xử lý escape code/font/icon. Giữ quy tắc tối đa bốn dòng, khoảng 33 ký tự khi có face và 40 khi không face trong luồng kiểm tra thoại; kích thước pixel vẫn cần đo riêng để tránh cắt chữ.

Bubble target, face window và mũi tên có state riêng; đóng text không tự bảo đảm cả ba đã được dọn khi gọi scene chat. Mọi API cleanup cần chịu được trường hợp cửa sổ phụ chưa từng được tạo.

## Hiệu năng và kiểm thử

Không tạo Bitmap/Font/Rect lớn hoặc quét toàn bộ event mỗi frame nếu chỉ có một ít thay đổi. Cache dữ liệu đã parse; dùng dirty flag và danh sách event liên quan. Đèn dynamic dành cho nhân vật di chuyển, đèn static dành cho nguồn cố định; không giảm shadow để bù một light preset không phù hợp.

Kiểm tra tối thiểu: New Game, load save cũ, transfer bình thường, vào từ Test Hub, scene phụ, retry, hủy choice, và chạy nhiều lần tính năng trong cùng phiên. `ruby -c` chỉ bắt cú pháp theo Ruby máy kiểm tra; cần test hành vi bằng fixture và playtest trong Game.exe cho API native.

Khi sửa runtime, định danh slot theo tên/ID, xác nhận byte nguồn hoặc hash trước thay, kiểm tra export/CSV và so thứ tự slot sau sửa. Không import cả thư mục để áp một patch nhỏ.
