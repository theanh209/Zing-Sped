// File: Mods.h
#ifndef Mods_h
#define Mods_h
#include <string>
#include <cstdint>

struct GameOffsets {
    uintptr_t GWorld = 0x0;
    uintptr_t PlayerKart = 0x0;
    uintptr_t NitroOffset = 0x0;
    uintptr_t SpeedOffset = 0x0;
    uintptr_t PositionOffset = 0x0;
    uintptr_t CollisionOffset = 0x0;
    bool isLoadedFromFile = false;
};

struct Mods {
    // Tab Cơ Bản (Racing)
    bool TeleportAuto = false;
    bool TeleportButton = false;
    bool MiniBoot = false;
    bool ThoatNhanh = false;
    bool VoHanNitro = false;
    bool NitroNhanh = false;
    bool ECU3Luot = false;
    bool TuDuaXe = false;
    bool GiaToc = false;
    
    // Sliders Tùy biến tốc độ & Nitro
    float GiaTocSpeed = 105.0f; // Mặc định 105.0f, range 10.0f - 300.0f
    float NitroDuration = 3.0f;  // Mặc định 3.0f, range 1.0f - 10.0f
    
    // Tab Auto Đua & Bản đồ (Map Selector)
    int AutoDuaMode = 1; // 1: Theo đường hướng dẫn, 2: Tự ra giữa đường
    bool AutoDuaLapTrinh = false;
    int SelectedMapIndex = 0; // Danh mục Map ID
    
    // Tab Nhân Vật / Xe
    bool KySinh = false;
    bool FakeTen = false;
    bool ModSkin = false;
    bool UnlockXeSkin = false;
    bool ModChiSoXe = false;
    
    // Camera FOV & Hỗ trợ Drift (Drift Assistant)
    bool CustomFOV = false;
    float CameraFOV = 60.0f; // Mặc định 60.0f, range 45.0f - 120.0f
    bool ShowDriftGuide = true; // Tâm ngắm & Thước đo góc Drift
    bool OptimalDriftCalc = true; // Tính toán góc chạy & drift tối ưu về nhất
    bool ShowSpeedometer = true;  // Đồng hồ đo tốc độ điện tử (Cyber Speedometer)
    bool CWWMetronome = true;     // Âm & rung báo nhịp CWW Boost khi vào vùng vàng

    // Tab Tiện Ích & Phòng Chờ (Tab 3)
    bool ShowHUD = true;          // Hiển thị HUD FPS / Ping
    bool ShowMatchTimer = true;   // Hiển thị đồng hồ bấm giờ trận
    bool ShowHardwareStats = true;// Đo RAM và Pin thời gian thực
    bool AutoReady = false;        // Tự động bấm Sẵn sàng phòng chờ
    bool AutoStart = false;        // Tự động bấm bắt đầu
    bool AntiAFK = true;          // Chống treo máy kick khỏi phòng chờ
    bool AntiCollision = false;    // Giảm va chạm nảy xe cọ tường
    bool AntiReport = true;        // Chặn log / report gửi về server VNG
    bool BlockAnalytics = true;    // Chặn telemetry / crashlytics

    // Tùy biến Menu & Hệ thống (Tab 4)
    bool HapticFeedback = true;    // Rung phản hồi iPhone
    bool SoundEffects = true;     // Âm thanh phản hồi khi bật tắt
    bool GestureShortcut = true;  // Cử chỉ chạm 3 ngón tay mở menu
    int ThemePreset = 0;          // 0: Dark, 1: Neon Cyan, 2: Racing Red, 3: Neon Purple, 4: Emerald Green
    float IconSize = 50.0f;       // Kích thước nút mở menu (35 - 75)
    float IconOpacity = 0.7f;     // Độ mờ nút menu (0.2 - 1.0)
};

extern Mods mods;
extern GameOffsets gameOffsets;

uintptr_t GetUnityBase();
void SaveConfig();
void LoadConfig();
void ResetConfig();
void TriggerHaptic(int type = 0);
void PlayBeepSound(int soundId = 1104);
void ApplyTheme(int preset);
void InitAntiReport();
void RenderHUD();
void RenderDriftGuide();
void RenderSpeedometer();
bool ExportConfigToClipboard();
bool ImportConfigFromClipboard();
void LoadDynamicOffsets();
void SaveDefaultOffsetsFile();
void ResetMatchTimer();

#endif
