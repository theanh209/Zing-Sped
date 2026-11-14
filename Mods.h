// File: Mods.h
#ifndef Mods_h
#define Mods_h
#include <string>

struct Mods {
    // Tab Cơ Bản
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
    
    // Tab Auto Đua
    int AutoDuaMode = 1; // 1: Theo đường hướng dẫn, 2: Tự ra giữa đường
    bool AutoDuaLapTrinh = false;
    
    // Tab Nhân Vật / Xe
    bool KySinh = false;
    bool FakeTen = false;
    bool ModSkin = false;
    bool UnlockXeSkin = false;
    bool ModChiSoXe = false;
    
    // Camera FOV
    bool CustomFOV = false;
    float CameraFOV = 60.0f; // Mặc định 60.0f, range 45.0f - 120.0f
};

extern Mods mods;

void SaveConfig();
void LoadConfig();
void ResetConfig();

#endif
