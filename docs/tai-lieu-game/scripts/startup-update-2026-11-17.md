# Kiểm tra cập nhật khi mở game — 17/11/2026

## Luồng người chơi

1. Chạy `Game.exe`: trước Title hiện màn hình “Đang kiểm tra phiên bản”.
2. Kiểm tra Release theo kênh trong `gameupdate/config.json`. Không có bản mới, lỗi kết nối hoặc quá thời gian chờ thì tiếp tục vào game.
3. Có phiên bản mới: hiện số phiên bản và “vui lòng chờ cập nhật”. Game chỉ thoát sau khi cửa sổ updater báo đã sẵn sàng.
4. Updater đợi tiến trình game cũ đóng, tải/kiểm tra/cài gói trong tiến trình riêng. Cửa sổ tiếng Việt hiển thị giai đoạn và số gói/file đã xử lý.
5. Thành công: tự mở lại game. Một biến môi trường chỉ truyền cho lần mở này bỏ qua kiểm tra một lần rồi được xóa; không tạo vòng lặp restart.
6. Thất bại: có “Thử lại”; chỉ cho “Chơi bản hiện tại” khi không có transaction đang chờ phục hồi. Khi cần phục hồi, nút còn lại chỉ đóng cửa sổ.

`GameUpdate.bat` vẫn dùng được để cập nhật/kiểm tra sửa file thủ công. Bản `0.1.0-test.2` có thể nhận tính năng bằng một lần chạy BAT; không thêm tên file managed mới nên không cần thay bootstrap chỉ vì tính năng này.

## Thành phần

| Thành phần | Vai trò |
|---|---|
| `Scripts/Main.rb`, slot 220 | `WCFStartupUpdate` vẽ màn hình chờ, gọi helper và đọc trạng thái cục bộ trước `SceneManager.run` |
| `Update.ps1 -StartupMode Check` | Tiến trình ẩn so phiên bản, ghi kết quả dạng dòng ngắn để Ruby không cần thư viện JSON |
| `Update.ps1 -StartupMode Update` | Cửa sổ WinForms và điều phối đợi game đóng, gọi apply, mở lại game |
| `Update.ps1 -StartupMode Apply` | Tiến trình ẩn thực hiện cập nhật với callback tiến độ |
| `Get-WcfStartupVersion` | Chỉ đọc version đã cài/source floor và danh sách Release, không hash/quét toàn bộ game lúc khởi động |
| `Invoke-WcfUpdate -Progress` | Tái sử dụng xác minh gói, transaction, backup và rollback hiện tại |

Mọi code vẫn ở các file đã có trong manifest của bản 0.1.0-test.2. Main giữ nguyên slot/ID; không thêm hoặc sắp xếp lại Script Editor. 222 slot và 221 dòng CSV không đổi. Chỉ `Main` và `Data/Scripts.rvdata2` đổi trong nhóm Data/script RGSS; không sửa map hoặc event.

## Thời gian chờ và phiên bản

- API startup có timeout 4 giây. RGSS chờ tối đa 6 giây cho kết quả; khi hết hạn ghi cancel và vào Title.
- Màn hình chờ hiển thị ít nhất 5 giây (bổ sung ngày 19/11), kể cả API trả không có bản mới hoặc không có mạng. Thời gian đã chờ mạng được tính vào 5 giây, không chờ thêm 5 giây sau khi nhận kết quả.
- Sau thông báo bản mới, chờ ít nhất một giây và đủ thời gian hiển thị tối thiểu rồi mở helper. Nếu helper không báo sẵn sàng trong 6 giây, tiếp tục game và hủy phiên đó; không đóng game chỉ vì PowerShell đã được tạo process.
- Cửa sổ updater đợi game cũ thoát tối đa 20 giây; không cưỡng bức kill game.
- `WCFStartupUpdate::VERSION` là source floor (hiện `0.1.0-test.4`). So sánh dùng giá trị cao hơn giữa source floor và `installed.json` để không kéo code đang phát triển về Release cũ.
- Check chỉ chạy một lần mỗi tiến trình, không chạy lại khi trở về Title. Battle Test bỏ qua startup.
- Khi có `pending.json`, chuyển tới quy trình phục hồi trước khi chơi.

## Tiến trình, file và hiệu năng

Không chạy HTTP đồng bộ trong RGSS. Main chỉ đọc file nhỏ; nền/chữ chỉ vẽ lại khi nội dung đổi. Helper dùng Windows PowerShell/WinForms và child process riêng; tải mạng/cài file không khóa vòng lặp giao diện updater.

Session tạm ở `gameupdate/startup-<pid>-<time>-<random>/`. Check và GUI dọn các file phẳng của đúng session, không xóa đệ quy vào thư mục con bất ngờ. Không đóng gói session, log hoặc dữ liệu người chơi. Nhật ký lỗi chính ở `gameupdate/update.log`.

Helper tự sao chép script/module vào thư mục tạm trước khi thay updater. Đường dẫn mở process dùng API/.NET với working directory literal, tránh lỗi PowerShell coi dấu `[]` là wildcard. SHA-256 dùng .NET trực tiếp, không phụ thuộc việc `Get-FileHash` có được nạp trong PowerShell 32-bit hay không.

## Kiểm tra đã thực hiện

- `tools/test_startup_update.rb`: 10 case / 35 assertion, gồm offline, timeout, helper không phản hồi/sẵn sàng, handoff đúng một lần, bỏ qua sau restart và Battle Test.
- `tools/Test-StartupUpdate.ps1`: 12 kiểm tra version, IPC, hủy phiên, phục hồi và apply gói cục bộ giữ save. Khóa file Scripts trong ca version check để xác minh startup không đọc/hash file đó.
- `tools/Test-GameUpdate.ps1`: 60 kiểm tra đạt sau thay đổi callback/loader; sửa lời gọi fixture cũ để kiểm tra thư mục dự án được chấp nhận qua đúng hàm nội bộ.
- Native RGSS: `Save/StartupNativeQA_20261117_[5] space!/`. Trạng thái bản mới được giả lập để đi vào nhánh update; gói lấy từ fixture cục bộ. Game thật gọi ShellExecuteW, chờ ready, thoát; WinForms/PowerShell thật cài Core/Data và mở lại Game.exe. `native-result.marshal` có `result=false, ready=true`; `native-restarted.marshal` có `skip_received=true, skip_consumed=true, result=true`.
- Native kiểm tra thật trong sandbox nhận `offline` và tiếp tục game. Gọi API công khai ngoài sandbox cũng trả đúng latest `0.1.0-test.2` thấp hơn source floor `0.1.0-test.3`, không tải gói/cài file.
- Đã xem `startup-20.png`, `updater-1.png`, `updater-2.png` từ renderer RGSS/WinForms thật. Không dùng thao tác chuột/phím vật lý và không suy ra FPS game từ fixture này.
- Lượt fixture có ký tự `ộ` trong đường dẫn bị chính Game.exe từ chối nạp RGSS DLL trước khi chạy script; lượt được chấp nhận dùng đường dẫn ASCII với khoảng trắng, `[]` và `!`. Không coi lỗi loader đó là lỗi startup script hoặc tuyên bố đã xác minh game chạy được ở mọi đường dẫn Unicode.

Backup: `Data/codex_backup_startup_update_20261117/`. Các case native trước lượt `[5]` là lượt điều tra, không dùng làm bằng chứng đạt toàn luồng.

## Giao diện alien — 18/11/2026

- Cả màn hình kiểm tra trong RGSS và cửa sổ tải/cài WinForms dùng năm ảnh `Graphics/Invaders/alien0.png` đến `alien4.png`. Đây là năm PNG đơn 50×50; không gọi logic của minigame Invaders.
- Alien nhún lên xuống, co giãn nhẹ và nghiêng luân phiên theo cùng chu kỳ 40 frame quy đổi 60 fps (90 nhịp/phút). Đây là nhịp hình ảnh, không thêm nhạc hoặc âm thanh.
- Thanh bo tròn màu pastel chạy qua lại khi đang kiểm tra/chưa biết tổng số. Khi tải/cài có số lượng thật, thanh mới hiển thị tiến độ tương ứng; không giả lập phần trăm kiểm tra phiên bản.
- RGSS cập nhật sprite mỗi frame, thanh mỗi ba frame; WinForms dùng timer 50 ms và panel double-buffer. Ảnh/brush nạp một lần, không đọc PNG trên từng frame. RGSS chỉ giải phóng sprite và bitmap do màn hình tự tạo, giữ bitmap chung trong Cache; WinForms clone ảnh vào bộ nhớ để không khóa file khi cập nhật rồi giải phóng khi đóng.
- Giữ nguyên timeout/offline, handoff, tải/cài, retry và restart. Không sửa map/event, dữ liệu save hoặc vị trí/thứ tự các script.

Xác minh bản giao diện: `tools/test_startup_update.rb` đạt 10 case / 35 assertion; inventory đạt 222 slot / 221 dòng CSV, không lệch token giữa runtime/export. So với backup `Data/codex_backup_startup_aliens_20261118/`, trong Data/script chỉ Main và pack Scripts thay đổi; mọi slot ngoài Main giữ nguyên cả ID, tên, thứ tự và source.

Fixture `Save/StartupAliensQA_20261118/` chạy Game.exe/RGSS, ShellExecuteW, WinForms và apply gói cục bộ thật; trạng thái có bản mới được giả lập. Đã xem ảnh `startup-10.png`, `startup-30.png`, `updater-1.png`, `updater-2.png`, xác nhận các tư thế khác nhau và đủ năm alien. Kết quả handoff/restart đạt như lượt native trước; `scope.json` lưu kết quả đối chiếu. Không dùng lượt này để suy ra FPS toàn game hoặc xác minh cập nhật công khai qua Internet.

## Thời gian tối thiểu — 19/11/2026

`MIN_DISPLAY_TIME=5.0` chỉ điều khiển thời gian trình bày, không kéo dài timeout API hoặc dùng sleep khóa RGSS. Vòng lặp tiếp tục cập nhật alien/thanh loading. Không có bản mới: thông báo đã ở phiên bản mới nhất trong thời gian còn lại; lỗi kết nối: tiếp tục vào game sau thời gian tối thiểu. Helper check không khởi động được cũng giữ màn hình 5 giây. Sau khi updater mở lại game vẫn bỏ qua check một lần; Battle Test và lượt trở về Title trong cùng tiến trình không phải chờ lại.

`tools/test_startup_update.rb` hiện đạt 12 case / 44 assertion, gồm phản hồi sớm, offline, lỗi mở helper và phản hồi muộn sau 4,5 giây vẫn kết thúc ở khoảng 5 giây. Native fixture được chấp nhận: `Save/StartupMinimumQA_20261119_2/real-check/`, API thật trả `up-to-date`, thời gian `WCFStartupUpdate.run` đo được 5,093 giây rồi tiếp tục. Fixture dùng snapshot renderer và vòng cập nhật thay thế vì Graphics.update gốc dừng khi cửa sổ ẩn không có focus; không dùng lượt này để xác nhận FPS hay điều khiển game. Lượt đầu bị dừng bởi cơ chế focus này đã được đóng và không tính là kết quả đạt.

Backup: `Data/codex_backup_startup_minimum_20261119/`. Pack chỉ thay Main tại slot 220; giữ nguyên 222 slot, 221 dòng CSV, ID/thứ tự và mọi map/event.

## Tham khảo kỹ thuật

Main dùng [ShellExecuteW](https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutew) với working directory hiện tại và kiểm tra mã trả về trước khi chờ helper. Giao diện hệ thống dùng [Windows Forms Timer](https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.timer) để nhận tiến độ trong message loop, còn công việc tải/cài chạy ở process khác.
