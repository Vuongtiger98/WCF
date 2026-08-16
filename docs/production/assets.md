# Asset checklist

## Menu điện thoại và group chat

Các file được script tham chiếu trong `Graphics/PhoneMenu/` gồm nền điện thoại, icon item/save/load/settings/contacts/gallery, avatar contact, `Contact_WandererGroup`, `Cursor`, `Button`, `MessageBackground` và các ảnh hội thoại. Cần kiểm tra tồn tại thực tế trước khi đóng gói.

## Gallery

- `Graphics/Gallery/0`: thumbnail khóa.
- Gallery picture IDs 1–8 đã được khai báo trong Custom Menu.
- `Save/GlobalGallery.rvdata2`: dữ liệu unlock toàn cục, không phải asset.

## Map effects

- `Graphics/Layers/`: layer cho Galv Layer Graphics, bao gồm `Bathroom_top` ở Map015.
- `Graphics/Lights/`: KUL Graphics.
- `Graphics/Fog/` hoặc thư mục fog cấu hình: KUL/Victor fog.
- `Graphics/Parallaxes/`: animated/parallax lock.
- `Graphics/Weather/`: MOG Weather EX.
- `Graphics/System/`: weather, message và effect system.

## BulletHell

`Graphics/Invaders/` cần backdrop, alien0–4, alien4S, lazor/elazor variants, orbit_bullet, powerups và player1/player2.

## Missing/uncertain asset audit

Tên được script gọi chưa tự động chứng minh file tồn tại. Trước khi làm route phải chạy checklist theo từng scene: sprite, face, emote, CG, background, BGM, SFX, voice. Không đọc bitmap để tiết kiệm token; chỉ kiểm tra tree/tên file.

