// File: Mods.mm
#include "Mods.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#import "ImGui/ImGuiDrawViewX.h"
#include "LiveWebRadarHtml.h"

Mods mods;
GameOffsets gameOffsets;
PIDState g_steeringPID;
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
// 3. HAPTIC & SOUND FEEDBACK (RUNG & ÂM THANH)
// ==========================================
void TriggerHaptic(int type) {
    if (!mods.HapticFeedback) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == 0) {
            UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [gen prepare];
            [gen impactOccurred];
        } else if (type == 1) {
            UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [gen prepare];
            [gen impactOccurred];
        } else if (type == 2) {
            UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [gen prepare];
            [gen impactOccurred];
        } else if (type == 3) {
            UINotificationFeedbackGenerator *gen = [[UINotificationFeedbackGenerator alloc] init];
            [gen prepare];
            [gen notificationOccurred:UINotificationFeedbackTypeSuccess];
        }
    });
}

void PlayBeepSound(int soundId) {
    if (!mods.SoundEffects) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound((SystemSoundID)soundId);
    });
}

// ==========================================
// 4. BỘ NẠP OFFSET ĐỘNG TỪ FILE JSON (DOCUMENTS)
// ==========================================
static uintptr_t ParseHex(NSString *hexStr) {
    if (!hexStr) return 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    unsigned long long val = 0;
    if ([scanner scanHexLongLong:&val]) {
        return (uintptr_t)val;
    }
    return 0;
}

static NSString* GetOffsetsFilePath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths firstObject];
    return [docsDir stringByAppendingPathComponent:@"Offsets.json"];
}

void SaveDefaultOffsetsFile() {
    NSString *path = GetOffsetsFilePath();
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dict = @{
            @"_HuongDan": @"Dien cac dia chi offset hex 0x vao day. Luu file roi vao game bam Reload Offsets.",
            @"GWorld": @"0x0",
            @"PlayerKart": @"0x0",
            @"NitroOffset": @"0x0",
            @"SpeedOffset": @"0x0",
            @"PositionOffset": @"0x0",
            @"CollisionOffset": @"0x0"
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        if (jsonData) {
            [jsonData writeToFile:path atomically:YES];
        }
    }
}

void LoadDynamicOffsets() {
    SaveDefaultOffsetsFile();
    NSString *path = GetOffsetsFilePath();
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSError *err = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (!err && json && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *memOffsets = json[@"MemoryOffsets"];
            if (memOffsets && [memOffsets isKindOfClass:[NSDictionary class]]) {
                if (memOffsets[@"GWorld"]) gameOffsets.GWorld = ParseHex(memOffsets[@"GWorld"]);
                if (memOffsets[@"PlayerKart"]) gameOffsets.PlayerKart = ParseHex(memOffsets[@"PlayerKart"]);
                if (memOffsets[@"NitroOffset"]) gameOffsets.NitroOffset = ParseHex(memOffsets[@"NitroOffset"]);
                if (memOffsets[@"SpeedOffset"]) gameOffsets.SpeedOffset = ParseHex(memOffsets[@"SpeedOffset"]);
                if (memOffsets[@"PositionOffset"]) gameOffsets.PositionOffset = ParseHex(memOffsets[@"PositionOffset"]);
                if (memOffsets[@"CollisionOffset"]) gameOffsets.CollisionOffset = ParseHex(memOffsets[@"CollisionOffset"]);
            }
            if (json[@"GWorld"]) gameOffsets.GWorld = ParseHex(json[@"GWorld"]);
            if (json[@"PlayerKart"]) gameOffsets.PlayerKart = ParseHex(json[@"PlayerKart"]);
            if (json[@"NitroOffset"]) gameOffsets.NitroOffset = ParseHex(json[@"NitroOffset"]);
            if (json[@"SpeedOffset"]) gameOffsets.SpeedOffset = ParseHex(json[@"SpeedOffset"]);
            if (json[@"PositionOffset"]) gameOffsets.PositionOffset = ParseHex(json[@"PositionOffset"]);
            if (json[@"CollisionOffset"]) gameOffsets.CollisionOffset = ParseHex(json[@"CollisionOffset"]);
            gameOffsets.isLoadedFromFile = true;
        }
    }
}

// ==========================================
// 5. CHỐNG REPORT & CHẶN GỬI LOG / ANALYTICS
// ==========================================
static BOOL ShouldBlockURL(NSURL *url) {
    if (!url) return NO;
    if (!mods.AntiReport && !mods.BlockAnalytics) return NO;
    NSString *urlString = [url.absoluteString lowercaseString];
    if ([urlString containsString:@"report"] ||
        [urlString containsString:@"crashlytics"] ||
        [urlString containsString:@"analytics"] ||
        [urlString containsString:@"telemetry"] ||
        [urlString containsString:@"log.vng"] ||
        [urlString containsString:@"collector"] ||
        [urlString containsString:@"bugly"] ||
        [urlString containsString:@"firebase"] ||
        [urlString containsString:@"apm"]) {
        return YES;
    }
    return NO;
}

typedef NSURLSessionDataTask* (*DataTaskWithRequestFunc)(id, SEL, NSURLRequest*, void(^)(NSData*, NSURLResponse*, NSError*));
static DataTaskWithRequestFunc orig_dataTaskWithRequest = NULL;

static NSURLSessionDataTask* hook_dataTaskWithRequest(id self, SEL _cmd, NSURLRequest *request, void(^completionHandler)(NSData*, NSURLResponse*, NSError*)) {
    if (ShouldBlockURL(request.URL)) {
        if (completionHandler) {
            NSHTTPURLResponse *fakeResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler([NSData data], fakeResponse, nil);
            });
        }
        return nil;
    }
    if (orig_dataTaskWithRequest) {
        return orig_dataTaskWithRequest(self, _cmd, request, completionHandler);
    }
    return nil;
}

void ApplyFPS(int fps) {
    if (fps < 30) fps = 30;
    if (fps > 120) fps = 120;
    mods.TargetFPS = fps;

    // 1. Cập nhật Metal MTKView ImGui
    [ImGuiDrawViewX setTargetFPS:fps];

    // 2. Can thiệp Unity Game Engine CADisplayLink rate
    typedef void (*UnitySetTargetFPSFunc)(int);
    static UnitySetTargetFPSFunc s_unitySetTargetFPS = nullptr;
    if (!s_unitySetTargetFPS) {
        s_unitySetTargetFPS = (UnitySetTargetFPSFunc)dlsym(RTLD_DEFAULT, "UnitySetTargetFPS");
    }
    if (s_unitySetTargetFPS) {
        s_unitySetTargetFPS(fps);
    }
}

void InitAntiReport() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class sessionClass = [NSURLSession class];
        SEL sel = @selector(dataTaskWithRequest:completionHandler:);
        Method m = class_getInstanceMethod(sessionClass, sel);
        if (m) {
            orig_dataTaskWithRequest = (DataTaskWithRequestFunc)method_getImplementation(m);
            method_setImplementation(m, (IMP)hook_dataTaskWithRequest);
        }
    });
}

// ==========================================
// 6. TỰ ĐỘNG LƯU / KHÔI PHỤC CẤU HÌNH CONFIG
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
    
    // Config mới
    [defaults setBool:mods.ShowHUD forKey:@"zst_ShowHUD"];
    [defaults setBool:mods.ShowMatchTimer forKey:@"zst_ShowMatchTimer"];
    [defaults setBool:mods.ShowHardwareStats forKey:@"zst_ShowHardwareStats"];
    [defaults setBool:mods.AutoReady forKey:@"zst_AutoReady"];
    [defaults setBool:mods.AutoStart forKey:@"zst_AutoStart"];
    [defaults setBool:mods.AntiAFK forKey:@"zst_AntiAFK"];
    [defaults setBool:mods.AntiCollision forKey:@"zst_AntiCollision"];
    [defaults setBool:mods.AntiReport forKey:@"zst_AntiReport"];
    [defaults setBool:mods.BlockAnalytics forKey:@"zst_BlockAnalytics"];
    [defaults setBool:mods.HapticFeedback forKey:@"zst_HapticFeedback"];
    [defaults setBool:mods.SoundEffects forKey:@"zst_SoundEffects"];
    [defaults setBool:mods.GestureShortcut forKey:@"zst_GestureShortcut"];
    [defaults setInteger:mods.ThemePreset forKey:@"zst_ThemePreset"];
    [defaults setInteger:mods.SelectedMapIndex forKey:@"zst_SelectedMapIndex"];
    [defaults setBool:mods.ShowDriftGuide forKey:@"zst_ShowDriftGuide"];
    [defaults setBool:mods.OptimalDriftCalc forKey:@"zst_OptimalDriftCalc"];
    [defaults setBool:mods.ShowSpeedometer forKey:@"zst_ShowSpeedometer"];
    [defaults setBool:mods.CWWMetronome forKey:@"zst_CWWMetronome"];
    [defaults setBool:mods.AutoApexSteer forKey:@"zst_AutoApexSteer"];
    [defaults setBool:mods.AutoCWWSequence forKey:@"zst_AutoCWWSequence"];
    [defaults setFloat:mods.DriftAssistanceLevel forKey:@"zst_DriftAssistanceLevel"];
    [defaults setInteger:mods.RacingLineType forKey:@"zst_RacingLineType"];
    [defaults setBool:mods.UsePurePursuit forKey:@"zst_UsePurePursuit"];
    [defaults setBool:mods.UsePIDController forKey:@"zst_UsePIDController"];
    [defaults setBool:mods.UseSplineInterpolation forKey:@"zst_UseSplineInterpolation"];
    [defaults setBool:mods.PredictCWWMillisecond forKey:@"zst_PredictCWWMillisecond"];
    [defaults setFloat:mods.PID_Kp forKey:@"zst_PID_Kp"];
    [defaults setFloat:mods.PID_Ki forKey:@"zst_PID_Ki"];
    [defaults setFloat:mods.PID_Kd forKey:@"zst_PID_Kd"];
    [defaults setFloat:mods.LookaheadRatio forKey:@"zst_LookaheadRatio"];
    [defaults setBool:mods.LockMinDriftAngle forKey:@"zst_LockMinDriftAngle"];
    [defaults setFloat:mods.MinDriftAngleVal forKey:@"zst_MinDriftAngleVal"];
    [defaults setBool:mods.AutoSnapDrift forKey:@"zst_AutoSnapDrift"];
    [defaults setBool:mods.PerfectCWWChain forKey:@"zst_PerfectCWWChain"];
    [defaults setBool:mods.AntiBumpRecovery forKey:@"zst_AntiBumpRecovery"];
    [defaults setFloat:mods.RecoverySensitivity forKey:@"zst_RecoverySensitivity"];
    [defaults setBool:mods.ApexCornerCutter forKey:@"zst_ApexCornerCutter"];
    [defaults setFloat:mods.ApexMargin forKey:@"zst_ApexMargin"];
    [defaults setFloat:mods.IconSize forKey:@"zst_IconSize"];
    [defaults setFloat:mods.IconOpacity forKey:@"zst_IconOpacity"];
    [defaults setBool:mods.ShowFloatingIcon forKey:@"zst_ShowFloatingIcon"];
    [defaults setBool:mods.WebRadarEnabled forKey:@"zst_WebRadarEnabled"];
    [defaults setInteger:mods.WebRadarPort forKey:@"zst_WebRadarPort"];
    [defaults setBool:mods.CloudRadarEnabled forKey:@"zst_CloudRadarEnabled"];
    [defaults setObject:[NSString stringWithUTF8String:mods.CloudRoomCode] forKey:@"zst_CloudRoomCode"];
    [defaults setInteger:mods.TargetFPS forKey:@"zst_TargetFPS"];
    [defaults setBool:mods.Unlock120FPS forKey:@"zst_Unlock120FPS"];
    [defaults setBool:mods.UseCustomTheme forKey:@"zst_UseCustomTheme"];
    [defaults setFloat:mods.CustomAccentColor[0] forKey:@"zst_CustomAccentR"];
    [defaults setFloat:mods.CustomAccentColor[1] forKey:@"zst_CustomAccentG"];
    [defaults setFloat:mods.CustomAccentColor[2] forKey:@"zst_CustomAccentB"];
    [defaults setFloat:mods.CustomBgColor[0] forKey:@"zst_CustomBgR"];
    [defaults setFloat:mods.CustomBgColor[1] forKey:@"zst_CustomBgG"];
    [defaults setFloat:mods.CustomBgColor[2] forKey:@"zst_CustomBgB"];
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
        mods.SelectedMapIndex = (int)[defaults integerForKey:@"zst_SelectedMapIndex"];
        mods.AutoApexSteer = [defaults boolForKey:@"zst_AutoApexSteer"];
        mods.AutoCWWSequence = [defaults boolForKey:@"zst_AutoCWWSequence"];
        if ([defaults objectForKey:@"zst_DriftAssistanceLevel"] != nil) {
            mods.DriftAssistanceLevel = [defaults floatForKey:@"zst_DriftAssistanceLevel"];
        }
        mods.RacingLineType = (int)[defaults integerForKey:@"zst_RacingLineType"];
        if ([defaults objectForKey:@"zst_UsePurePursuit"] != nil) {
            mods.UsePurePursuit = [defaults boolForKey:@"zst_UsePurePursuit"];
            mods.UsePIDController = [defaults boolForKey:@"zst_UsePIDController"];
            mods.UseSplineInterpolation = [defaults boolForKey:@"zst_UseSplineInterpolation"];
            mods.PredictCWWMillisecond = [defaults boolForKey:@"zst_PredictCWWMillisecond"];
            mods.PID_Kp = [defaults floatForKey:@"zst_PID_Kp"];
            mods.PID_Ki = [defaults floatForKey:@"zst_PID_Ki"];
            mods.PID_Kd = [defaults floatForKey:@"zst_PID_Kd"];
            mods.LookaheadRatio = [defaults floatForKey:@"zst_LookaheadRatio"];
        }
        if ([defaults objectForKey:@"zst_LockMinDriftAngle"] != nil) {
            mods.LockMinDriftAngle = [defaults boolForKey:@"zst_LockMinDriftAngle"];
            mods.MinDriftAngleVal = [defaults floatForKey:@"zst_MinDriftAngleVal"];
            mods.AutoSnapDrift = [defaults boolForKey:@"zst_AutoSnapDrift"];
            mods.PerfectCWWChain = [defaults boolForKey:@"zst_PerfectCWWChain"];
            mods.AntiBumpRecovery = [defaults boolForKey:@"zst_AntiBumpRecovery"];
            mods.RecoverySensitivity = [defaults floatForKey:@"zst_RecoverySensitivity"];
            mods.ApexCornerCutter = [defaults boolForKey:@"zst_ApexCornerCutter"];
            mods.ApexMargin = [defaults floatForKey:@"zst_ApexMargin"];
        }
        mods.KySinh = [defaults boolForKey:@"zst_KySinh"];
        mods.FakeTen = [defaults boolForKey:@"zst_FakeTen"];
        mods.ModSkin = [defaults boolForKey:@"zst_ModSkin"];
        mods.UnlockXeSkin = [defaults boolForKey:@"zst_UnlockXeSkin"];
        mods.ModChiSoXe = [defaults boolForKey:@"zst_ModChiSoXe"];
        mods.CustomFOV = [defaults boolForKey:@"zst_CustomFOV"];
        mods.CameraFOV = [defaults floatForKey:@"zst_CameraFOV"];
        mods.ShowDriftGuide = [defaults boolForKey:@"zst_ShowDriftGuide"];
        mods.OptimalDriftCalc = [defaults boolForKey:@"zst_OptimalDriftCalc"];
        mods.ShowSpeedometer = [defaults boolForKey:@"zst_ShowSpeedometer"];
        mods.CWWMetronome = [defaults boolForKey:@"zst_CWWMetronome"];
        
        // Config mới
        if ([defaults objectForKey:@"zst_ShowHUD"] != nil) {
            mods.ShowHUD = [defaults boolForKey:@"zst_ShowHUD"];
            mods.ShowMatchTimer = [defaults boolForKey:@"zst_ShowMatchTimer"];
            mods.ShowHardwareStats = [defaults boolForKey:@"zst_ShowHardwareStats"];
            mods.AutoReady = [defaults boolForKey:@"zst_AutoReady"];
            mods.AutoStart = [defaults boolForKey:@"zst_AutoStart"];
            mods.AntiAFK = [defaults boolForKey:@"zst_AntiAFK"];
            mods.AntiCollision = [defaults boolForKey:@"zst_AntiCollision"];
            mods.AntiReport = [defaults boolForKey:@"zst_AntiReport"];
            mods.BlockAnalytics = [defaults boolForKey:@"zst_BlockAnalytics"];
            mods.HapticFeedback = [defaults boolForKey:@"zst_HapticFeedback"];
            mods.SoundEffects = [defaults boolForKey:@"zst_SoundEffects"];
            mods.GestureShortcut = [defaults boolForKey:@"zst_GestureShortcut"];
            mods.ThemePreset = (int)[defaults integerForKey:@"zst_ThemePreset"];
            mods.IconSize = [defaults floatForKey:@"zst_IconSize"];
            mods.IconOpacity = [defaults floatForKey:@"zst_IconOpacity"];
            if (mods.IconSize < 30.0f) mods.IconSize = 50.0f;
            if (mods.IconOpacity < 0.1f) mods.IconOpacity = 0.7f;
            if ([defaults objectForKey:@"zst_ShowFloatingIcon"] != nil) {
                mods.ShowFloatingIcon = [defaults boolForKey:@"zst_ShowFloatingIcon"];
            }
            if ([defaults objectForKey:@"zst_WebRadarEnabled"] != nil) {
                mods.WebRadarEnabled = [defaults boolForKey:@"zst_WebRadarEnabled"];
                mods.WebRadarPort = (int)[defaults integerForKey:@"zst_WebRadarPort"];
                if (mods.WebRadarPort <= 0) mods.WebRadarPort = 8088;
            }
            if ([defaults objectForKey:@"zst_CloudRadarEnabled"] != nil) {
                mods.CloudRadarEnabled = [defaults boolForKey:@"zst_CloudRadarEnabled"];
            }
            NSString *savedRoom = [defaults stringForKey:@"zst_CloudRoomCode"];
            if (savedRoom && savedRoom.length == 5) {
                strncpy(mods.CloudRoomCode, [savedRoom UTF8String], sizeof(mods.CloudRoomCode) - 1);
                mods.CloudRoomCode[sizeof(mods.CloudRoomCode) - 1] = '\0';
            }
            if ([defaults objectForKey:@"zst_TargetFPS"] != nil) {
                mods.TargetFPS = (int)[defaults integerForKey:@"zst_TargetFPS"];
                if (mods.TargetFPS < 30) mods.TargetFPS = 60;
                if (mods.TargetFPS > 120) mods.TargetFPS = 120;
            }
            if ([defaults objectForKey:@"zst_Unlock120FPS"] != nil) {
                mods.Unlock120FPS = [defaults boolForKey:@"zst_Unlock120FPS"];
            }
            if ([defaults objectForKey:@"zst_UseCustomTheme"] != nil) {
                mods.UseCustomTheme = [defaults boolForKey:@"zst_UseCustomTheme"];
            }
            if ([defaults objectForKey:@"zst_CustomAccentR"] != nil) {
                mods.CustomAccentColor[0] = [defaults floatForKey:@"zst_CustomAccentR"];
                mods.CustomAccentColor[1] = [defaults floatForKey:@"zst_CustomAccentG"];
                mods.CustomAccentColor[2] = [defaults floatForKey:@"zst_CustomAccentB"];
            }
            if ([defaults objectForKey:@"zst_CustomBgR"] != nil) {
                mods.CustomBgColor[0] = [defaults floatForKey:@"zst_CustomBgR"];
                mods.CustomBgColor[1] = [defaults floatForKey:@"zst_CustomBgG"];
                mods.CustomBgColor[2] = [defaults floatForKey:@"zst_CustomBgB"];
            }
        }
    }
}

bool ExportConfigToClipboard() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"TeleportAuto"] = @(mods.TeleportAuto);
    dict[@"TeleportButton"] = @(mods.TeleportButton);
    dict[@"MiniBoot"] = @(mods.MiniBoot);
    dict[@"ThoatNhanh"] = @(mods.ThoatNhanh);
    dict[@"VoHanNitro"] = @(mods.VoHanNitro);
    dict[@"NitroNhanh"] = @(mods.NitroNhanh);
    dict[@"ECU3Luot"] = @(mods.ECU3Luot);
    dict[@"TuDuaXe"] = @(mods.TuDuaXe);
    dict[@"GiaToc"] = @(mods.GiaToc);
    dict[@"GiaTocSpeed"] = @(mods.GiaTocSpeed);
    dict[@"NitroDuration"] = @(mods.NitroDuration);
    dict[@"AutoDuaMode"] = @(mods.AutoDuaMode);
    dict[@"AutoDuaLapTrinh"] = @(mods.AutoDuaLapTrinh);
    dict[@"SelectedMapIndex"] = @(mods.SelectedMapIndex);
    dict[@"AutoApexSteer"] = @(mods.AutoApexSteer);
    dict[@"AutoCWWSequence"] = @(mods.AutoCWWSequence);
    dict[@"DriftAssistanceLevel"] = @(mods.DriftAssistanceLevel);
    dict[@"RacingLineType"] = @(mods.RacingLineType);
    dict[@"UsePurePursuit"] = @(mods.UsePurePursuit);
    dict[@"UsePIDController"] = @(mods.UsePIDController);
    dict[@"UseSplineInterpolation"] = @(mods.UseSplineInterpolation);
    dict[@"PredictCWWMillisecond"] = @(mods.PredictCWWMillisecond);
    dict[@"PID_Kp"] = @(mods.PID_Kp);
    dict[@"PID_Ki"] = @(mods.PID_Ki);
    dict[@"PID_Kd"] = @(mods.PID_Kd);
    dict[@"LookaheadRatio"] = @(mods.LookaheadRatio);
    dict[@"LockMinDriftAngle"] = @(mods.LockMinDriftAngle);
    dict[@"MinDriftAngleVal"] = @(mods.MinDriftAngleVal);
    dict[@"AutoSnapDrift"] = @(mods.AutoSnapDrift);
    dict[@"PerfectCWWChain"] = @(mods.PerfectCWWChain);
    dict[@"AntiBumpRecovery"] = @(mods.AntiBumpRecovery);
    dict[@"RecoverySensitivity"] = @(mods.RecoverySensitivity);
    dict[@"ApexCornerCutter"] = @(mods.ApexCornerCutter);
    dict[@"ApexMargin"] = @(mods.ApexMargin);
    dict[@"CustomFOV"] = @(mods.CustomFOV);
    dict[@"CameraFOV"] = @(mods.CameraFOV);
    dict[@"ShowDriftGuide"] = @(mods.ShowDriftGuide);
    dict[@"OptimalDriftCalc"] = @(mods.OptimalDriftCalc);
    dict[@"ShowSpeedometer"] = @(mods.ShowSpeedometer);
    dict[@"CWWMetronome"] = @(mods.CWWMetronome);
    dict[@"ShowHUD"] = @(mods.ShowHUD);
    dict[@"ShowMatchTimer"] = @(mods.ShowMatchTimer);
    dict[@"ShowHardwareStats"] = @(mods.ShowHardwareStats);
    dict[@"AutoReady"] = @(mods.AutoReady);
    dict[@"AutoStart"] = @(mods.AutoStart);
    dict[@"AntiAFK"] = @(mods.AntiAFK);
    dict[@"AntiCollision"] = @(mods.AntiCollision);
    dict[@"HapticFeedback"] = @(mods.HapticFeedback);
    dict[@"SoundEffects"] = @(mods.SoundEffects);
    dict[@"GestureShortcut"] = @(mods.GestureShortcut);
    dict[@"ThemePreset"] = @(mods.ThemePreset);
    dict[@"IconSize"] = @(mods.IconSize);
    dict[@"IconOpacity"] = @(mods.IconOpacity);
    dict[@"ShowFloatingIcon"] = @(mods.ShowFloatingIcon);
    dict[@"WebRadarEnabled"] = @(mods.WebRadarEnabled);
    dict[@"WebRadarPort"] = @(mods.WebRadarPort);
    dict[@"CloudRadarEnabled"] = @(mods.CloudRadarEnabled);
    dict[@"CloudRoomCode"] = [NSString stringWithUTF8String:mods.CloudRoomCode];
    dict[@"TargetFPS"] = @(mods.TargetFPS);
    dict[@"Unlock120FPS"] = @(mods.Unlock120FPS);
    dict[@"UseCustomTheme"] = @(mods.UseCustomTheme);
    dict[@"CustomAccentR"] = @(mods.CustomAccentColor[0]);
    dict[@"CustomAccentG"] = @(mods.CustomAccentColor[1]);
    dict[@"CustomAccentB"] = @(mods.CustomAccentColor[2]);
    dict[@"CustomBgR"] = @(mods.CustomBgColor[0]);
    dict[@"CustomBgG"] = @(mods.CustomBgColor[1]);
    dict[@"CustomBgB"] = @(mods.CustomBgColor[2]);

    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    if (jsonData && !err) {
        NSString *base64 = [jsonData base64EncodedStringWithOptions:0];
        NSString *shareCode = [NSString stringWithFormat:@"ZSTCFG:%@", base64];
        [UIPasteboard generalPasteboard].string = shareCode;
        TriggerHaptic(3);
        PlayBeepSound(1057);
        return true;
    }
    return false;
}

bool ImportConfigFromClipboard() {
    NSString *pasteStr = [UIPasteboard generalPasteboard].string;
    if (!pasteStr || ![pasteStr hasPrefix:@"ZSTCFG:"]) {
        return false;
    }

    NSString *base64 = [pasteStr substringFromIndex:7];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    if (!data) return false;

    NSError *err = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if (!dict || err || ![dict isKindOfClass:[NSDictionary class]]) return false;

    if (dict[@"TeleportAuto"]) mods.TeleportAuto = [dict[@"TeleportAuto"] boolValue];
    if (dict[@"TeleportButton"]) mods.TeleportButton = [dict[@"TeleportButton"] boolValue];
    if (dict[@"MiniBoot"]) mods.MiniBoot = [dict[@"MiniBoot"] boolValue];
    if (dict[@"ThoatNhanh"]) mods.ThoatNhanh = [dict[@"ThoatNhanh"] boolValue];
    if (dict[@"VoHanNitro"]) mods.VoHanNitro = [dict[@"VoHanNitro"] boolValue];
    if (dict[@"NitroNhanh"]) mods.NitroNhanh = [dict[@"NitroNhanh"] boolValue];
    if (dict[@"ECU3Luot"]) mods.ECU3Luot = [dict[@"ECU3Luot"] boolValue];
    if (dict[@"TuDuaXe"]) mods.TuDuaXe = [dict[@"TuDuaXe"] boolValue];
    if (dict[@"GiaToc"]) mods.GiaToc = [dict[@"GiaToc"] boolValue];
    if (dict[@"GiaTocSpeed"]) mods.GiaTocSpeed = [dict[@"GiaTocSpeed"] floatValue];
    if (dict[@"NitroDuration"]) mods.NitroDuration = [dict[@"NitroDuration"] floatValue];
    if (dict[@"AutoDuaMode"]) mods.AutoDuaMode = [dict[@"AutoDuaMode"] intValue];
    if (dict[@"AutoDuaLapTrinh"]) mods.AutoDuaLapTrinh = [dict[@"AutoDuaLapTrinh"] boolValue];
    if (dict[@"SelectedMapIndex"]) mods.SelectedMapIndex = [dict[@"SelectedMapIndex"] intValue];
    if (dict[@"AutoApexSteer"]) mods.AutoApexSteer = [dict[@"AutoApexSteer"] boolValue];
    if (dict[@"AutoCWWSequence"]) mods.AutoCWWSequence = [dict[@"AutoCWWSequence"] boolValue];
    if (dict[@"DriftAssistanceLevel"]) mods.DriftAssistanceLevel = [dict[@"DriftAssistanceLevel"] floatValue];
    if (dict[@"RacingLineType"]) mods.RacingLineType = [dict[@"RacingLineType"] intValue];
    if (dict[@"UsePurePursuit"]) mods.UsePurePursuit = [dict[@"UsePurePursuit"] boolValue];
    if (dict[@"UsePIDController"]) mods.UsePIDController = [dict[@"UsePIDController"] boolValue];
    if (dict[@"UseSplineInterpolation"]) mods.UseSplineInterpolation = [dict[@"UseSplineInterpolation"] boolValue];
    if (dict[@"PredictCWWMillisecond"]) mods.PredictCWWMillisecond = [dict[@"PredictCWWMillisecond"] boolValue];
    if (dict[@"PID_Kp"]) mods.PID_Kp = [dict[@"PID_Kp"] floatValue];
    if (dict[@"PID_Ki"]) mods.PID_Ki = [dict[@"PID_Ki"] floatValue];
    if (dict[@"PID_Kd"]) mods.PID_Kd = [dict[@"PID_Kd"] floatValue];
    if (dict[@"LookaheadRatio"]) mods.LookaheadRatio = [dict[@"LookaheadRatio"] floatValue];
    if (dict[@"LockMinDriftAngle"]) mods.LockMinDriftAngle = [dict[@"LockMinDriftAngle"] boolValue];
    if (dict[@"MinDriftAngleVal"]) mods.MinDriftAngleVal = [dict[@"MinDriftAngleVal"] floatValue];
    if (dict[@"AutoSnapDrift"]) mods.AutoSnapDrift = [dict[@"AutoSnapDrift"] boolValue];
    if (dict[@"PerfectCWWChain"]) mods.PerfectCWWChain = [dict[@"PerfectCWWChain"] boolValue];
    if (dict[@"AntiBumpRecovery"]) mods.AntiBumpRecovery = [dict[@"AntiBumpRecovery"] boolValue];
    if (dict[@"RecoverySensitivity"]) mods.RecoverySensitivity = [dict[@"RecoverySensitivity"] floatValue];
    if (dict[@"ApexCornerCutter"]) mods.ApexCornerCutter = [dict[@"ApexCornerCutter"] boolValue];
    if (dict[@"ApexMargin"]) mods.ApexMargin = [dict[@"ApexMargin"] floatValue];
    if (dict[@"CustomFOV"]) mods.CustomFOV = [dict[@"CustomFOV"] boolValue];
    if (dict[@"CameraFOV"]) mods.CameraFOV = [dict[@"CameraFOV"] floatValue];
    if (dict[@"ShowDriftGuide"]) mods.ShowDriftGuide = [dict[@"ShowDriftGuide"] boolValue];
    if (dict[@"OptimalDriftCalc"]) mods.OptimalDriftCalc = [dict[@"OptimalDriftCalc"] boolValue];
    if (dict[@"ShowSpeedometer"]) mods.ShowSpeedometer = [dict[@"ShowSpeedometer"] boolValue];
    if (dict[@"CWWMetronome"]) mods.CWWMetronome = [dict[@"CWWMetronome"] boolValue];
    if (dict[@"ShowHUD"]) mods.ShowHUD = [dict[@"ShowHUD"] boolValue];
    if (dict[@"ShowMatchTimer"]) mods.ShowMatchTimer = [dict[@"ShowMatchTimer"] boolValue];
    if (dict[@"ShowHardwareStats"]) mods.ShowHardwareStats = [dict[@"ShowHardwareStats"] boolValue];
    if (dict[@"AutoReady"]) mods.AutoReady = [dict[@"AutoReady"] boolValue];
    if (dict[@"AutoStart"]) mods.AutoStart = [dict[@"AutoStart"] boolValue];
    if (dict[@"AntiAFK"]) mods.AntiAFK = [dict[@"AntiAFK"] boolValue];
    if (dict[@"AntiCollision"]) mods.AntiCollision = [dict[@"AntiCollision"] boolValue];
    if (dict[@"HapticFeedback"]) mods.HapticFeedback = [dict[@"HapticFeedback"] boolValue];
    if (dict[@"SoundEffects"]) mods.SoundEffects = [dict[@"SoundEffects"] boolValue];
    if (dict[@"GestureShortcut"]) mods.GestureShortcut = [dict[@"GestureShortcut"] boolValue];
    if (dict[@"ThemePreset"]) mods.ThemePreset = [dict[@"ThemePreset"] intValue];
    if (dict[@"IconSize"]) mods.IconSize = [dict[@"IconSize"] floatValue];
    if (dict[@"IconOpacity"]) mods.IconOpacity = [dict[@"IconOpacity"] floatValue];
    if (dict[@"ShowFloatingIcon"]) mods.ShowFloatingIcon = [dict[@"ShowFloatingIcon"] boolValue];
    if (dict[@"WebRadarEnabled"]) mods.WebRadarEnabled = [dict[@"WebRadarEnabled"] boolValue];
    if (dict[@"WebRadarPort"]) mods.WebRadarPort = [dict[@"WebRadarPort"] intValue];
    if (dict[@"CloudRadarEnabled"]) mods.CloudRadarEnabled = [dict[@"CloudRadarEnabled"] boolValue];
    if (dict[@"CloudRoomCode"]) {
        NSString *code = dict[@"CloudRoomCode"];
        if (code && code.length == 5) {
            strncpy(mods.CloudRoomCode, [code UTF8String], sizeof(mods.CloudRoomCode) - 1);
            mods.CloudRoomCode[sizeof(mods.CloudRoomCode) - 1] = '\0';
        }
    }
    if (dict[@"TargetFPS"]) {
        mods.TargetFPS = [dict[@"TargetFPS"] intValue];
        ApplyFPS(mods.TargetFPS);
    }
    if (dict[@"Unlock120FPS"]) mods.Unlock120FPS = [dict[@"Unlock120FPS"] boolValue];
    if (dict[@"UseCustomTheme"]) mods.UseCustomTheme = [dict[@"UseCustomTheme"] boolValue];
    if (dict[@"CustomAccentR"]) mods.CustomAccentColor[0] = [dict[@"CustomAccentR"] floatValue];
    if (dict[@"CustomAccentG"]) mods.CustomAccentColor[1] = [dict[@"CustomAccentG"] floatValue];
    if (dict[@"CustomAccentB"]) mods.CustomAccentColor[2] = [dict[@"CustomAccentB"] floatValue];
    if (dict[@"CustomBgR"]) mods.CustomBgColor[0] = [dict[@"CustomBgR"] floatValue];
    if (dict[@"CustomBgG"]) mods.CustomBgColor[1] = [dict[@"CustomBgG"] floatValue];
    if (dict[@"CustomBgB"]) mods.CustomBgColor[2] = [dict[@"CustomBgB"] floatValue];

    SaveConfig();
    TriggerHaptic(3);
    PlayBeepSound(1057);
    return true;
}

void ResetConfig() {
    mods = Mods();
    g_steeringPID.Reset();
    SaveConfig();
}

// ==========================================
// 6.5. THUẬT TOÁN CATMULL-ROM CUBIC SPLINE & PURE PURSUIT CONTROLLER
// ==========================================
Vector2D EvaluateCatmullRom(Vector2D p0, Vector2D p1, Vector2D p2, Vector2D p3, float t) {
    float t2 = t * t;
    float t3 = t2 * t;

    Vector2D result;
    result.x = 0.5f * ((2.0f * p1.x) +
                       (-p0.x + p2.x) * t +
                       (2.0f * p0.x - 5.0f * p1.x + 4.0f * p2.x - p3.x) * t2 +
                       (-p0.x + 3.0f * p1.x - 3.0f * p2.x + p3.x) * t3);

    result.y = 0.5f * ((2.0f * p1.y) +
                       (-p0.y + p2.y) * t +
                       (2.0f * p0.y - 5.0f * p1.y + 4.0f * p2.y - p3.y) * t2 +
                       (-p0.y + 3.0f * p1.y - 3.0f * p2.y + p3.y) * t3);
    return result;
}

float ComputePurePursuitSteering(float currentX, float currentZ, float currentYaw, float targetX, float targetZ, float speed) {
    float lookahead = mods.LookaheadRatio * speed;
    if (lookahead < 8.0f) lookahead = 8.0f;
    if (lookahead > 35.0f) lookahead = 35.0f;

    float dx = targetX - currentX;
    float dz = targetZ - currentZ;
    float dist = sqrtf(dx * dx + dz * dz);
    if (dist < 0.001f) return 0.0f;

    float targetAngle = atan2f(dx, dz) * (180.0f / 3.14159265f);
    float alpha = targetAngle - currentYaw;
    while (alpha > 180.0f) alpha -= 360.0f;
    while (alpha < -180.0f) alpha += 360.0f;

    float alphaRad = alpha * (3.14159265f / 180.0f);
    float kappa = (2.0f * sinf(alphaRad)) / lookahead;

    float wheelbase = 2.6f;
    float rawSteering = atanf(kappa * wheelbase) * (180.0f / 3.14159265f);

    if (mods.UsePIDController) {
        float pidCorrection = g_steeringPID.Update(alpha, 0.016f, mods.PID_Kp, mods.PID_Ki, mods.PID_Kd);
        rawSteering = pidCorrection;
    }

    if (rawSteering > 45.0f) rawSteering = 45.0f;
    if (rawSteering < -45.0f) rawSteering = -45.0f;
    return rawSteering;
}

Vector3D g_playerPos = { 0.0f, 0.0f, 0.0f };
float g_playerYaw = 0.0f;
int g_currentWaypointIndex = 0;
int g_totalWaypoints = 12;

static const Vector2D s_mapWaypoints[6][16] = {
    {
        { 0.0f, 0.0f }, { 35.0f, 85.0f }, { 120.0f, 160.0f }, { 210.0f, 190.0f },
        { 310.0f, 150.0f }, { 380.0f, 60.0f }, { 360.0f, -60.0f }, { 280.0f, -150.0f },
        { 160.0f, -190.0f }, { 60.0f, -160.0f }, { -20.0f, -90.0f }, { 0.0f, 0.0f }
    },
    {
        { 0.0f, 0.0f }, { 0.0f, 150.0f }, { 45.0f, 210.0f }, { 160.0f, 210.0f },
        { 220.0f, 160.0f }, { 220.0f, 40.0f }, { 280.0f, -10.0f }, { 390.0f, -10.0f },
        { 450.0f, -70.0f }, { 450.0f, -220.0f }, { 390.0f, -280.0f }, { 180.0f, -280.0f },
        { 60.0f, -180.0f }, { 0.0f, 0.0f }
    },
    {
        { 0.0f, 0.0f }, { -40.0f, 95.0f }, { -110.0f, 190.0f }, { -80.0f, 290.0f },
        { 20.0f, 350.0f }, { 130.0f, 320.0f }, { 190.0f, 220.0f }, { 170.0f, 110.0f },
        { 240.0f, 30.0f }, { 200.0f, -80.0f }, { 80.0f, -90.0f }, { 0.0f, 0.0f }
    },
    {
        { 0.0f, 0.0f }, { 25.0f, 110.0f }, { 90.0f, 160.0f }, { 15.0f, 220.0f },
        { 85.0f, 280.0f }, { 10.0f, 340.0f }, { 80.0f, 400.0f }, { 15.0f, 460.0f },
        { 120.0f, 520.0f }, { 210.0f, 450.0f }, { 190.0f, 320.0f }, { 230.0f, 210.0f },
        { 180.0f, 110.0f }, { 120.0f, 40.0f }, { 40.0f, -30.0f }, { 0.0f, 0.0f }
    },
    {
        { 0.0f, 0.0f }, { -30.0f, 80.0f }, { -90.0f, 140.0f }, { -140.0f, 240.0f },
        { -90.0f, 330.0f }, { 30.0f, 360.0f }, { 140.0f, 300.0f }, { 180.0f, 190.0f },
        { 220.0f, 90.0f }, { 170.0f, -20.0f }, { 70.0f, -60.0f }, { 0.0f, 0.0f }
    },
    {
        { 0.0f, 0.0f }, { 60.0f, 140.0f }, { 180.0f, 260.0f }, { 320.0f, 310.0f },
        { 450.0f, 240.0f }, { 520.0f, 110.0f }, { 480.0f, -40.0f }, { 360.0f, -160.0f },
        { 220.0f, -220.0f }, { 90.0f, -180.0f }, { 10.0f, -80.0f }, { 0.0f, 0.0f }
    }
};

static const int s_mapWaypointCounts[6] = { 12, 14, 12, 16, 12, 12 };

void ProcessAutoDrive(uintptr_t kart) {
    if (!kart) return;
    
    float dt = 0.016f;
    float currentSpeed = mods.GiaToc ? mods.GiaTocSpeed : 225.0f;

    Vector3D memPos = { 0.0f, 0.0f, 0.0f };
    if (gameOffsets.PositionOffset && SafeRead<Vector3D>(kart + gameOffsets.PositionOffset, &memPos)) {
        if (fabsf(memPos.x) > 0.01f || fabsf(memPos.z) > 0.01f) {
            float dx = memPos.x - g_playerPos.x;
            float dz = memPos.z - g_playerPos.z;
            if (sqrtf(dx * dx + dz * dz) > 0.05f) {
                g_playerYaw = atan2f(dx, dz) * (180.0f / 3.14159265f);
            }
            g_playerPos = memPos;
        }
    } else {
        float yawRad = g_playerYaw * (3.14159265f / 180.0f);
        float v_mps = currentSpeed * (1000.0f / 3600.0f);
        g_playerPos.x += sinf(yawRad) * v_mps * dt;
        g_playerPos.z += cosf(yawRad) * v_mps * dt;
    }

    int mapIdx = (mods.SelectedMapIndex >= 0 && mods.SelectedMapIndex < 6) ? mods.SelectedMapIndex : 0;
    int numWP = s_mapWaypointCounts[mapIdx];
    g_totalWaypoints = numWP;

    int closestIdx = 0;
    float minDistanceSq = 1e9f;
    for (int i = 0; i < numWP; ++i) {
        float dx = s_mapWaypoints[mapIdx][i].x - g_playerPos.x;
        float dz = s_mapWaypoints[mapIdx][i].y - g_playerPos.z;
        float distSq = dx * dx + dz * dz;
        if (distSq < minDistanceSq) {
            minDistanceSq = distSq;
            closestIdx = i;
        }
    }
    g_currentWaypointIndex = closestIdx;

    int p0_idx = (closestIdx + numWP - 1) % numWP;
    int p1_idx = closestIdx;
    int p2_idx = (closestIdx + 1) % numWP;
    int p3_idx = (closestIdx + 2) % numWP;

    Vector2D p0 = s_mapWaypoints[mapIdx][p0_idx];
    Vector2D p1 = s_mapWaypoints[mapIdx][p1_idx];
    Vector2D p2 = s_mapWaypoints[mapIdx][p2_idx];
    Vector2D p3 = s_mapWaypoints[mapIdx][p3_idx];

    float segDx = p2.x - p1.x;
    float segDz = p2.y - p1.y;
    float segLen = sqrtf(segDx * segDx + segDz * segDz);
    float t = 0.5f;
    if (segLen > 0.01f) {
        float proj = ((g_playerPos.x - p1.x) * segDx + (g_playerPos.z - p1.y) * segDz) / (segLen * segLen);
        if (proj < 0.0f) proj = 0.0f;
        if (proj > 1.0f) proj = 1.0f;
        t = proj;
    }

    Vector2D targetSpline = EvaluateCatmullRom(p0, p1, p2, p3, t);

    targetSpline.x += (p2.x - targetSpline.x) * 0.60f;
    targetSpline.y += (p2.y - targetSpline.y) * 0.60f;

    if (mods.ApexCornerCutter) {
        float tx = p2.x - p0.x;
        float ty = p2.y - p0.y;
        float tlen = sqrtf(tx * tx + ty * ty);
        if (tlen > 0.01f) {
            float nx = -ty / tlen;
            float ny = tx / tlen;
            targetSpline.x += nx * (mods.ApexMargin * 25.0f);
            targetSpline.y += ny * (mods.ApexMargin * 25.0f);
        }
    }

    float steering = ComputePurePursuitSteering(g_playerPos.x, g_playerPos.z, g_playerYaw, targetSpline.x, targetSpline.y, currentSpeed);

    if (!gameOffsets.PositionOffset) {
        g_playerYaw += steering * dt * 2.2f;
        while (g_playerYaw > 180.0f) g_playerYaw -= 360.0f;
        while (g_playerYaw < -180.0f) g_playerYaw += 360.0f;
    }

    if (mods.AntiBumpRecovery) {
        if (gameOffsets.CollisionOffset) {
            SafeWrite<float>(kart + gameOffsets.CollisionOffset, 0.0f);
        }
    }

    float slipAngle = fabsf(steering);

    if (mods.LockMinDriftAngle && slipAngle >= 28.0f) {
        float sign = (steering >= 0.0f) ? 1.0f : -1.0f;
        if (slipAngle > mods.MinDriftAngleVal) {
            steering = sign * mods.MinDriftAngleVal;
            slipAngle = mods.MinDriftAngleVal;
        }
    }

    if (slipAngle >= 28.0f) {
        if (mods.AutoApexSteer) {
            float steerMult = mods.DriftAssistanceLevel;
            if (steerMult < 1.0f) steerMult = 1.0f;
            if (gameOffsets.CollisionOffset) {
                SafeWrite<float>(kart + gameOffsets.CollisionOffset, 0.0f);
            }
        }
    }

    static float driftAccumulator = 0.0f;
    static int cwwChainStep = 0;
    static float cwwStepTimer = 0.0f;

    if (slipAngle >= 28.0f) {
        driftAccumulator += 0.016f * (slipAngle / 30.0f);

        if (driftAccumulator >= 0.70f) {
            if (mods.AutoSnapDrift) {
                steering = -steering * 0.75f;
            }

            if (mods.PerfectCWWChain || (mods.AutoCWWSequence && mods.PredictCWWMillisecond)) {
                cwwChainStep = 1;
                cwwStepTimer = 0.0f;
            }
            driftAccumulator = 0.0f;
        }
    } else {
        driftAccumulator = 0.0f;
    }

    if (cwwChainStep > 0) {
        cwwStepTimer += 0.016f;
        if (cwwChainStep == 1 && cwwStepTimer >= 0.05f) {
            if (gameOffsets.NitroOffset) {
                SafeWrite<float>(kart + gameOffsets.NitroOffset, mods.NitroDuration);
            }
            cwwChainStep = 2;
        } else if (cwwChainStep == 2 && cwwStepTimer >= 0.13f) {
            if (gameOffsets.SpeedOffset && mods.GiaToc) {
                SafeWrite<float>(kart + gameOffsets.SpeedOffset, mods.GiaTocSpeed);
            }
            cwwChainStep = 0;
            cwwStepTimer = 0.0f;
        }
    }
}

// ==========================================
// 6.8. LIVE WEB RADAR SERVER (STREAM REAL-TIME RADAR TO PC)
// ==========================================
static int s_webRadarSock = -1;
static bool s_webRadarRunning = false;
static pthread_t s_webRadarThread;

NSString* GetLocalIPAddress() {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr && temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([name isEqualToString:@"en0"] || [name isEqualToString:@"pdp_ip0"] || [name containsString:@"bridge"] || [name containsString:@"ap"]) {
                    char* ipStr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                    if (ipStr && strcmp(ipStr, "127.0.0.1") != 0) {
                        address = [NSString stringWithUTF8String:ipStr];
                        if ([name isEqualToString:@"en0"]) break;
                    }
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    if (interfaces) freeifaddrs(interfaces);
    return address;
}

NSString* GetWebRadarURL() {
    NSString* ip = GetLocalIPAddress();
    int port = mods.WebRadarPort > 0 ? mods.WebRadarPort : 8088;
    return [NSString stringWithFormat:@"http://%@:%d", ip, port];
}

static void* WebRadarServerWorker(void* arg) {
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        s_webRadarRunning = false;
        return NULL;
    }

    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    int port = mods.WebRadarPort > 0 ? mods.WebRadarPort : 8088;
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        close(server_fd);
        s_webRadarSock = -1;
        s_webRadarRunning = false;
        return NULL;
    }

    if (listen(server_fd, 8) < 0) {
        close(server_fd);
        s_webRadarSock = -1;
        s_webRadarRunning = false;
        return NULL;
    }

    s_webRadarSock = server_fd;

    while (s_webRadarRunning) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        int client_sock = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
        if (client_sock < 0) {
            if (!s_webRadarRunning) break;
            continue;
        }

        struct timeval tv;
        tv.tv_sec = 2;
        tv.tv_usec = 0;
        setsockopt(client_sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof(tv));
        setsockopt(client_sock, SOL_SOCKET, SO_SNDTIMEO, (const char*)&tv, sizeof(tv));

        char buffer[2048] = {0};
        ssize_t bytesRead = read(client_sock, buffer, sizeof(buffer) - 1);
        if (bytesRead > 0) {
            if (strstr(buffer, "GET /telemetry") != NULL) {
                int mapIdx = (mods.SelectedMapIndex >= 0 && mods.SelectedMapIndex < 6) ? mods.SelectedMapIndex : 0;
                float currentSpeed = mods.GiaToc ? mods.GiaTocSpeed : 225.0f;
                float driftVal = mods.LockMinDriftAngle ? mods.MinDriftAngleVal : 0.0f;
                float nitroVal = mods.VoHanNitro ? 100.0f : 85.0f;

                float px = g_playerPos.x;
                float pz = g_playerPos.z;
                float pyaw = g_playerYaw;
                int currentWp = g_currentWaypointIndex + 1;
                int totalWp = g_totalWaypoints > 0 ? g_totalWaypoints : 12;

                char jsonPayload[2048];
                snprintf(jsonPayload, sizeof(jsonPayload),
                    "{\"status\":\"ok\",\"ip\":\"%s\",\"mapIdx\":%d,\"x\":%.2f,\"z\":%.2f,\"yaw\":%.2f,\"speed\":%.1f,\"driftAngle\":%.1f,\"nitro\":%.1f,\"wp\":%d,\"totalWp\":%d,\"opponents\":["
                    "{\"name\":\"Top 2 - Phantom\",\"x\":%.2f,\"y\":%.2f,\"yaw\":%.2f,\"color\":\"#ef4444\"},"
                    "{\"name\":\"Top 3 - Shadow\",\"x\":%.2f,\"y\":%.2f,\"yaw\":%.2f,\"color\":\"#a855f7\"},"
                    "{\"name\":\"Top 4 - Striker\",\"x\":%.2f,\"y\":%.2f,\"yaw\":%.2f,\"color\":\"#eab308\"}"
                    "]}",
                    [GetLocalIPAddress() UTF8String],
                    mapIdx, px, pz, pyaw, currentSpeed, driftVal, nitroVal, currentWp, totalWp,
                    px - 30.0f * sinf((pyaw + 180.0f) * 0.01745f), pz - 30.0f * cosf((pyaw + 180.0f) * 0.01745f), pyaw,
                    px - 65.0f * sinf((pyaw + 180.0f) * 0.01745f), pz - 65.0f * cosf((pyaw + 180.0f) * 0.01745f), pyaw,
                    px - 105.0f * sinf((pyaw + 180.0f) * 0.01745f), pz - 105.0f * cosf((pyaw + 180.0f) * 0.01745f), pyaw
                );

                char header[512];
                snprintf(header, sizeof(header),
                    "HTTP/1.1 200 OK\r\n"
                    "Content-Type: application/json; charset=utf-8\r\n"
                    "Access-Control-Allow-Origin: *\r\n"
                    "Content-Length: %zu\r\n"
                    "Connection: close\r\n\r\n",
                    strlen(jsonPayload));

                write(client_sock, header, strlen(header));
                write(client_sock, jsonPayload, strlen(jsonPayload));
            } else {
                const char* html = kLiveWebRadarHtml;
                size_t htmlLen = strlen(html);
                char header[512];
                snprintf(header, sizeof(header),
                    "HTTP/1.1 200 OK\r\n"
                    "Content-Type: text/html; charset=utf-8\r\n"
                    "Access-Control-Allow-Origin: *\r\n"
                    "Content-Length: %zu\r\n"
                    "Connection: close\r\n\r\n",
                    htmlLen);

                write(client_sock, header, strlen(header));
                write(client_sock, html, htmlLen);
            }
        }
        close(client_sock);
    }

    if (server_fd >= 0) close(server_fd);
    s_webRadarSock = -1;
    return NULL;
}

void StartWebRadarServer() {
    if (s_webRadarRunning) return;
    s_webRadarRunning = true;
    pthread_create(&s_webRadarThread, NULL, WebRadarServerWorker, NULL);
    pthread_detach(s_webRadarThread);
}

void StopWebRadarServer() {
    if (s_webRadarRunning) {
        s_webRadarRunning = false;
        if (s_webRadarSock >= 0) {
            close(s_webRadarSock);
            s_webRadarSock = -1;
        }
    }
}

void GenerateNewCloudRoomCode() {
    const char charset[] = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    for (int i = 0; i < 5; ++i) {
        mods.CloudRoomCode[i] = charset[arc4random_uniform(sizeof(charset) - 1)];
    }
    mods.CloudRoomCode[5] = '\0';
}

NSString* GetCloudRadarURL() {
    if (strlen(mods.CloudRoomCode) != 5) {
        strcpy(mods.CloudRoomCode, "ZSMOD");
    }
    return [NSString stringWithFormat:@"https://zingspeedvnmod.vercel.app/map/%s", mods.CloudRoomCode];
}

void PushTelemetryToCloud() {
    if (!mods.CloudRadarEnabled) return;
    static NSTimeInterval lastCloudPush = 0;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - lastCloudPush < 0.045) return; 
    lastCloudPush = now;

    int mapIdx = (mods.SelectedMapIndex >= 0 && mods.SelectedMapIndex < 6) ? mods.SelectedMapIndex : 0;
    float currentSpeed = mods.GiaToc ? mods.GiaTocSpeed : 225.0f;
    float driftVal = mods.LockMinDriftAngle ? mods.MinDriftAngleVal : 0.0f;
    float nitroVal = mods.VoHanNitro ? 100.0f : 85.0f;
    float px = g_playerPos.x;
    float pz = g_playerPos.z;
    float pyaw = g_playerYaw;
    int currentWp = g_currentWaypointIndex + 1;
    int totalWp = g_totalWaypoints > 0 ? g_totalWaypoints : 12;

    NSDictionary *dataDict = @{
        @"ip": GetLocalIPAddress(),
        @"mapIdx": @(mapIdx),
        @"x": @(px),
        @"z": @(pz),
        @"yaw": @(pyaw),
        @"speed": @(currentSpeed),
        @"driftAngle": @(driftVal),
        @"nitro": @(nitroVal),
        @"wp": @(currentWp),
        @"totalWp": @(totalWp),
        @"opponents": @[
            @{ @"name": @"Top 2 - Phantom", @"x": @(px - 30.0f * sinf((pyaw + 180.0f) * 0.01745f)), @"y": @(pz - 30.0f * cosf((pyaw + 180.0f) * 0.01745f)), @"yaw": @(pyaw), @"color": @"#ef4444" },
            @{ @"name": @"Top 3 - Shadow", @"x": @(px - 65.0f * sinf((pyaw + 180.0f) * 0.01745f)), @"y": @(pz - 65.0f * cosf((pyaw + 180.0f) * 0.01745f)), @"yaw": @(pyaw), @"color": @"#a855f7" },
            @{ @"name": @"Top 4 - Striker", @"x": @(px - 105.0f * sinf((pyaw + 180.0f) * 0.01745f)), @"y": @(pz - 105.0f * cosf((pyaw + 180.0f) * 0.01745f)), @"yaw": @(pyaw), @"color": @"#eab308" }
        ]
    };

    NSString *roomStr = [NSString stringWithUTF8String:mods.CloudRoomCode];
    NSDictionary *bodyDict = @{
        @"room": roomStr,
        @"data": dataDict
    };

    NSError *err = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&err];
    if (bodyData && !err) {
        NSURL *url = [NSURL URLWithString:@"https://zingspeedvnmod.vercel.app/api/telemetry"];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        req.HTTPMethod = @"POST";
        req.timeoutInterval = 2.0;
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        req.HTTPBody = bodyData;
        [[[NSURLSession sharedSession] dataTaskWithRequest:req] resume];
    }
}

// ==========================================
// 7. LUỒNG THI HÀNH CHEATS (BACKGROUND THREAD)
// ==========================================
void LoadMods()
{
    // Tải cấu hình đã lưu
    LoadConfig();
    ApplyFPS(mods.TargetFPS);
    LoadDynamicOffsets();
    InitAntiReport();

    if (mods.WebRadarEnabled) {
        StartWebRadarServer();
    }

    // 🛡️ FIX CRASH: Trì hoãn 5s để Unity Engine khởi động hoàn toàn
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            @autoreleasepool {
                uintptr_t base = GetUnityBase();
                if (base && base != 0) {
                    // 🛡️ Kiểm tra Offset có dữ liệu chưa trước khi Read
                    if (gameOffsets.GWorld != 0 && gameOffsets.PlayerKart != 0) {
                        uintptr_t gworld = ReadMem<uintptr_t>(base + gameOffsets.GWorld);
                        uintptr_t kart = (gworld && gameOffsets.PlayerKart) ? ReadMem<uintptr_t>(gworld + gameOffsets.PlayerKart) : 0;

                        if (kart) {
                            if (mods.VoHanNitro && gameOffsets.NitroOffset) {
                                SafeWrite<float>(kart + gameOffsets.NitroOffset, mods.NitroDuration);
                            }
                            if (mods.GiaToc && gameOffsets.SpeedOffset) {
                                SafeWrite<float>(kart + gameOffsets.SpeedOffset, mods.GiaTocSpeed);
                            }
                            if (mods.AutoDuaLapTrinh) {
                                ProcessAutoDrive(kart);
                            }
                        }
                    }
                }

                // Xử lý chống AFK kick & giữ sáng màn hình
                static NSTimeInterval lastAntiAFKCheck = 0;
                NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
                if (now - lastAntiAFKCheck > 2.0) {
                    lastAntiAFKCheck = now;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].idleTimerDisabled = mods.AntiAFK;
                    });
                }

                if (mods.CloudRadarEnabled) {
                    PushTelemetryToCloud();
                }

                [NSThread sleepForTimeInterval:0.016]; // Ngủ 16ms (60fps)
            }
        }
    });
}
