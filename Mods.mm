// File: Mods.mm
#include "Mods.h"
#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <string.h>

Mods mods;
char* BinaryName = "Frameworks/UnityFramework.framework/UnityFramework";

// ==========================================
// 1. TỐI ƯU HIỆU NĂNG & BASE ADDRESS CACHING
// ==========================================
static uintptr_t cachedBase = 0;

uintptr_t GetUnityBase() {
    if (cachedBase != 0) return cachedBase;

    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "UnityFramework")) {
            cachedBase = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return cachedBase;
}

// ==========================================
// 2. SAFE MEMORY READ / WRITE (CHỐNG CRASH)
// ==========================================
static inline bool IsValidAddress(uintptr_t addr) {
    // Địa chỉ người dùng trên iOS 64-bit thường nằm trong khoảng này
    return (addr >= 0x100000000ULL && addr <= 0x3000000000ULL);
}

template<typename T>
bool SafeRead(uintptr_t addr, T* outVal) {
    if (!IsValidAddress(addr) || !outVal) return false;
    vm_size_t size = sizeof(T);
    kern_return_t kr = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, size, (vm_address_t)outVal, &size);
    return (kr == KERN_SUCCESS && size == sizeof(T));
}

template<typename T>
T ReadMem(uintptr_t addr, T defaultVal = T()) {
    T val = defaultVal;
    if (SafeRead<T>(addr, &val)) {
        return val;
    }
    return defaultVal;
}

template<typename T>
bool SafeWrite(uintptr_t addr, T val) {
    if (!IsValidAddress(addr)) return false;
    kern_return_t kr = vm_protect(mach_task_self(), (vm_address_t)addr, sizeof(T), FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr != KERN_SUCCESS) return false;
    *(T*)addr = val;
    return true;
}

template<typename T>
void WriteMem(uintptr_t addr, T val) {
    SafeWrite<T>(addr, val);
}

// ==========================================
// 3. TỰ ĐỘNG LƯU / KHÔI PHỤC CẤU HÌNH CONFIG
// ==========================================
void SaveConfig() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:mods.TeleportAuto forKey:@"zst_TeleportAuto"];
    [defaults setBool:mods.TeleportButton forKey:@"zst_TeleportButton"];
    [defaults setBool:mods.MiniBoot forKey:@"zst_MiniBoot"];
    [defaults setBool:mods.ThoatNhanh forKey:@"zst_ThoatNhanh"];
    [defaults setBool:mods.VoHanNitro forKey:@"zst_VoHanNitro"];
    [defaults setBool:mods.NitroNhanh forKey:@"zst_NitroNhanh"];
    [defaults setBool:mods.ECU3Luot forKey:@"zst_ECU3Luot"];
    [defaults setBool:mods.TuDuaXe forKey:@"zst_TuDuaXe"];
    [defaults setBool:mods.GiaToc forKey:@"zst_GiaToc"];
    [defaults setFloat:mods.GiaTocSpeed forKey:@"zst_GiaTocSpeed"];
    [defaults setFloat:mods.NitroDuration forKey:@"zst_NitroDuration"];
    [defaults setInteger:mods.AutoDuaMode forKey:@"zst_AutoDuaMode"];
    [defaults setBool:mods.AutoDuaLapTrinh forKey:@"zst_AutoDuaLapTrinh"];
    [defaults setBool:mods.KySinh forKey:@"zst_KySinh"];
    [defaults setBool:mods.FakeTen forKey:@"zst_FakeTen"];
    [defaults setBool:mods.ModSkin forKey:@"zst_ModSkin"];
    [defaults setBool:mods.UnlockXeSkin forKey:@"zst_UnlockXeSkin"];
    [defaults setBool:mods.ModChiSoXe forKey:@"zst_ModChiSoXe"];
    [defaults setBool:mods.CustomFOV forKey:@"zst_CustomFOV"];
    [defaults setFloat:mods.CameraFOV forKey:@"zst_CameraFOV"];
    [defaults synchronize];
}

void LoadConfig() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"zst_GiaTocSpeed"] != nil) {
        mods.TeleportAuto = [defaults boolForKey:@"zst_TeleportAuto"];
        mods.TeleportButton = [defaults boolForKey:@"zst_TeleportButton"];
        mods.MiniBoot = [defaults boolForKey:@"zst_MiniBoot"];
        mods.ThoatNhanh = [defaults boolForKey:@"zst_ThoatNhanh"];
        mods.VoHanNitro = [defaults boolForKey:@"zst_VoHanNitro"];
        mods.NitroNhanh = [defaults boolForKey:@"zst_NitroNhanh"];
        mods.ECU3Luot = [defaults boolForKey:@"zst_ECU3Luot"];
        mods.TuDuaXe = [defaults boolForKey:@"zst_TuDuaXe"];
        mods.GiaToc = [defaults boolForKey:@"zst_GiaToc"];
        mods.GiaTocSpeed = [defaults floatForKey:@"zst_GiaTocSpeed"];
        mods.NitroDuration = [defaults floatForKey:@"zst_NitroDuration"];
        mods.AutoDuaMode = (int)[defaults integerForKey:@"zst_AutoDuaMode"];
        if (mods.AutoDuaMode == 0) mods.AutoDuaMode = 1;
        mods.AutoDuaLapTrinh = [defaults boolForKey:@"zst_AutoDuaLapTrinh"];
        mods.KySinh = [defaults boolForKey:@"zst_KySinh"];
        mods.FakeTen = [defaults boolForKey:@"zst_FakeTen"];
        mods.ModSkin = [defaults boolForKey:@"zst_ModSkin"];
        mods.UnlockXeSkin = [defaults boolForKey:@"zst_UnlockXeSkin"];
        mods.ModChiSoXe = [defaults boolForKey:@"zst_ModChiSoXe"];
        mods.CustomFOV = [defaults boolForKey:@"zst_CustomFOV"];
        mods.CameraFOV = [defaults floatForKey:@"zst_CameraFOV"];
    }
}

void ResetConfig() {
    mods = Mods();
    SaveConfig();
}

// ==========================================
// 4. LUỒNG THI HÀNH CHEATS (BACKGROUND THREAD)
// ==========================================
void LoadMods()
{
    // Tải cấu hình đã lưu
    LoadConfig();

    // Khởi tạo luồng chạy ngầm 60fps tối ưu
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            @autoreleasepool {
                uintptr_t base = GetUnityBase();
                if (base) {
                    // === KHU VỰC ĐIỀN OFFSET GAME ===
                    // uintptr_t GWorld = ReadMem<uintptr_t>(base + 0x0);
                    // uintptr_t Kart = ReadMem<uintptr_t>(GWorld + 0x0);
                    
                    // Can thiệp an toàn với SafeWrite
                    if (mods.VoHanNitro) {
                        // SafeWrite<float>(Kart + 0x0, mods.NitroDuration);
                    }
                    if (mods.GiaToc) {
                        // SafeWrite<float>(Kart + 0x0, mods.GiaTocSpeed);
                    }
                    if (mods.AutoDuaLapTrinh) {
                        // Code Auto Bám Đường
                    }
                }
                [NSThread sleepForTimeInterval:0.016]; // Ngủ 16ms (60fps)
            }
        }
    });
}
