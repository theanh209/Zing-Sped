// File: Mods.mm (Bản Full - Tự động dùng Token)
#include "Mods.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <string.h>
#import "ImGui/ImGuiDrawViewX.h"

Mods mods;
GameOffsets gameOffsets;
PIDState g_steeringPID;

// ==========================================
// 1. HÀM LẤY BASE ADDRESS
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
// 2. HÀM ĐỌC/GHI BỘ NHỚ AN TOÀN (CHỐNG VĂNG)
// ==========================================
static inline bool IsValidAddress(uintptr_t addr) {
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
    if (SafeRead<T>(addr, &val)) return val;
    return defaultVal;
}

// ==========================================
// 3. BỘ RESOLVER TOKEN (TÌM ĐỊA CHỈ HÀM TỪ TOKEN)
// ==========================================
uintptr_t ResolveToken(uint32_t token) {
    if ((token & 0xFF000000) != 0x06000000) return 0;
    uint32_t methodIndex = (token & 0x00FFFFFF) - 1;

    void* codeGenModulesPtr = dlsym(RTLD_DEFAULT, "g_CodeGenModules");
    if (!codeGenModulesPtr) return 0;

    struct Il2CppCodeGenModule {
        const char* moduleName;
        const uint32_t methodPointerCount;
        const void** methodPointers;
    };

    struct Il2CppCodeGenModule** g_CodeGenModules = *(struct Il2CppCodeGenModule***)codeGenModulesPtr;
    uint32_t* g_CodeGenModulesCountPtr = (uint32_t*)dlsym(RTLD_DEFAULT, "g_CodeGenModulesCount");
    if (!g_CodeGenModules || !g_CodeGenModulesCountPtr) return 0;
    
    uint32_t count = *g_CodeGenModulesCountPtr;

    for (uint32_t i = 0; i < count; i++) {
        struct Il2CppCodeGenModule* mod = g_CodeGenModules[i];
        if (methodIndex < mod->methodPointerCount) {
            return (uintptr_t)mod->methodPointers[methodIndex];
        }
        methodIndex -= mod->methodPointerCount;
    }
    return 0;
}

// ==========================================
// 4. CÁC HÀM TIỆN ÍCH
// ==========================================
void TriggerHaptic(int type) {
    if (!mods.HapticFeedback) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:type == 0 ? UIImpactFeedbackStyleLight : UIImpactFeedbackStyleMedium];
        [gen impactOccurred];
    });
}

void PlayBeepSound(int soundId) {
    if (!mods.SoundEffects) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound((SystemSoundID)soundId);
    });
}

void LoadConfig() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    mods.VoHanNitro = [defaults boolForKey:@"zst_VoHanNitro"];
    mods.GiaToc = [defaults boolForKey:@"zst_GiaToc"];
    mods.GiaTocSpeed = [defaults floatForKey:@"zst_GiaTocSpeed"];
    mods.NitroDuration = [defaults floatForKey:@"zst_NitroDuration"];
    mods.AutoDuaLapTrinh = [defaults boolForKey:@"zst_AutoDuaLapTrinh"];
}

void SaveConfig() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:mods.VoHanNitro forKey:@"zst_VoHanNitro"];
    [defaults setBool:mods.GiaToc forKey:@"zst_GiaToc"];
    [defaults setFloat:mods.GiaTocSpeed forKey:@"zst_GiaTocSpeed"];
    [defaults setFloat:mods.NitroDuration forKey:@"zst_NitroDuration"];
    [defaults setBool:mods.AutoDuaLapTrinh forKey:@"zst_AutoDuaLapTrinh"];
    [defaults synchronize];
}

void ApplyFPS(int fps) {
    [ImGuiDrawViewX setTargetFPS:fps];
}

// ==========================================
// 5. LUỒNG CHÍNH CHẠY MOD
// ==========================================
void LoadMods()
{
    LoadConfig();
    ApplyFPS(mods.TargetFPS);
    
    uintptr_t offsetGWorld = 0x1AD99C40; 
    uintptr_t offsetPlayerKart = 0x40;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        uintptr_t func_SetSpeed = ResolveToken(0x0600B2C7); 
        uintptr_t func_SetNitro = ResolveToken(0x06033679); 
        
        while (true) {
            @autoreleasepool {
                uintptr_t base = GetUnityBase();
                
                if (base && base != 0) {
                    uintptr_t actorPool = ReadMem<uintptr_t>(base + offsetGWorld);
                    if (actorPool != 0) {
                        uintptr_t listViewPtr = actorPool + offsetPlayerKart;
                        uintptr_t buffer = ReadMem<uintptr_t>(listViewPtr + 0x10);
                        
                        if (buffer != 0) {
                            uintptr_t kart = ReadMem<uintptr_t>(buffer);
                            
                            if (kart != 0) {
                                if (mods.GiaToc && func_SetSpeed != 0) {
                                    typedef void (*SetSpeedFunc)(void*, float);
                                    SetSpeedFunc setSpeed = (SetSpeedFunc)func_SetSpeed;
                                    setSpeed((void*)kart, mods.GiaTocSpeed);
                                }
                                
                                if (mods.VoHanNitro && func_SetNitro != 0) {
                                    typedef void (*SetEnergyFunc)(void*, float);
                                    SetEnergyFunc setEnergy = (SetEnergyFunc)func_SetNitro;
                                    setEnergy((void*)kart, 100.0f);
                                }
                            }
                        }
                    }
                }
                [NSThread sleepForTimeInterval:0.016];
            }
        }
    });
}
