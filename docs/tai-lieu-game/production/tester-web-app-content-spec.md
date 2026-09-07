# Đặc tả nội dung web app hỗ trợ playtest

## 1. Mục tiêu

Web app giúp người chơi phổ thông playtest bản hoàn chỉnh của **Wonder Christmas Fiesta** mà không cần biết cách dự án được xây dựng bên trong.

Người chơi chỉ cần biết:

- Bắt đầu đoạn test ở đâu.
- Cần chọn hoặc tương tác như thế nào.
- Nếu game chạy đúng thì họ sẽ nhìn thấy chuyện gì.
- Dấu hiệu nào cho thấy game đã chạy sai.
- Cách gửi ảnh, video, save và mô tả lỗi cho đội phát triển.

Tài liệu này là đặc tả nội dung cần đưa vào web app. Đây không phải checklist để tester đọc trực tiếp và không dùng để ghi kết quả test trong file Markdown.

## 2. Ngôn ngữ hiển thị

Mọi nội dung trên web app phải dùng ngôn ngữ của người chơi, không dùng thuật ngữ nội bộ của RPG Maker.

Quy tắc đặt tên địa điểm:

| Không nên ghi | Cách phải hiển thị |
|---|---|
| `Map043` | `Map43 (Phòng Shylvie)` |
| `Map038` | `Map38 (Văn phòng Wanderer trong tiệc Giáng sinh)` |
| `Map019` | `Map19 (Siêu thị)` |
| `Map029` | `Map29 (Hành lang rượt đuổi ở Atlantis)` |

Quy tắc mô tả:

- Không nhắc tới tên biến, công tắc, số trang sự kiện, mã event hoặc tên script.
- Không yêu cầu người chơi mở trình chỉnh sửa game.
- Không viết “giá trị phải bằng 1”; viết “lựa chọn cà phê phải dẫn tới tiệm cà phê”.
- Không viết “event tự chạy”; viết “cảnh phải tự bắt đầu khi người chơi vừa tới nơi”.
- Không viết “bật Through”; viết “sau cảnh, Hải Quỳ phải đi lại và va chạm bình thường”.
- Không viết tên hệ thống ánh sáng; chỉ mô tả màn hình phải tối, sáng hoặc chuyển cảnh như thế nào.
- Mỗi địa điểm luôn hiện cả số map và tên dễ hiểu.
- Mỗi nhánh luôn nhắc lại món quà và người nhận để người chơi nhận ra ngay khi game đi sai route.

## 3. Cấu trúc web app

### 3.1. Màn hình chính

Màn hình chính có bốn khu vực nội dung:

| Khu vực | Nội dung |
|---|---|
| Route | Theo dõi một đường chơi từ điểm lựa chọn tới ending |
| Scene | Kiểm tra một cảnh cắt, chuyển cảnh hoặc đoạn hội thoại cụ thể |
| Map tương tác | Khám phá địa điểm, kiểm tra vật thể, cửa ra vào và hội thoại phụ |
| Minigame | Kiểm tra luật chơi, thắng, thua, thoát và việc quay lại game chính |

Phần đầu trang cho phép chọn tên tester, phiên bản game, ngày test và thiết bị. Tiến độ được tính riêng cho từng khu vực và cho toàn bộ bản build.

### 3.2. Trạng thái một nội dung

Web app dùng chữ đầy đủ:

| Trạng thái | Ý nghĩa |
|---|---|
| Chưa thử | Người chơi chưa mở nội dung này |
| Đang thử | Đã bắt đầu nhưng chưa đi hết đoạn |
| Diễn ra đúng | Mọi diễn biến quan trọng đều khớp mô tả |
| Có lỗi | Có ít nhất một điểm khác mô tả |
| Không thể tiếp tục | Game crash, màn hình đen vĩnh viễn hoặc bị kẹt |
| Cần thử lại | Lỗi chưa tái hiện ổn định hoặc cần bản build mới |

### 3.3. Nội dung của mỗi trang test

Mỗi route, scene, map hoặc minigame cần có cùng bố cục:

| Phần | Nội dung hiển thị |
|---|---|
| Bạn đang kiểm tra | Tên route/scene/map/minigame bằng ngôn ngữ tự nhiên |
| Bắt đầu tại | Ví dụ `Map10 (Trong xe bus)` hoặc tên save do đội phát triển cấp |
| Cách đi tới | Những lựa chọn và tương tác người chơi cần thực hiện |
| Nếu đúng, bạn sẽ thấy | Trình tự hình ảnh, hội thoại và kết quả chính |
| Có thể là lỗi nếu | Các dấu hiệu dễ nhận biết khi game chạy sai |
| Kết thúc tại | Cảnh, địa điểm hoặc ending mong đợi |
| Gửi báo cáo | Trạng thái, mô tả, ảnh/video và save gần lỗi nhất |

Web app cần ghi nhớ tiến độ tự động. Người chơi có thể thoát trình duyệt rồi quay lại mà không mất những nội dung đã đánh dấu.

### 3.4. Báo lỗi

Khi chọn “Có lỗi” hoặc “Không thể tiếp tục”, web app mở biểu mẫu gồm:

- Chuyện gì đã xảy ra.
- Người chơi đang ở địa điểm nào.
- Lựa chọn gần nhất trước khi lỗi xảy ra.
- Điều người chơi nhìn thấy khác mô tả như thế nào.
- Lỗi xảy ra mọi lần hay chỉ đôi lúc.
- Ảnh chụp hoặc video.
- File save ngay trước lỗi, nếu có.
- Nội dung lỗi trong cửa sổ thông báo của game, nếu có.

Tên route, scene hoặc map đang test được điền tự động. Người chơi không cần tự nhớ số map.

## 4. Nội dung Route

### 4.1. Phần mở đầu dùng chung

#### Điểm bắt đầu và đường đi

Người chơi bắt đầu tại Map3 (Văn phòng Silver Wing), rời văn phòng qua Map6 (Thành phố) hoặc Map17 (Hành lang Silver Wing), rồi tới Map10 (Trong xe bus).

#### Diễn biến đúng

- Hội thoại tại Silver Wing diễn ra theo đúng thứ tự và đúng người nói.
- Nếu đi qua Map17 (Hành lang Silver Wing), Hải Quỳ vẫn phải tới đúng vị trí ở Map6 (Thành phố), giống như khi đi thẳng.
- Camera không bỏ lại Hải Quỳ và nhân vật không tự chạy tiếp sau khi đã sang map mới.
- Trên xe bus, Hải Quỳ suy nghĩ về quà Giáng sinh bằng hộp thoại bình thường.
- Cuối cảnh xe bus, người chơi được chọn hướng đi: siêu thị, văn phòng Wanderer, Atlantis hoặc mua mì cay.
- Mỗi lựa chọn dẫn đúng địa điểm được ghi trên nút chọn.

#### Dấu hiệu game chạy sai

- Hải Quỳ xuất hiện lệch vị trí hoặc tiếp tục tự đi sau khi sang Map6 (Thành phố).
- Màn hình vẫn đen sau khi xe bus tới nơi.
- Có một khung hình rất sáng trước khi map mới tối lại.
- Chọn một địa điểm nhưng bị đưa tới địa điểm khác.

### 4.2. Nhóm route mua quà tại siêu thị

#### Đường đi chung

Map10 (Trong xe bus) → Map19 (Siêu thị) → Map37 (Phòng Hải Quỳ lúc chuẩn bị quà) → Map38 (Văn phòng Wanderer trong tiệc Giáng sinh) → Map39 (Sáng hôm sau tại văn phòng Wanderer) → Map36 (Gợi ý sau ending).

Riêng máy pha cà phê có thêm Map40 (Chuyến xuống Atlantis lấy cà phê).

#### Diễn biến chung phải có

- Khi vừa tới Map19 (Siêu thị), chiếc xe bus ở ngoài cửa tiếp tục chạy sang trái rồi rời khỏi màn hình.
- Người chơi có thể xem cả bốn món quà trước khi quyết định.
- Chọn một món không được tự kéo Hải Quỳ tới quầy. Người chơi vẫn được tự do đi lại và chỉ thanh toán khi chủ động ra cửa.
- Sau khi thanh toán, người chơi chọn Leo, Kohi, Shylvie hoặc Hakase làm người nhận.
- Không được thoát khỏi màn hình chọn người nhận mà chưa chọn ai.
- Ảnh món đồ phải đúng với món vừa chọn.
- Cảnh chuẩn bị quà, bữa tiệc, cảnh trao quà, đoạn sáng hôm sau và lời gợi ý cuối phải cùng một món quà và cùng một người nhận.
- Trước khi tiếp tục bữa tiệc, người chơi được đi lại tự do và có thể rủ bốn thành viên chơi ném tuyết.

#### Các route bộ phá khóa

| Lựa chọn của người chơi | Nội dung đúng cần xuất hiện |
|---|---|
| Bộ phá khóa tặng Leo | Leo nhận bộ phá khóa. Về sau Leo dùng nó để mở cửa cứu Hải Quỳ bị kẹt. Lời gợi ý cuối nhắc tới việc món quà kỳ lạ này đã cứu được tình huống. |
| Bộ phá khóa tặng Kohi | Kohi nhận bộ phá khóa. Đoạn sau vẫn phải đi theo kịch bản Kohi chuyển sang chuyện máy pha cà phê; đây là chủ ý của kịch bản, không phải game đi nhầm route. |
| Bộ phá khóa tặng Shylvie | Shylvie nhận bộ phá khóa, nâng cấp nó thành dụng cụ phá phép và gây rắc rối với nhóm đầu ổ khóa. |
| Bộ phá khóa tặng Hakase | Hakase nhận bộ phá khóa, luyện mở khóa rồi bị cảnh sát hiểu nhầm là trộm. |

#### Các route combo dao và chảo

| Lựa chọn của người chơi | Nội dung đúng cần xuất hiện |
|---|---|
| Dao và chảo tặng Leo | Leo nhận đúng combo dao và chảo. Đoạn sau liên hệ tới việc Leo biết nấu mì cay. |
| Dao và chảo tặng Kohi | Kohi nhận đúng combo dao và chảo. Đoạn sau liên hệ tới món phở của Kohi và việc cô làm gãy thớt. |
| Dao và chảo tặng Shylvie | Shylvie nhận đúng combo dao và chảo. Đoạn sau phải giữ hướng Shylvie thích dụng cụ làm bếp. |
| Dao và chảo tặng Hakase | Hakase nhận đúng combo dao và chảo. Đoạn sau liên hệ tới món omurice trứng hắc ám và thịt Leviathan chiên xù. |

#### Các route đan khăn len

| Lựa chọn của người chơi | Nội dung đúng cần xuất hiện |
|---|---|
| Khăn len tặng Leo | Leo nhận khăn và vẫn khen dù chiếc khăn chưa đẹp. |
| Khăn len tặng Kohi | Khăn có chi tiết hình hạt cà phê; Kohi vui vẻ nhận, quàng khăn và ôm Hải Quỳ. |
| Khăn len tặng Shylvie | Khăn dành cho Shylvie có chi tiết gợi tới chiếc khiên; phản ứng của Shylvie không được thay bằng phản ứng của người khác. |
| Khăn len tặng Hakase | Hakase nhận khăn. Lời gợi ý cuối hướng người chơi tới khả năng tặng Hakase một quyển sách phép. |

Các route khăn len dùng một cảnh kết chung theo kịch bản. Web app không được mô tả như thể cả bốn người đều có một hậu truyện riêng hoàn toàn khác nhau.

#### Các route máy pha cà phê

Mỗi người nhận có hai cách hoàn thành:

| Người nhận | Cách lấy cà phê | Nội dung đúng cần xuất hiện |
|---|---|---|
| Leo | Dùng cà phê thường | Người chơi bỏ qua minigame, tiếp tục chuẩn bị quà cho Leo và nhận toàn bộ hội thoại của trường hợp cà phê thường. |
| Leo | Đi câu tôm | Người chơi phải câu đủ cà phê Atlantis trước khi tiếp tục; phần sau ghi nhận đây là cà phê Atlantis. |
| Kohi | Dùng cà phê thường | Người chơi bỏ qua minigame, tiếp tục chuẩn bị quà cho Kohi và nhận toàn bộ hội thoại của trường hợp cà phê thường. |
| Kohi | Đi câu tôm | Người chơi phải câu đủ cà phê Atlantis; Kohi nhận máy pha cà phê và route giữ đúng nội dung cà phê Atlantis. |
| Shylvie | Dùng cà phê thường | Người chơi bỏ qua minigame, tiếp tục chuẩn bị quà cho Shylvie và nhận toàn bộ hội thoại của trường hợp cà phê thường. |
| Shylvie | Đi câu tôm | Người chơi phải câu đủ cà phê Atlantis; phần sau không được quay về nội dung cà phê thường. |
| Hakase | Dùng cà phê thường | Người chơi bỏ qua minigame, tiếp tục chuẩn bị quà cho Hakase và nhận toàn bộ hội thoại của trường hợp cà phê thường. |
| Hakase | Đi câu tôm | Người chơi phải câu đủ cà phê Atlantis; đoạn sau có hậu quả mạnh của món quà và lời gợi ý cuối trách Hải Quỳ vì lựa chọn này. |

Tại Map40 (Chuyến xuống Atlantis lấy cà phê), màn hình đang đen nên lời kể phải dùng hộp thoại bình thường. Người chơi nghe tin quái vật Vực Sâu đã bị khống chế và mái nhà thị chính bị hỏng, rồi được biết quán đã hết cà phê Atlantis. Sau đó mới xuất hiện lựa chọn dùng cà phê thường hoặc đi câu tôm.

### 4.3. Route mua mì cay cho Leo

#### Đường đi

Map10 (Trong xe bus) → Map20 (Tiệm mì cay) → Map47 (Phòng Hải Quỳ lúc chuẩn bị mì cay) → Map14 (Nhà bếp Wanderer) → Map38 (Văn phòng Wanderer trong tiệc Giáng sinh) → Map36 (Gợi ý sau ending).

#### Hai cách hoàn thành

| Lựa chọn | Diễn biến đúng |
|---|---|
| Tin Aira | Aira chọn nguyên liệu và phụ trách hướng nấu. Có một đoạn mua nguyên liệu tại Map19 (Siêu thị), nhưng người chơi không bị đưa vào hệ thống chọn quà của siêu thị. |
| Không tin Aira | Hải Quỳ ăn nhiều tô mì, phân tích công thức rồi tự chuẩn bị hướng nấu. |

#### Những điểm người chơi phải thấy

- Người nhận luôn là Leo; không xuất hiện màn hình chọn bốn người.
- Cảnh nấu ăn ở Map14 (Nhà bếp Wanderer) chỉ chạy một lần.
- Hình tô mì phải đúng người nấu.
- Trong bữa tiệc có nồi mì cay, bình Sting 20 lít, cảnh tuyết với Hải Quỳ hoặc Bully Quỳ, cùng các cảnh ăn uống liên quan.
- Người chơi được khám phá tự do và chơi ném tuyết trước khi chọn tiếp tục.
- Sau cuộc gọi từ Silver Wing, route đi tới lời gợi ý cuối. Không có một buổi sáng hôm sau được tự thêm ngoài kịch bản.

### 4.4. Route hỏi Leo ba lần

#### Điểm bắt đầu

Tại Map13 (Văn phòng Wanderer), người chơi nói chuyện với Leo ba lần. Sau lần thứ ba, game tự chuyển sang cuộc trò chuyện riêng để chọn một trong ba địa điểm.

#### Ba nhánh

| Lựa chọn | Đường đi và kết quả đúng |
|---|---|
| Tiệm cà phê | Tới Map58 (Tiệm cà phê), mua cà phê Luminous cho Kohi, sau đó chuẩn bị quà, dự tiệc và nhận lời gợi ý về cà phê Luminous. |
| Cửa hàng vũ khí | Tới Map59 (Cửa hàng vũ khí), mua món đồ sau đó trở thành chiếc khiên cho Shylvie, dự tiệc và nhận lời gợi ý về chiếc khiên. |
| Tiệm ma pháp | Tới Map57 (Tiệm ma pháp), mua áo choàng luyện tàng hình cho Hakase, dự tiệc và kết thúc bằng đoạn gợi ý có Drosalya. |

#### Những điểm người chơi phải thấy

- Chọn tiệm cà phê hoặc cửa hàng vũ khí tuyệt đối không được đưa tới tiệm ma pháp.
- Cảnh phải tự bắt đầu khi vừa tới đúng cửa hàng.
- Chủ tiệm ma pháp lặp ba hình hút thuốc, mỗi hình giữ khoảng một giây.
- Map60 (Phòng Hải Quỳ lúc chuẩn bị quà theo lời Leo) dùng đúng quà vừa mua, không phát thoại của route mua đá.
- Hải Quỳ chỉ đổi sang trang phục Giáng sinh sau khi đã xem xong cảnh thử đồ.
- Khi sang Map38 (Văn phòng Wanderer trong tiệc Giáng sinh), màn hình phải sáng trở lại và người chơi được tự do khám phá.

### 4.5. Route hỏi Shylvie và mua đá phong thủy

Route này phải có mặt đầy đủ trong web app ngay từ cấu trúc nội dung đầu tiên, vì người chơi sẽ dùng app để kiểm tra phiên bản game hoàn chỉnh.

#### Điểm bắt đầu

Tại Map13 (Văn phòng Wanderer), người chơi nói chuyện với Shylvie cho tới khi cô gửi tọa độ tiệm đá phong thủy. Hải Quỳ tới tiệm, xem các kệ đá rồi chọn người sẽ nhận quà.

#### Bốn nhánh

| Người nhận | Món quà | Diễn biến đúng cần thấy |
|---|---|---|
| Leo | Purple Garnet | Hải Quỳ chọn viên đá tím. Chủ tiệm giải thích nó giúp giải trừ trạng thái bất lợi, độc tố và hỗ trợ tinh thần. Khi nhận quà, Leo cảm thấy mệt mỏi tan biến. Đoạn sau cho thấy viên đá bị vỡ và Leo tận dụng các mảnh làm chuông gió. |
| Kohi | Kim cương hình hạt cà phê | Hải Quỳ chọn vì viên kim cương có hình hạt cà phê. Kohi nhận quà, vui mừng và cài viên kim cương lên tóc. Đoạn gợi ý cuối nhắc rằng Hải Quỳ chỉ chú ý hình dạng mà không nghĩ tới công dụng xua đuổi ma quỷ. |
| Shylvie | Congo Tourmaline | Hải Quỳ chọn viên đá không theo màu xanh quen thuộc của Shylvie. Khi Shylvie nhận quà, viên đá phát sáng và triệu hồi một chiếc khiên phép thuật trong suốt. |
| Hakase | Rainbow Fluorite | Chủ tiệm giải thích đây là đá tri thức, chứa ngẫu nhiên phép thuật. Hakase kích hoạt đá, học các phép biến đổi kỳ lạ rồi dùng viên đá như nơi lưu trữ ma lực và thông tin. |

#### Phần chung của route

- Sau khi mua đá, Hải Quỳ chuẩn bị và đặt gói quà trong phòng.
- Game đi tới bữa tiệc Giáng sinh, cho phép khám phá tự do và chơi ném tuyết.
- Người nhận, hình viên đá, phản ứng trong bữa tiệc, đoạn sau bữa tiệc và lời gợi ý cuối phải cùng một nhánh.
- Route không được tự chuyển sang tiệm ma pháp, tiệm cà phê hoặc cửa hàng vũ khí của nhánh hỏi Leo.

### 4.6. Atlantis — mua sách phép tặng Shylvie

#### Đường đi

Map10 (Trong xe bus) → Map22 (Nhà Hải Quỳ) → Map21 (Điểm xuống Atlantis) → Map23 (Tiệm sách phép Atlantis) → Map49 (Phòng Hải Quỳ lúc chuẩn bị sách) → Map38 (Văn phòng Wanderer trong tiệc Giáng sinh) → Map50 (Đoạn sau khi tặng sách cho Shylvie) → Map36 (Gợi ý sau ending).

#### Diễn biến đúng

- Người chơi chọn sách phép dịch chuyển nâng cao và mang sách ra quầy.
- Sau khi chọn, game không cho đổi sang sách Ma Vương Cổ Đại.
- Hải Quỳ ngủ quên, thức dậy muộn và thay đồ; hình nhân vật chỉ đổi sau cảnh thay đồ.
- Khi tới văn phòng muộn, scene không được phát lại toàn bộ đoạn mọi người còn chuẩn bị bữa tiệc.
- Người chơi được khám phá tự do và chơi ném tuyết.
- Shylvie nhận đúng sách dịch chuyển.
- Đoạn sau bữa tiệc nói về phép hoán đổi/dịch chuyển và kết thúc bằng đúng lời gợi ý của route này.

### 4.7. Atlantis — mua sách Ma Vương Cổ Đại tặng Hakase

#### Đường đi

Map10 (Trong xe bus) → Map22 (Nhà Hải Quỳ) → Map21 (Điểm xuống Atlantis) → Map23 (Tiệm sách phép Atlantis) → Map51 (Phòng Hải Quỳ lúc chuẩn bị sách) → Map38 (Văn phòng Wanderer trong tiệc Giáng sinh) → Map52 (Đoạn sau khi tặng sách cho Hakase) → Map36 (Gợi ý sau ending).

#### Diễn biến đúng

- Người chơi chọn sách Ma Vương Cổ Đại và mang sách ra quầy.
- Sau khi chọn, game không cho đổi sang sách dịch chuyển.
- Hải Quỳ chỉ đổi trang phục sau cảnh thử đồ.
- Người chơi được khám phá tự do và chơi ném tuyết trước khi tiếp tục tiệc.
- Hakase nhận đúng sách và phần sau nói về việc hấp thụ ma lực Ma Vương.
- Trong vòng quà có hình váy tặng Shylvie và ốp lưng đúng thời điểm.
- Route kết thúc bằng lời gợi ý riêng của sách Ma Vương Cổ Đại.

### 4.8. Atlantis — nói chuyện với chủ tiệm sách trước

#### Đường đi

Map23 (Tiệm sách phép Atlantis) → Map53 (Cảnh tự phong ấn) → Map54 (Văn phòng Wanderer đi tìm Hải Quỳ) → Map55 (Cảnh giải cứu) → Map36 (Gợi ý sau ending).

#### Diễn biến đúng

- Người chơi ưu tiên nói chuyện với chủ tiệm trước khi chọn sách.
- Tạo vật Vực Sâu phát nổ và chiếm hữu Hải Quỳ/Aira.
- Hải Quỳ tự phong ấn trong lồng giam.
- Nhóm Wanderer lần theo dấu vết và tới giải cứu.
- Các vết nứt đầu tiên trên lồng xuất hiện chậm, nặng; các vết sau nhanh dần cho tới khi lồng vỡ.
- Route này không mở phần khám phá tiệc Giáng sinh và không đi qua cảnh Paulie rượt quái vật.
- Sau giải cứu, game đi tới lời gợi ý cuối và Title.

### 4.9. Atlantis — phòng kho, ký ức, rượt đuổi và Paulie

#### Đường đi

Map22 (Nhà Hải Quỳ) → Map26 (Phòng kho nhà Hải Quỳ) → Map24 (Ký ức bãi rác) → Map28 (Mê cung gương Atlantis) → Map34 (Vòng vây clone) → Map29 (Hành lang rượt đuổi ở Atlantis) → Map25 (Đối đầu quái vật Vực Sâu) → Map35 (Phòng Hải Quỳ vào đêm muộn) → Map36 (Gợi ý sau ending).

#### Diễn biến đúng

- Người chơi tìm được chìa khóa, bật đèn phòng kho và đọc lá thư cuối của Dahria.
- Đọc xong thư phải dẫn vào ký ức và cuộc rượt đuổi, không đưa người chơi tới route chọn sách.
- Trong Map34 (Vòng vây clone), cả 11 clone chạy sát tới quanh Hải Quỳ như đang giữ cô.
- Chỉ khi đủ clone, Hải Quỳ mới nói “Buông tao ra!”, đánh văng chúng, hiện dấu chấm than và quay lên.
- Quái vật bước vào khung hình rồi mới gầm và làm rung màn hình.
- Trong Map29 (Hành lang rượt đuổi ở Atlantis), Hải Quỳ và quái vật cùng chạy xuống. Quái vật ở phía trên màn hình và tiến gần dần nhưng không chạy xuyên qua Hải Quỳ.
- Sau khi thoát, Hải Quỳ và quái vật đứng gần nhau. Hải Quỳ nhảy lùi trước khi Paulie đáp xuống.
- Camera đưa Hải Quỳ và quái vật ra khỏi khung hình, rồi Paulie rơi từ trên cao bằng hình nhân vật đáp đất.
- Chỉ có một Paulie trên màn hình. Ba hình đầu lặp lại khi rơi; những hình còn lại chạy khi đáp xuống.
- Hiệu ứng đáp đất xuất hiện tại Paulie. Sau khi hiệu ứng kết thúc, Paulie trở về hình đứng bình thường.
- Paulie hô tên đòn, hiệu ứng khống chế xuất hiện ở quái vật, rồi quái vật mới chạy các hình bị trói.
- Paulie nhảy tới bên phải Hải Quỳ, cách khoảng hai ô. Hai anh em quay mặt vào nhau và nói chuyện.
- Hải Quỳ tung đòn kết liễu tại quái vật. Xác quái vật vỡ vụn, hình ảnh tối dần như Hải Quỳ kiệt sức.
- Chỉ khi màn hình tối hoàn toàn mới chuyển sang Map35 (Phòng Hải Quỳ vào đêm muộn).
- Khi Paulie rời đi, Paulie biến mất trước rồi hiệu ứng dịch chuyển vẫn phát đủ tại vị trí cũ.
- Cuộc trò chuyện điện thoại sau đó không còn đuôi của hộp thoại nổi trên màn hình.

## 5. Nội dung Scene

Web app cần cho phép tìm scene độc lập với route. Một scene đã được xác nhận trong route sẽ đồng thời cập nhật tiến độ ở khu vực Scene.

### 5.1. Scene mở đầu và di chuyển

| Scene | Diễn biến đúng cần mô tả |
|---|---|
| Map3 (Văn phòng Silver Wing) | Hội thoại, camera và việc rời văn phòng diễn ra trọn vẹn; không ai bị kẹt khi tự đi. |
| Map17 (Hành lang Silver Wing) | Đoạn hành lang kết thúc trước khi chuyển map; Hải Quỳ không tiếp tục một lộ trình cũ ở map mới. |
| Map6 (Thành phố) | Camera bắt kịp Hải Quỳ và chuyển được lên xe bus. |
| Map10 (Trong xe bus) | Lời kể hiện bình thường, hiệu ứng xe rung không làm lệch camera, các lựa chọn dẫn đúng nơi. |

### 5.2. Scene chuẩn bị quà và ngủ dậy

Phạm vi gồm Map37 (Chuẩn bị quà siêu thị), Map47 (Chuẩn bị mì cay), Map49 (Chuẩn bị sách cho Shylvie), Map51 (Chuẩn bị sách cho Hakase), Map60 (Chuẩn bị quà theo lời Leo) và map chuẩn bị của route mua đá.

Mỗi trang scene cần mô tả:

- Món quà và người nhận đang được nhắc tới.
- Hải Quỳ ngủ trước, sau đó mới thức dậy.
- Màn hình che việc thay đổi trạng thái nhân vật.
- Cảnh thử nhiều bộ đồ chạy đúng thứ tự.
- Hải Quỳ chỉ đổi sang hình mặc đồ Giáng sinh sau khi chọn xong bộ đồ cuối.
- Màn hình phải sáng trở lại để câu chuyện tiếp tục.

Dấu hiệu sai dễ nhận biết là Hải Quỳ đổi hình nhân vật trước cảnh thay đồ, một hình khác lóe lên lúc nhắm mắt, hoặc màn hình tối rồi không có gì xảy ra.

### 5.3. Scene tiệc Giáng sinh

Phạm vi chính là Map38 (Văn phòng Wanderer trong tiệc Giáng sinh).

Web app chia cảnh thành bốn đoạn:

1. Hải Quỳ/Aira tới văn phòng và phần chuẩn bị tiệc phù hợp với route.
2. Bữa ăn, hội thoại nhóm và các ảnh minh họa liên quan.
3. Khám phá tự do, vào các phòng và chơi ném tuyết.
4. Chọn tiếp tục, trao quà, nhận cuộc gọi khẩn và rời tiệc.

Người chơi cần được cảnh báo báo lỗi nếu:

- Thoại của một route khác xuất hiện.
- Cảnh tới muộn vẫn phát đoạn chuẩn bị tiệc như người tới sớm.
- Chọn “chưa tiếp tục” nhưng không thể đi lại.
- Chọn “tiếp tục” làm scene chạy lặp hoặc crash.
- Ảnh CG bị hộp thoại nổi che lên.
- Màn hình vẫn đen khi phần tự do bắt đầu.

### 5.4. Scene ăn mì tại nhà Hải Quỳ

Hải Quỳ và Paulie ngồi đối diện nhau tại bàn ăn trên hình nền. Camera cần đặt hai người gần trung tâm màn hình, không dồn sang mép phải.

Game chọn đúng nền theo việc Hải Quỳ đã thay đổi hình dạng hay chưa. Những câu Hải Quỳ đang nghĩ một mình dùng hộp thoại bình thường. Những câu hai nhân vật nói trực tiếp có thể bám vào nhân vật nếu vị trí hiển thị chính xác. Kết thúc cảnh phải chuyển sang Map23 (Tiệm sách phép Atlantis) hoặc địa điểm tiếp theo với ánh sáng bình thường.

### 5.5. Scene văn phòng Wanderer trong đoạn Giáng sinh

Trong phân đoạn Hải Quỳ bị vùi trong tuyết, màn hình tối và lời thoại dùng hộp thoại bình thường. CG6 dùng cho Hải Quỳ; CG7 dùng cho Bully Quỳ. Sau đó màn hình tiếp tục tối cho tới khi scene kết thúc. Chỉ lúc game trả quyền đi lại tự do thì văn phòng mới sáng trở lại.

### 5.6. Scene Paulie khống chế quái vật

Trang scene này dùng toàn bộ trình tự đã mô tả trong route Atlantis rượt đuổi, nhưng tách thành các mốc có thể bấm xác nhận trong giao diện web:

| Mốc | Hình ảnh đúng |
|---|---|
| Camera đi lên | Hải Quỳ và quái vật rời khung hình; không nhìn thấy hai Paulie |
| Paulie rơi | Ba hình đầu của chuỗi đáp đất lặp lại để tạo cảm giác rơi rất lâu |
| Paulie đáp | Camera và Paulie cùng xuống; hiệu ứng đáp đất phát tại Paulie |
| Khống chế | Paulie trở về hình đứng thường, hô tên đòn, hiệu ứng xuất hiện tại quái vật, rồi quái vật bị trói |
| Hội thoại hai anh em | Paulie đứng bên phải Hải Quỳ, cách khoảng hai ô; cả hai quay vào nhau |
| Kết liễu | Hiệu ứng của Hải Quỳ trúng quái vật, xác vỡ và màn hình tối dần |

### 5.7. Quy tắc hình ảnh và hội thoại dùng cho mọi scene

- Nếu bản đồ và nhân vật đang hiện, hộp thoại nổi phải trỏ đúng người nói.
- Nếu màn hình đen hoặc đang hiện ảnh minh họa toàn màn hình, dùng hộp thoại bình thường, không có đuôi chỉ vào nhân vật.
- Suy nghĩ và độc thoại của Hải Quỳ dùng hộp thoại bình thường.
- Khi nhân vật có ảnh chân dung phù hợp, ảnh phải đúng người và đúng cảm xúc.
- Chữ tiếng Việt phải hiện đủ, đặc biệt là ký tự cuối dòng.
- Sau khi đóng ảnh minh họa, ảnh không được còn sót sang cảnh tiếp theo.
- Mỗi lần mở khóa CG hoặc nhận tin nhắn mới chỉ có một thông báo và thông báo không che nội dung quan trọng.
- Chuyển cảnh tối phải liền mạch, không lóe sáng một frame và không để màn hình đen vĩnh viễn.

## 6. Nội dung Map tương tác và khám phá tự do

Mỗi trang map trên web app có ảnh thu nhỏ của địa điểm, cách đi tới, danh sách khu vực có thể tương tác và mô tả điều người chơi sẽ thấy. Không hiển thị thuật ngữ event hoặc điều kiện nội bộ.

### 6.1. Khu vực công cộng

| Map | Nội dung người chơi cần khám phá |
|---|---|
| Map3 (Văn phòng Silver Wing) | Bàn làm việc, tủ, bảng ghi chú, đồng nghiệp, các đoạn hội thoại phụ và hai đường rời văn phòng. |
| Map6 (Thành phố) | Đường đi, va chạm, camera và các điểm chuyển khu vực. |
| Map13 (Văn phòng Wanderer) | Khu laser/xác thực, Leo, Shylvie, két sắt, đồ vật trong văn phòng, nhà bếp, phòng riêng, phòng họp và phòng chế tạo. |
| Map14 (Nhà bếp Wanderer) | Đồ bếp và các cửa nối về đúng phiên bản văn phòng mà người chơi vừa rời đi. |
| Map15 (Phòng tắm Wanderer) | Toàn bộ vật thể trong phòng tắm và đường quay lại. |
| Map19 (Siêu thị) | Bốn quà chính, các kệ hàng, hai quầy thu ngân, khu game bắn phi thuyền, vuốt mèo và đường ra cửa. |
| Map20 (Tiệm mì cay) | Hội thoại mua mì và hai lựa chọn tin/không tin Aira. |
| Map21 (Điểm xuống Atlantis) | Đoạn nối từ nhà Hải Quỳ tới tiệm sách phải liền mạch, không để người chơi ở lại một nơi trống hoặc tối vĩnh viễn. |
| Map23 (Tiệm sách phép Atlantis) | Hai vị trí trước cùng một quầy phải nói chuyện với cùng một bà chủ và dùng chung tiến độ; có hai sách route, quả địa cầu, giá sách, cửa phụ và các vật thể lore. Hộp thoại của bà chủ phải trỏ đúng hình bà đứng sau quầy. |
| Map28 (Mê cung gương Atlantis) | Các gương, cảnh hù dọa, va chạm và đường đi tới vòng vây clone; camera và ánh sáng phải luôn cho người chơi biết Hải Quỳ đang ở đâu. |
| Map57 (Tiệm ma pháp) | Chủ tiệm hút thuốc, các vật thể cửa hàng và cảnh mua áo choàng. |
| Map58 (Tiệm cà phê) | Hội thoại mua cà phê, nhân vật gần giữa màn hình và hộp thoại trỏ đúng vị trí. |
| Map59 (Cửa hàng vũ khí) | Chủ tiệm/NPC, vật phẩm, va chạm và cảnh mua món quà cho Shylvie. |
| Tiệm đá phong thủy | Các kệ đá, chủ tiệm, bốn lựa chọn người nhận và ảnh Purple Garnet, kim cương hạt cà phê, Congo Tourmaline, Rainbow Fluorite. Khi map chính thức có số, web app phải hiển thị theo mẫu `MapXX (Tiệm đá phong thủy)`. |

### 6.2. Nhà Hải Quỳ

| Map | Nội dung đúng cần mô tả |
|---|---|
| Map22 (Nhà Hải Quỳ) | Đồ vật trong nhà, điểm pha mì, chìa khóa, cầu thang và đường tới Atlantis. |
| Map41 (Phòng Hải Quỳ ở nhà) | Đây là phòng ở nhà vào buổi sáng, không phải phòng ngủ trong văn phòng Wanderer. Người chơi có thể xem hồ sơ, sách, đầu đĩa, tủ đầu giường và máy chơi game. |
| Map26 (Phòng kho nhà Hải Quỳ) | Trước khi bật đèn, các vật thể đều chỉ cho biết căn phòng quá tối và cần tìm đèn. Chỉ có một điểm bật đèn. Sau khi bật, mọi tương tác thật mới dùng được. |

Khi lên hoặc xuống cầu thang giữa Map22 (Nhà Hải Quỳ) và Map41 (Phòng Hải Quỳ ở nhà), Hải Quỳ phải trở lại tốc độ bình thường, không xuyên qua tường và không tiếp tục đi theo kiểu cầu thang ở nền phẳng.

### 6.3. Nhật ký, thư và album trong phòng kho

Các trang nội dung riêng trên web app cần chỉ cho người chơi biết thứ tự hợp lý mà không chép lại toàn bộ nội dung ảnh:

| Vật tương tác | Kết quả đúng |
|---|---|
| Nhật ký thời thơ ấu của Aira | Có một câu giới thiệu vật đang xem, sau đó hiện đúng bộ ảnh nhật ký thời thơ ấu của Aira. |
| Nhật ký cũ của Aira | Có câu giới thiệu, sau đó hiện đúng bộ ảnh nhật ký cũ của Aira. |
| Lá thư cuối của Dahria | Có câu giới thiệu, sau đó hiện đúng bộ ảnh lá thư cuối của Dahria; đọc hết dẫn tới nhánh ký ức/rượt đuổi. |
| Album ảnh | Có câu giới thiệu, cho xem Album 1 đến Album 4 và thêm cả bốn ảnh vào Gallery. |
| Đầu đĩa | Khi đã có băng, Hải Quỳ nói rằng mình bỏ băng tương ứng vào đầu đĩa. Những câu sau là âm thanh phát từ máy nên không dùng ảnh chân dung Hải Quỳ. |

### 6.4. Phòng riêng tại Wanderer

| Map | Nội dung người chơi cần khám phá |
|---|---|
| Map42 (Phòng Hải Quỳ ở văn phòng Wanderer) | Đây là phòng ngủ tại văn phòng, khác với phòng Hải Quỳ ở nhà; có két mã, đồ cá nhân, bồn tắm và TV dẫn tới bad ending. |
| Map43 (Phòng Shylvie) | Đồ vật của Shylvie, trạng thái bật/tắt đèn và các vật nhiều ô nhưng chỉ tiến triển một mạch hội thoại. |
| Map44 (Phòng Leo) | Đồ vật và lore của Leo; vật tương tác ở góc trên bên trái phòng có phần hội thoại tiếp theo riêng của Leo. |
| Map45 (Phòng Hakase) | Thiết bị, khe lắp RAM, đầu đĩa và các ghi chú âm thanh. |
| Map46 (Phòng Kohi) | Đồ vật của Kohi và thanh RAM dưới giường; RAM chỉ được lấy một lần rồi có thể đem sang phòng Hakase. |

Từ Map42 (Phòng Hải Quỳ ở văn phòng Wanderer), Map43 (Phòng Shylvie), Map44 (Phòng Leo), Map45 (Phòng Hakase) và Map46 (Phòng Kohi), đường ra phải đưa người chơi về đúng phiên bản văn phòng đã đi vào: văn phòng thường, tiệc Giáng sinh hoặc cảnh sáng hôm sau. Không được luôn luôn trả về Map13 (Văn phòng Wanderer thường).

### 6.5. Bồn tắm và TV trong Map42 (Phòng Hải Quỳ ở văn phòng Wanderer)

Bồn tắm phải khớp đúng chiếc bồn được vẽ ở góc dưới bên trái phòng. Khi Hải Quỳ tắm, ba hình đầu của cảnh tắm lặp ba lần, sau đó chạy các hình còn lại. Hình cuối giữ lại một lúc rồi màn hình mới tối và kết thúc cảnh.

TV là chiếc TV được vẽ ở góc trên bên trái phòng. Hải Quỳ phải ngồi trước TV; không đặt thêm một hình TV mới chắn trước mặt cô.

Chuỗi xem TV gồm chín hình theo đúng thứ tự. Mỗi hình hiện vài giây, màn hình tối hoàn toàn, hình mới được đổi trong lúc tối, rồi màn hình sáng lại. Chỉ sau hình thứ chín mới tiếp tục tới bad ending “Thêm tập nữa thôi!”.

### 6.6. Phòng họp và phòng chế tạo

Các phiên bản văn phòng đều có hai lối dùng chung:

| Nơi xuất phát | Khi dùng lối vào phòng họp | Khi dùng lối vào phòng chế tạo |
|---|---|---|
| Map13 (Văn phòng Wanderer) | Tới Map61 (Phòng họp) | Tới Map63 (Phòng chế tạo) |
| Map38 (Văn phòng Wanderer trong tiệc Giáng sinh) | Tới Map62 (Phòng họp Movie Night) | Tới Map63 (Phòng chế tạo) |
| Map39 (Văn phòng Wanderer vào sáng hôm sau) | Tới Map61 (Phòng họp) | Tới Map63 (Phòng chế tạo) |
| Map48 (Bản văn phòng của route mì cay) | Tới Map62 (Phòng họp Movie Night) | Tới Map63 (Phòng chế tạo) |
| Map50 (Văn phòng sau route sách Shylvie) | Tới Map61 (Phòng họp) | Tới Map63 (Phòng chế tạo) |
| Map52 (Văn phòng sau route sách Hakase) | Tới Map61 (Phòng họp) | Tới Map63 (Phòng chế tạo) |
| Map54 (Văn phòng trong cảnh đi tìm Hải Quỳ) | Tới Map62 (Phòng họp Movie Night) | Tới Map63 (Phòng chế tạo) |

Map61 (Phòng họp) và Map62 (Phòng họp Movie Night) phải có va chạm khớp hình nền, vị trí vào không đè lên lối ra và có thể quay lại đúng nơi xuất phát.

Map63 (Phòng chế tạo) có đầy đủ các nhóm tương tác về bàn chế tạo, máy móc, thùng thiết bị, xác sinh vật dị biến, dụng cụ phẫu thuật, Nethervoid và tháp dò tín hiệu. Vật thể kéo dài nhiều ô vẫn phải dùng chung một mạch hội thoại, không phát lại như nhiều vật khác nhau.

### 6.7. Map38 (Văn phòng Wanderer trong tiệc Giáng sinh)

Web app cần có trang riêng cho từng route đi vào Map38 (Văn phòng Wanderer trong tiệc Giáng sinh), vì đây là điểm hội tụ dễ phát nhầm nội dung:

| Route đi vào | Điều phải đúng |
|---|---|
| Quà siêu thị | Món và người nhận đã chọn được giữ nguyên; phần tự do dẫn tới cảnh trao đúng quà. |
| Mì cay | Nồi mì và nhánh người nấu đúng; chọn tiếp tục dẫn tới cảnh mì cay. |
| Sách dịch chuyển | Hải Quỳ tới muộn, không phát lại cảnh chuẩn bị tiệc; tiếp tục dẫn tới cảnh tặng Shylvie. |
| Sách Ma Vương Cổ Đại | Tiếp tục dẫn tới cảnh tặng Hakase. |
| Ba nhánh hỏi Leo | Mỗi cửa hàng giữ đúng quà/người nhận; không cùng dẫn về một cảnh. |
| Bốn nhánh hỏi Shylvie | Mỗi loại đá giữ đúng người nhận, hiệu ứng của đá và đoạn sau bữa tiệc. |

Trong thời gian khám phá tự do, người chơi phải vào được nhà bếp, năm phòng riêng, phòng họp, phòng chế tạo và có thể thách đấu ném tuyết với Shylvie, Kohi, Leo và Hakase. Chọn chưa tiếp tục phải trả quyền đi lại; chọn tiếp tục chỉ chạy cảnh một lần.

## 7. Nội dung Minigame

### 7.1. Ném tuyết

#### Cách người chơi mở minigame

Trong phần khám phá tự do tại Map38 (Văn phòng Wanderer trong tiệc Giáng sinh), nói chuyện với Shylvie, Kohi, Leo hoặc Hakase và chọn chơi ném tuyết.

#### Luật phải giải thích trên web app

- Khi đối thủ ném, nhìn hướng trên quả cầu tuyết và bấm phím mũi tên tương ứng khi bóng sắp chạm Hải Quỳ.
- Sau khi phòng thủ, làm theo hướng dẫn phản công riêng của từng đối thủ.
- Người chơi có thể thắng, thua hoặc chủ động dừng trận rồi quay về bữa tiệc.

#### Hành vi chung đúng

- Thanh máu, lượt, Perfect, Miss và sát thương cập nhật rõ ràng.
- Hình tấn công/phòng thủ dùng đúng thứ tự nhân vật: Shylvie, Leo, Hakase, Kohi.
- Hình đứng chờ và biến thể đứng chờ không bị tráo nhân vật.
- Người cổ vũ đứng trên bục cao, ngoài sân ném tuyết và giữ kích thước nhân vật bình thường.
- Khi kết thúc, toàn bộ tuyết, nhân vật, giao diện và âm thanh của minigame biến mất trước khi quay về bữa tiệc.
- Kết quả thắng từng người được ghi nhớ; thắng lại một người không xóa kết quả của những người khác.

#### Nội dung riêng từng đối thủ

| Đối thủ | Điều cần quan sát |
|---|---|
| Shylvie | Nhịp tấn công, phản công, hình nhân vật và hai kết quả thắng/thua đều đúng Shylvie. |
| Kohi | Cơ chế nhập chuỗi theo tỷ lệ hoàn thành chỉ xuất hiện đúng ở phần của Kohi. |
| Leo | Hướng đòn và mũi tên dễ nhìn; hình tấn công/phòng thủ đúng của Leo. |
| Hakase | Mũi tên chỉ hướng đẩy ma lực luôn nhìn thấy; quỹ đạo, hình nhân vật và kết quả không bị lẫn Leo/Kohi. |

Mỗi đối thủ cần có nội dung web app riêng cho một lượt thắng và một lượt thua, vì finisher và phản ứng sau trận khác nhau.

### 7.2. Câu tôm lấy cà phê Atlantis

#### Cách mở

Trong Map40 (Chuyến xuống Atlantis lấy cà phê), chọn đi câu tôm thay vì dùng cà phê thường.

#### Luật phải giải thích

- Z dùng để thả mồi, kéo dây hoặc bắn beam tùy dụng cụ.
- Shift đổi giữa cần câu và găng tay của Hải Quỳ.
- X/Esc rời minigame.
- Chỉ kéo tôm lên khi nó chuyển vàng.

#### Diễn biến đúng

| Tình huống | Kết quả đúng |
|---|---|
| Kéo tôm còn đen | Hải Quỳ thả nó trở lại biển; không tăng số cà phê. |
| Kéo đúng lúc tôm vàng | Tôm nhả cà phê Atlantis và bộ đếm tăng một. |
| Kéo quá muộn | Tôm đỏ rồi phát nổ; không được tính là bắt thành công. |
| Tôm giằng dây | Người chơi làm theo hướng hiển thị; sai hoặc chậm thì tôm thoát. |
| Dùng găng tay | Beam có cảnh báo, hoạt động trong vùng rõ ràng, sau đó cần thời gian hồi. |
| Thoát trước khi đủ mười | Quay lại lựa chọn, route chưa được coi là có cà phê Atlantis. |
| Đủ mười | Game báo đã đủ, cho phép quay lại quán và tiếp tục route. |

Sau khi rời minigame, không còn cá, tôm, cần câu, beam, chữ hướng dẫn hoặc âm thanh của minigame trên map chính.

### 7.3. Rượt đuổi ở Atlantis

#### Cách mở

Hoàn thành Map34 (Vòng vây clone) để chuyển sang Map29 (Hành lang rượt đuổi ở Atlantis).

#### Luật phải giải thích

- Hải Quỳ tự chạy xuống.
- Khi clone cản đường, nhập đủ chuỗi ba phím được hiện trên màn hình.
- Các phím có thể xuất hiện là Z, X, Shift, mũi tên lên và mũi tên xuống.
- Nhập sai hoặc hết giờ làm mức nguy hiểm tăng.
- Bị lỗi bốn lần dẫn tới Game Over.
- Muốn thoát thành công phải sống sót đủ thời gian và đã gặp đủ cả 11 clone.

#### Hình ảnh và hành vi đúng

- Camera theo Hải Quỳ liên tục.
- Quái vật chạy cùng hướng xuống, ở phía trên Hải Quỳ và ngày càng gần hơn nhưng không vượt qua cô.
- Quái vật không bị phần giao diện phía trên che mất thân chính.
- Nhập đúng làm Hải Quỳ đánh văng clone.
- Trong một lượt hoàn chỉnh, cả 11 clone khác nhau đều xuất hiện trước khi bất kỳ clone nào được dùng lại.
- Cuộc rượt đuổi không kết thúc trước 60 giây hoặc trước khi đủ 11 lần cản đường.
- Khi thắng, giao diện và clone được dọn sạch rồi mới chuyển sang Map25 (Đối đầu quái vật Vực Sâu).
- Khi thua, Game Over xuất hiện sạch, không giữ giao diện rượt đuổi.

Web app cần tách hai cách bắt đầu để phát hiện lỗi từng xảy ra: vào thẳng Map29 (Hành lang rượt đuổi ở Atlantis), và đi đúng từ Map34 (Vòng vây clone) sang Map29. Hai trường hợp phải cho cùng chuyển động camera và quái vật.

### 7.4. Game bắn phi thuyền trong siêu thị

Người chơi mở game tại Map19 (Siêu thị). Web app mô tả cách điều khiển dựa trên hướng dẫn có trong minigame, yêu cầu thử hoàn thành và thử thua/thoát. Sau khi quay lại siêu thị, giao diện và điều khiển của trò bắn phi thuyền phải biến mất. Khi đạt đủ điểm yêu cầu, phần thưởng biến hình phải được mở đúng một lần.

### 7.5. Vuốt mèo trong siêu thị

Người chơi mở trò vuốt mèo tại Map19 (Siêu thị), thử tương tác và thoát. Game phải quay lại đúng vị trí trong siêu thị, không crash và không giữ hình bàn tay/mèo trên màn hình. Nếu bản cuối yêu cầu điểm số hoặc phần thưởng, web app cần bổ sung kết quả mong đợi; hiện tại nội dung chính chỉ yêu cầu minigame mở và đóng ổn định.

### 7.6. Xem TV dẫn tới bad ending

Nội dung này được đặt trong nhóm minigame/phân đoạn đặc biệt nhưng liên kết tới trang Map42 (Phòng Hải Quỳ ở văn phòng Wanderer). Web app mô tả chuỗi chín màn hình TV, nhịp tối–đổi hình–sáng và bad ending “Thêm tập nữa thôi!” như phần Map tương tác ở trên.

## 8. Nội dung dùng chung cần web app nhắc người chơi quan sát

### 8.1. Hình ảnh và Gallery

Khi một CG xuất hiện lần đầu, người chơi phải nhận thông báo đã mở khóa CG. Ảnh sau đó xem được trong Gallery và vẫn còn sau khi lưu rồi tải game.

Web app cần có thư viện tham chiếu bằng thumbnail cho:

- CG1 đến CG24.
- Album 1 đến Album 4.
- Các trang nhật ký và lá thư.
- Ảnh vật phẩm xuất hiện trong game, gồm áo khoác, khăn, găng tay, cà phê, đá quý, dụng cụ phá khóa, dao/chảo, máy ép cam, máy pha cà phê, mì, váy, khiên, kiếm, thú bông và các món còn lại trong thư viện ảnh của game.

Thumbnail chỉ dùng để người chơi đối chiếu đúng/sai. Web app không tiết lộ ảnh chưa tới nếu người quản lý bật chế độ tránh spoiler.

Khi đang hiện ảnh toàn màn hình, hộp thoại phải là thoại bình thường và không có mũi tên chỉ vào nhân vật phía sau ảnh. Đóng ảnh phải xóa nó khỏi màn hình trước khi tiếp tục.

### 8.2. Khuôn mặt và biểu cảm

Web app không yêu cầu tester biết tên file khuôn mặt. Thay vào đó, mỗi scene mô tả người đang nói và cảm xúc dễ nhận ra: bình thường, ngạc nhiên, tức giận, buồn, cười hoặc ngượng.

Người chơi báo lỗi khi:

- Ảnh khuôn mặt thuộc nhân vật khác.
- Nhân vật đang hét nhưng khuôn mặt vẫn bình thản dù scene có biểu cảm phù hợp.
- Tiếng phát từ máy móc hoặc đầu đĩa lại dùng khuôn mặt Hải Quỳ.
- Một câu suy nghĩ bị gắn thành lời nói của nhân vật đứng trên map.

### 8.3. Chuyển cảnh, ánh sáng và camera

Mô tả chung trên mọi trang:

- Cảnh tối phải tối dần mượt mà.
- Map mới không được lóe sáng trước khi được làm tối.
- Khi cần nhìn nhân vật, nguồn sáng phải nằm đúng Hải Quỳ/Paulie thay vì lệch sang ô khác.
- Khi phần tự do bắt đầu, người chơi phải nhìn thấy map và điều khiển được Hải Quỳ.
- Camera không được bỏ Hải Quỳ ngoài màn hình, nhảy bất ngờ hoặc giữ vị trí của scene trước.
- Sau rung, zoom hoặc làm mờ, hình ảnh phải trở lại trạng thái phù hợp cho scene kế tiếp.

### 8.4. Khả năng chơi tiếp

Mọi route và scene đều cần nút “Tôi bị kẹt” trong web app. Phần trợ giúp yêu cầu người chơi thử:

1. Chờ vài giây xem hội thoại hoặc chuyển động còn tiếp tục không.
2. Thử phím xác nhận và phím hủy một lần.
3. Ghi lại map, câu thoại cuối cùng và lựa chọn gần nhất.
4. Chụp màn hình trước khi đóng game.
5. Gửi save gần nhất nếu lỗi có thể tái hiện.

Các biểu hiện phải báo ngay gồm màn hình đen vĩnh viễn, nhân vật không thể đi lại sau cutscene, cảnh tự lặp, chọn một route nhưng sang route khác, hoặc cửa ra không hoạt động.

## 9. Theo dõi tiến độ trên web app

Trang tiến độ cần hiển thị các số liệu sau bằng tên dễ hiểu:

| Nhóm | Cách tính |
|---|---|
| Route đã hoàn thành | Số đường chơi đã đi từ đầu nhánh tới ending |
| Scene đã xem | Số cảnh đã xác nhận có diễn biến đúng |
| Map đã khám phá | Số địa điểm đã thử đủ các nhóm tương tác |
| Minigame đã thử | Số minigame đã thử cả kết quả thành công và thất bại/thoát |
| Lỗi chưa xử lý | Báo cáo đang chờ đội phát triển xác nhận |
| Nội dung cần thử lại | Những phần từng lỗi nhưng đã có build sửa mới |

Phạm vi route của phiên bản hoàn chỉnh gồm:

| Nhóm route | Số đường chơi cần theo dõi |
|---|---:|
| Mua quà tại siêu thị | 20 |
| Mua mì cay cho Leo | 2 |
| Hỏi Leo rồi chọn cửa hàng | 3 |
| Hỏi Shylvie rồi mua đá phong thủy | 4 |
| Mua sách phép tại Atlantis | 2 |
| Nói chuyện với chủ tiệm sách trước | 1 |
| Phòng kho, ký ức và rượt đuổi cùng Paulie | 1 |
| Tổng cộng | 33 |

Route siêu thị phải hiển thị riêng 20 đường kiểm tra: 12 tổ hợp của ba món bộ phá khóa, dao/chảo, khăn len và 8 trường hợp máy pha cà phê do mỗi người nhận có cả cà phê thường lẫn cà phê Atlantis.

Route hỏi Shylvie phải hiển thị đủ bốn nhánh ngay từ phiên bản đầu của web app và được tính vào phạm vi test của bản game hoàn chỉnh.

Một nội dung chỉ được tính là hoàn thành khi người chơi đã tới điểm kết thúc được mô tả. Việc chỉ mở trang hoặc chỉ bắt đầu route không được tính là đã test xong.

## 10. Bộ lọc và tìm kiếm

Web app cần cho phép lọc theo:

- Nhân vật nhận quà: Leo, Kohi, Shylvie, Hakase.
- Nơi bắt đầu: siêu thị, văn phòng Wanderer, Atlantis, tiệm mì cay.
- Loại nội dung: route, scene, map tương tác, minigame.
- Trạng thái test.
- Phiên bản game.
- Nội dung có lỗi chưa xử lý.
- Nội dung cần file save riêng để bắt đầu nhanh.

Tìm kiếm `Shylvie` phải trả về cả route tặng quà cho Shylvie, route hỏi Shylvie, Map43 (Phòng Shylvie), trận ném tuyết với Shylvie và các scene Shylvie tham gia.

Tìm kiếm số map, chẳng hạn `43`, cũng phải trả về `Map43 (Phòng Shylvie)`.

## 11. Chế độ tránh spoiler

Web app nên có hai chế độ:

| Chế độ | Cách hiển thị |
|---|---|
| Hướng dẫn đầy đủ | Hiện toàn bộ diễn biến đúng và các mốc ending |
| Hạn chế spoiler | Chỉ hiện bước cần làm tiếp theo; phần kết quả chi tiết được che cho tới khi người chơi xác nhận đã tới scene đó |

Tester chính có thể dùng hướng dẫn đầy đủ. Player tình nguyện nên mặc định dùng hạn chế spoiler để trải nghiệm game tự nhiên hơn nhưng vẫn có thể mở phần “Nếu đúng, bạn sẽ thấy” khi nghi ngờ lỗi.

## 12. Xuất báo cáo

Web app cần xuất được báo cáo theo phiên bản game, gồm:

- Route nào đã có người hoàn thành.
- Route nào chưa ai đi hết.
- Scene/map/minigame nào có nhiều lỗi nhất.
- Danh sách lỗi có ảnh, video và save đính kèm.
- Số người tái hiện được cùng một lỗi.
- Lỗi chỉ xảy ra khi đi đúng luồng dài, nhưng không xảy ra khi bắt đầu trực tiếp tại map.
- Các nội dung cần thử lại sau khi cập nhật build.

Báo cáo xuất ra phải dùng cùng tên thân thiện như trên giao diện, ví dụ `Map29 (Hành lang rượt đuổi ở Atlantis)`, để cả tester và đội phát triển cùng hiểu đang nói tới đâu.
