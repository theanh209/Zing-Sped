# ZingSpeedTweakIOS

> **ZingSpeed Mobile iOS Mod Menu (ImGui Metal Edition)**  
> Menu mod/hack tweak cho tựa game **ZingSpeed Mobile VN (`vn.vng.zsmvn`)** trên hệ điều hành iOS (Jailbreak & Non-Jailbreak / Jailed).  
> **Tác giả:** [Zhee Dev](https://github.com/zheedevVn)

---

![Screenshot](menupic/screenshot.png)

## 📌 Giới thiệu (Overview)

**ZingSpeedTweakIOS** là dự án iOS tweak mod menu sử dụng giao diện **Dear ImGui** tối ưu bằng **Apple Metal Framework**, hỗ trợ can thiệp bộ nhớ Unity và hook chức năng trong game ZingSpeed Mobile mà không cần JIT.

- **Bundle ID hỗ trợ:** `vn.vng.zsmvn` (ZingSpeed Mobile VNG)
- **Kiến trúc:** `arm64` (iOS 13.0+)
- **Hỗ trợ thiết bị:** Cả máy đã Jailbreak (cài file `.deb`) và máy chưa Jailbreak (inject `.dylib` qua Sideloadly / TrollStore / Esign / Scarlet).

---

## ⚡ Các tính năng nổi bật (Features)

### 🏎️ Tab 0: Đua Xe Cơ Bản & Auto Lái Nâng Cao (Racing & Auto Drive)
- **Quỹ Đạo Ôm Cua Chuyên Nghiệp (Apex Out-In-Out Line):** Tùy chọn 3 chế độ chạy tự động: *1. Đường hướng dẫn*, *2. Ra giữa đường*, *3. Quỹ đạo Apex Out-In-Out* (bám sát mép ngoài trước cua $\rightarrow$ cắt sát vách cua trong $\rightarrow$ văng ngoài thoát cua đạt tốc độ cao nhất).
- **Trợ Lực Tự Bẻ Lái Apex & Trả Thẳng (Auto Apex Counter-Steering):** Tự động điều chỉnh góc xoay bánh xe vào góc vàng drift $38^\circ - 45^\circ$, tự động trả thẳng lái ngay khi hết cua giúp triệt tiêu văng xe và chống cọ mép tường.
- **Tự Động Kích Hoạt Combo CWW (Auto CWW Sequence):** Tự động canh đúng nhịp thoát cua để kích hoạt chuỗi kép Nitro + Mini Boost đôi (chuẩn combo CWW/WCW của tuyển thủ chuyên nghiệp).
- **Tùy Chỉnh Độ Nhạy Trợ Lực Drift:** Thanh trượt điều chỉnh mức độ can thiệp góc bẻ lái từ $1.0\times$ đến $3.0\times$.
- **Chế Độ Cắt Góc Cua:** Lựa chọn phong cách chạy: *Out-In-Out Tối Ưu*, *Cắt Ngắn (Short-Cut)*, hoặc *An Toàn (Safe Line)*.
- **Danh Mục Bản Đồ (Map ID Selector):** Cho phép chọn nhanh bản đồ cần đua (Hồ Long Tỉnh 157, Thành Phố 11 102, Đảo 11 120, Thu Danh Sơn 145, Suối Nước Nóng 188, Sa Mạc Tốc Độ 210) để tự động căn chỉnh tọa độ cua.
- **Auto Đua Lập Trình (Auto Race):** Tự động chạy bám đường kết hợp hệ thống lái tối ưu.
- **Vô Hạn Nitro (Infinite Nitro):** Luôn duy trì nitro, hỗ trợ thanh trượt tùy chỉnh thời gian Nitro (1s - 10s).
- **Gia Tốc (Speed Acceleration):** Tăng tốc độ tối đa của xe, hỗ trợ thanh trượt tốc độ (50 - 300 km/h).
- **Mini Boot (Super Mini Boost):** Tăng tốc mini boost liên tục.
- **ECU 3 Lượt:** Mở rộng số lần kích hoạt tính năng ECU.
- **Teleport Auto / Teleport Button:** Di chuyển tức thời đến các điểm mốc trên đường đua.
- **Thoát Nhanh (Fast Exit):** Rời trận nhanh chóng.
- **Nitro Nhanh:** Hồi nitro siêu tốc.

### 👤 Tab 1: Nhân Vật & Tài Khoản (Player)
- **Ký Sinh (Parasite):** Ghép và đồng bộ xe mục tiêu.
- **Fake Tên:** Ẩn hoặc đổi tên hiển thị trong trận.

### 🚘 Tab 2: Xe & Căn Góc Drift (Kart & Apex Drift Guide)
- **Đồng Hồ Tốc Độ Điện Tử (Cyberpunk Speedometer HUD):** Cụm đồng hồ tốc độ thể thao bo tròn hiển thị vận tốc km/h tức thời, kim đo góc xoay mượt mà và thanh trạng thái nạp Nitro.
- **Tâm Can Drift & Apex Racing Line:** Hiển thị tâm ngắm HUD và đường cong dẫn hướng ôm cua (Apex Trajectory) dạng Out-In-Out chuẩn xác trên màn hình.
- **Tính Toán Góc Cua Tối Ưu (CWW Boost Calculator):** Phân tích và căn góc drift trong vùng vàng **38° - 45°** lý tưởng nhất của ZingSpeed Mobile, giúp tối đa hóa tốc độ tích nạp Nitro và giảm thiểu tối đa mất tốc độ góc cua để về đích nhanh nhất.
- **Nhịp Rung Thoát Cua (CWW Metronome Haptic):** Tự động phát xung rung nhẹ (Taptic) báo hiệu chuẩn xác khi xe đã nằm trong vùng góc vàng để người chơi phản xạ kích hoạt Nitro kép.
- **Cảnh Báo CWW Boost Ready:** Báo hiệu thời điểm chuẩn xác nhất để kích hoạt kép phun nitro (CWW / WCW) khi xe đạt độ trôi góc tối ưu.
- **Mod Skin & Xe:** Mở khóa hiển thị xe và skin yêu thích.
- **Mod Chỉ Số Xe:** Tùy biến thông số hiệu năng xe.
- **Camera FOV:** Thanh trượt góc nhìn Camera từ 45° đến 120° giúp mở rộng tầm nhìn toàn cảnh đường đua.

### 🛠️ Tab 3: Tiện Ích & Phòng Chờ (Utilities & Protection)
- **Giám Sát Phần Cứng Realtime (RAM & Pin):** Đo trực tiếp lượng RAM chiếm dụng của game (`mach_task_basic_info`) và phần trăm pin để cảnh báo giật lag khi máy quá nhiệt.
- **Chống AFK Kick Phòng Chờ (Anti-AFK Keepalive):** Ngăn chặn hệ thống game kick ra khỏi phòng khi treo máy, đồng thời giữ màn hình luôn sáng (`idleTimerDisabled`).
- **HUD Realtime Overlay:** Bảng chỉ số FPS thực tế, Ping ms, đồng hồ bấm giờ (Stopwatch) và Badges cheat đang hoạt động (không cản trở thao tác lái xe).
- **Live Memory Inspector:** Xem trực tiếp địa chỉ `Unity Base (0x...)` và trạng thái module game ngay trên menu.
- **Bộ Nạp Offset Động (`Offsets.json`):** Tự động đọc file `Offsets.json` từ thư mục Documents của game, cho phép bạn cập nhật offset 0x bất cứ lúc nào qua Filza/Text Editor mà **không cần phải biên dịch lại mã nguồn**.
- **Auto Ready & Auto Start:** Tự động ấn Sẵn sàng và Bắt đầu trận đấu.
- **Giảm Va Chạm Tường:** Ổn định thân xe, giảm thiểu tình trạng nảy xe khi cọ mép tường.
- **Chống Report Server & Chặn Log Analytics:** Can thiệp ngắt gói tin gửi crash log/telemetry về máy chủ game, giảm thiểu nguy cơ bị quét tài khoản.

### 👑 Tab 4: Tác Giả Zhee Dev & Giao Diện (Showcase & System)
- **Sao Chép & Chia Sẻ Cấu Hình (Share Config via Clipboard):** Nút *Sao Chép Config* đóng gói toàn bộ thiết lập thành chuỗi mã hóa Base64 và nút *Dán & Áp Dụng* giúp nhập nhanh cấu hình từ bạn bè vào game chỉ bằng 1 chạm.
- **Ghi Nhớ Vị Trí Nút Nổi:** Tự động lưu tọa độ X, Y của nút menu khi bạn kéo thả, không bao giờ bị nhảy về giữa màn hình sau khi khởi động lại game.
- **Thẻ Tác Giả Zhee Dev (Profile Showcase):** Tiêu đề animated gradient cầu vồng, card thông tin lập trình viên viền neon phát sáng, hiển thị trạng thái `STATUS: ONLINE & ACTIVATED`.
- **Cử chỉ 3 ngón tay (3-Finger Tap):** Chạm 3 ngón tay cùng lúc lên màn hình để ẩn/hiện menu nhanh chóng.
- **Âm thanh phản hồi (Sound Effects):** Phát âm thanh click native khi thao tác.
- **Bộ Theme Presets:** Đổi ngay màu sắc menu: **Classic Dark**, **Cyberpunk Neon Cyan**, **Racing Red**, **Neon Purple**, **Emerald Green**.
- **Tùy biến Nút Nổi (Floating Icon):** Thanh trượt chỉnh kích thước icon và độ mờ trong suốt.
- **Haptic Feedback:** Tích hợp rung phản hồi nhẹ qua Taptic Engine của iPhone khi chạm nút hoặc bật toggle.
- **Lưu Cấu Hình (Save/Reset Config):** Tự động ghi nhớ cấu hình vào `NSUserDefaults`.
- **Safe Memory Engine:** Đọc/ghi an toàn bằng Mach API (`vm_read_overwrite`, `vm_protect`), cache Base Address chống crash và tiết kiệm pin.

---

## 📄 Hướng dẫn sử dụng file cấu hình `Offsets.json`

Khi cài đặt và mở game lần đầu, tweak sẽ tự tạo file mẫu tại:  
`/var/mobile/Containers/Data/Application/<ZingSpeedMobile>/Documents/Offsets.json`

Nội dung file JSON:
```json
{
  "_HuongDan": "Dien cac dia chi offset hex 0x vao day. Luu file roi vao game bam Reload Offsets.",
  "GWorld": "0x0",
  "PlayerKart": "0x0",
  "NitroOffset": "0x0",
  "SpeedOffset": "0x0",
  "PositionOffset": "0x0",
  "CollisionOffset": "0x0"
}
```
Khi bạn có offset mới:
1. Mở file `Offsets.json` bằng Filza hoặc trình soạn thảo text bất kỳ.
2. Điền địa chỉ hex (ví dụ: `"NitroOffset": "0x54"`).
3. Vào game, mở Menu -> **Tab Tiện Ích** -> Bấm **Tải Lại Offsets.json**. Tweak sẽ cập nhật ngay lập tức!

---

## 🛠️ Yêu cầu & Cài đặt (Requirements & Build)

### 1. Build tự động qua GitHub Actions (Khuyên dùng)
Dự án tích hợp sẵn workflow [`.github/workflows/build.yml`](.github/workflows/build.yml):
1. Nhấn **Star** và **Fork** repository này về tài khoản GitHub của bạn.
2. Vào tab **Actions** trên GitHub repo của bạn.
3. Chọn workflow **Build ZingSpeedTweakIOS** và nhấn **Run workflow**.
4. Khi quá trình build hoàn tất:
   - **Người dùng Jailbreak:** Tải file tại artifact **`ZingSpeedTweakIOS-Deb`**.
   - **Người dùng Non-Jailbreak / Sideloadly / TrollStore:** Tải ngay file tại artifact **`ZingSpeedTweakIOS-Dylib`** (đã tách sẵn file `.dylib` và `libdobby_fixed.a`).

### 2. Build thủ công trên máy tính (macOS / Linux với Theos)
Cài đặt [Theos](https://theos.dev):
```bash
git clone --recursive https://github.com/theos/theos.git $HOME/theos
export THEOS=$HOME/theos
export PATH=$THEOS/bin:$PATH

# Biên dịch gói .deb:
make clean package FINALPACKAGE=1
```
Gói `.deb` sẽ được xuất ra trong thư mục `packages/`.

---

## 📲 Hướng dẫn cài đặt vào Game (Installation Guide)

### Cách 1: Thiết bị đã Jailbreak
1. Chép file `.deb` vào thiết bị qua Filza File Manager.
2. Nhấn vào file `.deb` và chọn **Install** (Cài đặt).
3. Mở game **ZingSpeed Mobile** và chạm vào nút menu tròn để mở giao diện.

### Cách 2: Thiết bị chưa Jailbreak (TrollStore / Sideloadly / Esign)
1. Tải gói artifact **`ZingSpeedTweakIOS-Dylib`** (đã có sẵn file `ZingSpeedTweakIOS.dylib` và `libdobby_fixed.a`).
2. Tải file `.ipa` gốc của **ZingSpeed Mobile VN**.
3. Dùng Sideloadly, TrollStore hoặc Esign để chèn (inject) `ZingSpeedTweakIOS.dylib` vào file `.ipa`.
4. Cài đặt và mở game trải nghiệm.

---

## 👨‍💻 Tác giả & Bản quyền (Author & Credits)

- **Author / Developer:** [Zhee Dev (@zheedevVn)](https://github.com/zheedevVn)
- **Repository:** [https://github.com/zheedevVn/ZingSpeedTweakIOS](https://github.com/zheedevVn/ZingSpeedTweakIOS)
- **Giao diện ImGui:** Dựa trên template ImGui Metal iOS, được tinh chỉnh và tùy biến bởi **Zhee Dev**.

---

## ⚠️ Tuyên bố miễn trừ trách nhiệm (Disclaimer)

Dự án này được phát triển chỉ nhằm mục đích nghiên cứu học tập kỹ thuật dịch ngược (reverse engineering) và lập trình đồ họa Metal trên iOS. Tác giả không chịu trách nhiệm đối với bất kỳ hành vi lạm dụng nào vi phạm điều khoản dịch vụ của nhà phát hành game.
