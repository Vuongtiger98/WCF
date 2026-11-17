# Bộ cập nhật game trên Windows

Trạng thái ngày 17/11/2026: đã có bộ cập nhật ngoài game, công cụ đóng gói và kiểm thử cục bộ. Đang chuẩn bị bản tester **0.1.0-test.1** theo yêu cầu tác giả; [ghi chú bản phát hành](releases/0.1.0-test.1.md). Thư mục `dist/` chứa kết quả đóng gói và được Git bỏ qua.

## Cách hoạt động

Người chơi đóng game rồi chạy `GameUpdate.bat` trong bản game đã giải nén. Máy cần Windows PowerShell 5.1 trở lên, kết nối HTTPS và quyền ghi vào thư mục game; không cần Git, GitHub CLI hoặc tài khoản GitHub.

Bộ cập nhật đọc Release đã công bố của `Vuongtiger98/WCF`, tìm file `wcf-update.json` và chọn phiên bản SemVer cao nhất trong 100 Release gần nhất. Nó không tải trực tiếp nhánh `master`, commit hoặc tag chưa có Release. Khi chưa có bản phù hợp, chương trình báo chưa có cập nhật và giữ nguyên game.

`gameupdate/config.json` đặt kênh:

- `tester` (mặc định): nhận Release chính thức và prerelease đã công bố.
- `stable`: chỉ nhận Release chính thức, bỏ qua prerelease.

Draft luôn bị bỏ qua. Phiên bản thấp hơn bản đã cài không được tự động cài đè. Cùng một phiên bản có thể sửa lại file bị thiếu hoặc hỏng.

Đây là bộ cập nhật bên ngoài game. Chưa thêm thông báo kiểm tra phiên bản trong menu RGSS3.

## Phạm vi file và dữ liệu người chơi

Các file chính thức được quản lý gồm `Game.exe`, `Game.ini`, DLL Khas, `Data/*.rvdata2`, tài nguyên ảnh/âm thanh/video, thư viện `System` và bản thân bộ cập nhật. Gói tải chia theo Data, System, từng nhóm Graphics/Audio và phần runtime. Chỉ nhóm có file khác bản cài đặt mới cần tải; sau khi xác minh, chỉ file khác hoặc thiếu được thay.

Manifest mô tả toàn bộ phiên bản đích. Vì vậy có thể cập nhật qua nhiều phiên bản, không cần lần lượt cài từng bản vá. File chính thức bị bỏ ở phiên bản mới chỉ được xóa nếu manifest đã cài trước đó xác nhận nó thuộc game. File lạ không tự động bị xóa. Mod trùng đường dẫn với file chính thức có thể được thay bằng bản chính thức.

Các dữ liệu sau không nằm trong gói cập nhật:

| Dữ liệu | Xử lý |
|---|---|
| `Save*.rvdata2` ở thư mục gốc | Giữ nguyên |
| Toàn bộ `Save/`, gồm gallery và thiết lập điện thoại | Giữ nguyên |
| `Graphics Settings.cfg` | Giữ thiết lập KUL của máy |
| `HaiQuy.txt` | Giữ cả trạng thái có hoặc không có file của Easter egg |
| `gameupdate/config.json` | Chỉ được cấp trong bản game đầy đủ; cập nhật giữ cấu hình hiện tại |
| Tài liệu, web app QA, script Ruby xuất rời, file nguồn ảnh, backup Data, `.git` | Không đóng gói |

Giữ save không có nghĩa mọi save đều tương thích. Tác giả có thể đánh dấu `requiresNewGame`; updater sẽ hiện yêu cầu chơi mới nhưng vẫn giữ save cũ. Cờ này chỉ thông báo, không tự đổi hoặc xóa dữ liệu save.

Không chạy updater trong thư mục làm việc RPG Maker: nó chủ động từ chối thư mục có `.git`, `Game.rvproj2` hoặc danh mục xuất script. Chỉ hỗ trợ bản game giải nén, không trộn với `Game.rgss3a`.

## Kiểm tra gói và phục hồi

Trước khi sửa game, updater tải vào thư mục tạm và đối chiếu kích thước, SHA-256 của ZIP lẫn từng file bên trong. Nó từ chối đường dẫn thoát thư mục, junction/symlink, file ngoài manifest và đường dẫn dữ liệu người chơi. Cơ chế này kiểm tra tính toàn vẹn theo manifest của Release; không có chữ ký số riêng cho dự án.

Updater kiểm tra game đang chạy và khóa phiên cập nhật để tránh hai tiến trình ghi cùng lúc. Mỗi lần áp dụng đều sao lưu các file sắp thay hoặc xóa vào `gameupdate/backups/txn-...`, ghi journal, rồi thay từng file bằng thao tác thay thế file. `installed.json` chỉ được cập nhật sau các file game.

Nếu ghi lỗi, updater cố phục hồi bản trước. Nếu tiến trình bị tắt giữa chừng, lần chạy kế tiếp phục hồi transaction còn dang dở trước, rồi yêu cầu chạy lại để tiếp tục kiểm tra bản mới. Cần đóng game trong lúc phục hồi. Đây là khả năng phục hồi từ journal, không phải bảo đảm tuyệt đối trước hỏng ổ đĩa hoặc mất cả bản sao lưu.

Để quay lại lần cập nhật thành công gần nhất, mở PowerShell ở thư mục **bản game** và chạy:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\gameupdate\Update.ps1 -Rollback
```

Nhật ký nằm ở `gameupdate/update.log`. Backup hiện được giữ lại, chưa tự dọn. Không xóa `backups`, `pending.json` khi đang cập nhật hoặc còn yêu cầu phục hồi. Xóa backup cũng làm mất khả năng quay lại transaction tương ứng.

## Đóng gói trên máy tác giả

Từ thư mục dự án:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Build-Update.ps1 `
  -Version 0.1.0-test.1 `
  -RequiresNewGame `
  -Notes 'Ghi chu cac thay doi can tester kiem tra'
```

Chọn phiên bản SemVer mới cho mỗi bản sẽ công bố. Bỏ `-RequiresNewGame` khi bản sửa tương thích save. `-SourceDirectory` và `-OutputDirectory` cho phép chỉ định nguồn/đích khác. Công cụ từ chối ghi đè thư mục build đã có.

Kết quả mặc định:

```text
dist/wcf-0.1.0-test.1/
  game/                         Bản game giải nén có GameUpdate.bat
  release/
    wcf-update.json             Manifest toàn bộ phiên bản đích
    wcf-core.zip                Runtime và updater
    wcf-data.zip                Database và map
    wcf-graphics-*.zip          Các nhóm ảnh có trong game
    wcf-audio-*.zip             Các nhóm âm thanh có trong game
    wcf-system.zip             Thư viện runtime
    wcf-game-0.1.0-test.1.zip    Bản đầy đủ cho lần tải đầu
    wcf-updater-bootstrap.zip  Thêm updater vào bản game cũ chưa có updater
  build-report.json             Báo cáo build, không phát cho người chơi
```

Các nhóm rỗng không tạo ZIP. Bản đầy đủ chứa config và manifest đã cài. Gói bootstrap chỉ chứa launcher, hai script updater và config; dùng một lần để thêm bộ cập nhật vào bản game giải nén cũ. Bộ cập nhật chỉ dùng các ZIP nhóm, không tải lại ZIP game đầy đủ.

Build lấy đúng trạng thái file đang có, kể cả sửa đổi chưa commit; `sourceCommit` và `sourceDirty` ghi rõ điều đó. Nó không export/repack script, dựng lại map, thay tọa độ event, chỉnh BGM hoặc cập nhật web app. Nên đóng RPG Maker hoặc ngừng lưu project trong lúc build để nguồn không thay đổi giữa các lần đọc.

`Game.ini` hiện vẫn có `RTP=RPGVXAce`. Công cụ không thu gom RTP từ máy tác giả; bản đóng gói này vẫn yêu cầu RTP RPG Maker VX Ace. Đây chưa phải bản phát hành độc lập với RTP.

Khi được yêu cầu phát hành sau này: review nội dung bản build, playtest, rồi tạo Release có tag khớp `v<version>` và đính kèm manifest cùng **đầy đủ các ZIP nhóm** của đúng một build. Các file này cần có đủ trong từng Release để người chơi ở bất kỳ phiên bản trước nào cũng cập nhật được. Có thể đính kèm thêm ZIP game đầy đủ cho người tải lần đầu. Hiện chưa thực hiện bước này.

## Kiểm tra cục bộ, không công bố

Kiểm tra có bản cập nhật từ GitHub, không áp dụng bản mới:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\gameupdate\Update.ps1 -CheckOnly
```

Áp dụng hoặc kiểm tra một build cục bộ vào **bản game thử riêng**:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\gameupdate\Update.ps1 `
  -PackageDirectory 'D:\duong-dan\dist\wcf-0.1.0-test.2\release' -CheckOnly
```

Bỏ `-CheckOnly` để thực sự áp dụng gói cục bộ. `-CheckOnly` không áp dụng phiên bản mới, nhưng vẫn ghi log/lock; nếu có transaction dở từ lần chạy trước, updater vẫn phục hồi trước khi làm việc khác.

Bộ thử tự động:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Test-GameUpdate.ps1
pwsh -NoProfile -File .\tools\Test-GameUpdate.ps1
```

Các fixture ở `Save/UpdaterQA/<id>/` chứa game giả và kết quả riêng; không dùng save thật, không cần GitHub hoặc chạy game. Bộ thử kiểm tra: build độc lập; tên Unicode và ký tự đặc biệt; giữ dữ liệu người chơi; chỉ tải nhóm thay đổi; xóa file cũ có quản lý; chống hạ phiên bản; rollback thủ công/tự động; gói hỏng; đường dẫn nguy hiểm/junction; khóa file; game đang chạy (tiến trình giả cục bộ); chạy trùng updater; thứ tự SemVer/kênh Release; ngắt tiến trình giữa lần ghi; tự cập nhật updater. Kết quả từng lượt nằm trong `results.json` của fixture.

Tải asset từ một Release thật chưa thể kiểm thử đầy đủ trước khi có Release. Bộ thử cục bộ xác minh cùng đường giải nén/kiểm tra/áp dụng/phục hồi, còn lần kiểm tra GitHub hiện chỉ xác minh trường hợp chưa có bản công bố.

Kết quả xác minh ngày 17/11/2026:

- 60 kiểm tra đạt trên Windows PowerShell `5.1.26100.9818` và 60 kiểm tra đạt trên PowerShell `7.6.10`.
- Build cục bộ `dist/wcf-0.1.0-preview.1`: 1.097 file runtime, gồm đủ 79 file Data gốc, chia thành 26 gói cập nhật.
- Đã giải nén/xác minh cả 26 gói; đối chiếu SHA-256 với nguồn và kiểm tra đủ 1.099 entry trong ZIP game đầy đủ (thêm config và manifest đã cài).
- Kiểm tra repo GitHub thật trả về chưa có Release phù hợp; đối chiếu sau đó xác nhận 1.097 file game giữ nguyên.
- Audit nguồn xác nhận thứ tự 222 script và các map vẫn giữ nguyên; updater không thay dữ liệu game trong dự án.

Bản preview chứa những sửa đổi game đang có trên máy, có `sourceDirty=true`; đây chỉ là kiểm tra đóng gói, không phải xác nhận toàn bộ nội dung game đã sẵn sàng phát hành.

## File triển khai

| File | Vai trò |
|---|---|
| `GameUpdate.bat` | Điểm chạy cho người chơi bằng Windows PowerShell |
| `gameupdate/Update.ps1` | Chạy module qua bản sao tạm để có thể tự cập nhật |
| `gameupdate/WcfUpdater.psm1` | Chọn Release, kiểm tra gói, áp dụng và phục hồi |
| `gameupdate/config.json` | Repo và kênh cập nhật |
| `tools/Build-Update.ps1` | Tạo game giải nén, ZIP đầy đủ và ZIP cập nhật |
| `tools/Test-GameUpdate.ps1` | Kiểm thử độc lập với game/save thật |
