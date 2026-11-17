# WCF updater

Chạy `GameUpdate.bat` trong bản game đã đóng gói, sau khi đóng game. Updater dùng Windows PowerShell 5.1, tải bản đã công bố từ GitHub Releases và giữ save/thiết lập người chơi.

Từ bản 0.1.0-test.3, mở `Game.exe` cũng tự kiểm tra phiên bản: có bản mới thì chờ cập nhật và tự mở lại game. BAT tiếp tục dùng cho lần nhận tính năng này và cập nhật thủ công. Không có mạng thì vẫn vào game.

Bản tester có `Game.rvproj2` để mở trong RPG Maker UI. Updater không chặn thư mục dự án, `.git` hoặc script xuất rời. Đóng game và RPG Maker trước khi cập nhật.

Hướng dẫn build, thử cục bộ, phục hồi và cấu hình kênh nằm ở [tài liệu bộ cập nhật](../docs/tai-lieu-game/production/game-updater.md). File README này dành cho người phát triển, không được đưa vào bản game đóng gói.
