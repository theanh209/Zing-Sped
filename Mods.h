// File: Mods.h
#ifndef Mods_h
#define Mods_h
#include <string>
#include <cstdint>
#if defined(__OBJC__)
#import <Foundation/Foundation.h>
#else
typedef struct objc_object NSString;
#endif

struct GameOffsets {
    uintptr_t GWorld = 0x0;
    uintptr_t PlayerKart = 0x0;
    uintptr_t NitroOffset = 0x0;
    uintptr_t SpeedOffset = 0x0;
    uintptr_t PositionOffset = 0x0;
    uintptr_t CollisionOffset = 0x0;
    bool isLoadedFromFile = false;
};

struct PIDState {
    float prevError = 0.0f;
    float integral = 0.0f;
    float output = 0.0f;

    float Update(float error, float dt, float kp, float ki, float kd) {
        if (dt <= 0.0f) dt = 0.016f;
        integral += error * dt;
        if (integral > 10.0f) integral = 10.0f;
        if (integral < -10.0f) integral = -10.0f;
        float derivative = (error - prevError) / dt;
        prevError = error;
        output = (kp * error) + (ki * integral) + (kd * derivative);
        return output;
    }

    void Reset() {
        prevError = 0.0f;
        integral = 0.0f;
        output = 0.0f;
    }
};

extern PIDState g_steeringPID;

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
    
    // Tab Auto Đua & Bản đồ (Advanced Auto Drive & Steering)
    int AutoDuaMode = 1; // 1: Theo đường hướng dẫn, 2: Tự ra giữa đường, 3: Quỹ đạo Apex Out-In-Out
    bool AutoDuaLapTrinh = false;
    int SelectedMapIndex = 0; // Danh mục Map ID
    bool AutoApexSteer = true; // Trợ lực tự bẻ lái vào góc Apex & trả thẳng
    bool AutoCWWSequence = true; // Tự động combo chuỗi CWW khi thoát cua
    float DriftAssistanceLevel = 1.5f; // Độ nhạy trợ lực drift (1.0f - 3.0f)
    int RacingLineType = 0; // 0: Out-In-Out (Tối ưu), 1: Cắt ngắn (Short-Cut), 2: An toàn (Safe Line)

    // Thuật Toán Điều Khiển Học & Động Lực Học (Advanced Racing Algorithms)
    bool UsePurePursuit = true;       // Thuật toán Pure Pursuit bám quỹ đạo động
    bool UsePIDController = true;      // Bộ điều khiển vi tích phân PID lái mượt
    bool UseSplineInterpolation = true;// Nội suy đường cong trơn mượt Catmull-Rom Spline
    bool PredictCWWMillisecond = true; // Dự đoán chính xác mili-giây nhả Drift kích hoạt CWW
    float PID_Kp = 1.25f;              // Hệ số tỉ lệ P (bẻ lái nhanh về tim đường)
    float PID_Ki = 0.05f;              // Hệ số tích phân I (triệt tiêu trôi dạt)
    float PID_Kd = 0.45f;              // Hệ số vi phân D (triệt tiêu rung lắc / rắn bò)
    float LookaheadRatio = 0.22f;      // Tỉ lệ khoảng cách nhìn trước L = k * v
    
    // Bộ Tính Năng Chiến Thắng Thực Chiến (Competitive Winning Mechanics)
    bool LockMinDriftAngle = true;     // Khóa góc drift tối thiểu giữ tốc 198-205 km/h
    float MinDriftAngleVal = 29.5f;    // Góc drift tối thiểu (25.0 - 38.0 deg)
    bool AutoSnapDrift = true;         // Auto Đoạn Drift / Snap bẻ thẳng xe tức thì
    bool PerfectCWWChain = true;       // Combo chuỗi CWW chuẩn khung hình 100% max speed
    bool AntiBumpRecovery = true;      // Chống văng khi va chạm & tự lấy lại lái tâm đường
    float RecoverySensitivity = 0.15f; // Độ nhạy phục hồi sau va chạm (0.05 - 0.5s)
    bool ApexCornerCutter = true;      // Cắt góc cua ôm sát mép lề (rút ngắn 8-12% đường)
    float ApexMargin = 0.20f;          // Khoảng cách lề trong Apex (0.1 - 0.6m)
    
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
    bool WebRadarEnabled = false; // Chia sẻ Live Radar lên trình duyệt máy tính
    int WebRadarPort = 8088;      // Cổng Web Server Radar (mặc định 8088)
    bool CloudRadarEnabled = false; // Chia sẻ Live Radar qua Cloud Hosting (zingspeedvnmod.vercel.app)
    char CloudRoomCode[16] = "ZSMOD"; // Mã phòng 5 chữ cái viết hoa (VD: ZSMOD, SPEED)

    // Tùy biến Menu & Hệ thống (Tab 4)
    bool HapticFeedback = true;    // Rung phản hồi iPhone
    bool SoundEffects = true;     // Âm thanh phản hồi khi bật tắt
    bool GestureShortcut = true;  // Cử chỉ chạm 3 ngón tay mở menu
    bool ShowFloatingIcon = true; // Hiển thị nút nổi icon mở menu
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
void ProcessAutoDrive(uintptr_t kart);
bool ExportConfigToClipboard();
bool ImportConfigFromClipboard();
void LoadDynamicOffsets();
void SaveDefaultOffsetsFile();
void ResetMatchTimer();
void StartWebRadarServer();
void StopWebRadarServer();
NSString* GetWebRadarURL();
void GenerateNewCloudRoomCode();
NSString* GetCloudRadarURL();
void PushTelemetryToCloud();

struct Vector2D {
    float x;
    float y;
};

struct Vector3D {
    float x;
    float y;
    float z;
};

extern Vector3D g_playerPos;
extern float g_playerYaw;
extern int g_currentWaypointIndex;
extern int g_totalWaypoints;

Vector2D EvaluateCatmullRom(Vector2D p0, Vector2D p1, Vector2D p2, Vector2D p3, float t);
float ComputePurePursuitSteering(float currentX, float currentZ, float currentYaw, float targetX, float targetZ, float speed);

#endif
