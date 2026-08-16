# Sơ đồ route

File này lưu mã Mermaid dùng để kiểm tra cấu trúc route. Nội dung chi tiết và quy tắc triển khai nằm trong [04-route-map.md](./04-route-map.md).

## Cây route tổng thể

```mermaid
flowchart TD
    START["Cảnh 1–3 dùng chung<br/>Silver Wing → tin nhắn Wanderer → xe buýt"]
    START --> CHOICE{"Hướng chuẩn bị quà"}

    CHOICE --> MARKET["Siêu thị Mega Galaxy Central"]
    CHOICE --> NOODLE["Mua mì cay cho Leo"]
    CHOICE --> OFFICE["Ghé Wanderer Office hỏi ý kiến"]
    CHOICE --> ATLANTIS["Xuống Atlantis mua sách phép"]

    MARKET --> ITEM{"Chọn món quà"}
    ITEM --> LOCK["Bộ phá khóa"]
    ITEM --> COOK["Dao và chảo"]
    ITEM --> SCARF["Khăn len/bộ đan len"]
    ITEM --> MACHINE["Máy pha cà phê"]
    LOCK --> R1{"Leo / Kohi / Shylvie / Hakase"}
    COOK --> R2{"Leo / Kohi / Shylvie / Hakase"}
    SCARF --> R3{"Leo / Kohi / Shylvie / Hakase"}
    MACHINE --> R4{"Leo / Kohi / Shylvie / Hakase"}

    NOODLE --> TRUST{"Tin Aira?"}
    TRUST -->|Có| AIRA["Aira chọn nguyên liệu và nấu"]
    TRUST -->|Không| HQ["Hải Quỳ phân tích công thức và tự nấu"]
    AIRA --> FIXED["Người nhận: Leo"]
    HQ --> FIXED

    OFFICE --> TALK{"Hỏi Leo hay Shylvie?"}
    TALK --> LEO["Leo giới thiệu cửa hàng"]
    TALK --> SHYLVIE["Shylvie giới thiệu tiệm đá"]
    LEO --> LSHOP{"Chọn cửa hàng"}
    LSHOP --> MAGIC["Dụng cụ ma pháp<br/>Áo choàng tàng hình → Hakase"]
    LSHOP --> CAFE["Cửa hàng cà phê<br/>Cà phê đặc biệt → Kohi"]
    LSHOP --> WEAPON["Cửa hàng vũ khí<br/>Khiên → Shylvie"]
    SHYLVIE --> GEM{"Chọn người nhận"}
    GEM --> GP["Purple Garnet → Leo"]
    GEM --> GD["Kim cương hạt cà phê → Kohi"]
    GEM --> GC["Congo Tourmaline → Shylvie"]
    GEM --> GF["Rainbow Fluorite → Hakase"]

    ATLANTIS --> OWNER{"Nói với chủ tiệm trước khi tìm sách?"}
    OWNER -->|Không| BOOK{"Chọn sách"}
    BOOK --> ANCIENT["Ma Vương Cổ Đại → Hakase"]
    BOOK --> TELEPORT["Dịch chuyển nâng cao → Shylvie"]
    OWNER -->|Có| ABYSS["Tạo vật Vực Sâu phát nổ"]
    ABYSS --> SPECIAL["Nhóm Wanderer giải cứu Hải Quỳ<br/>Kết thúc đặc biệt"]

    R1 --> PARTY["Tiệc Giáng sinh"]
    R2 --> PARTY
    R3 --> PARTY
    R4 --> PARTY
    FIXED --> PARTY
    MAGIC --> PARTY
    CAFE --> PARTY
    WEAPON --> PARTY
    GP --> PARTY
    GD --> PARTY
    GC --> PARTY
    GF --> PARTY
    ANCIENT --> PARTY
    TELEPORT --> PARTY
    PARTY --> GIFTS["Vòng trao quà theo route"]
    GIFTS --> CALL["Silver Wing gọi khẩn"]
    CALL --> LEAVE["Omega D-13 rời tiệc"]
    LEAVE --> EPILOGUE["Epilogue theo món quà/người nhận"]
```

## Luồng scene tiêu chuẩn

```mermaid
flowchart LR
    S1["Cảnh 1<br/>Silver Wing"] -->
    S2["Cảnh 2<br/>Tin nhắn Wanderer"] -->
    S3["Cảnh 3<br/>Chọn hướng"] -->
    BRANCH["Cảnh nhánh<br/>tìm và chuẩn bị quà"] -->
    PARTY["Tiệc Giáng sinh"] -->
    GIFT["Vòng trao quà"] -->
    CALL["Cuộc gọi Silver Wing"] -->
    DEPART["Hải Quỳ rời tiệc"] -->
    END["Epilogue/ending"]
```

## Nhánh Atlantis đặc biệt

```mermaid
flowchart LR
    SHOP["Tiệm sách Atlantis"] --> TALK["Nói chuyện với chủ tiệm trước"]
    TALK --> BOX["Nhận hộp bà chủ cũ để lại"]
    BOX --> EXPLODE["Sách Vực Sâu phát nổ và nhập vào Hải Quỳ/Aira"]
    EXPLODE --> SEAL["Tự phong ấn"]
    SEAL --> TRACE["Wanderer dò ma lực từ băng đạn"]
    TRACE --> RESCUE["Hakase học Oblivion Blast"]
    RESCUE --> EXORCISE["Trục xuất Quái Vật Vực Sâu"]
    EXORCISE --> END["Kết thúc đặc biệt"]
```

