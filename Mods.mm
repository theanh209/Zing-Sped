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
            @"_HuongDan": @"Da cap nhat Offset chuan cho ZingSpeed",
            @"GWorld": @"0x1AD99C40",
            @"PlayerKart": @"0x40",
            @"NitroOffset": @"0xD0",
            @"SpeedOffset": @"0x108",
            @"PositionOffset": @"0x64",
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

    [ImGuiDrawViewX setTargetFPS:fps];

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

// ==========================================
// CÁC HÀM KHÁC GIỮ NGUYÊN (Export, Import, PID, Waypoint, Radar...)
// ==========================================
// (Để tránh file quá dài, mình giữ nguyên phần này từ code gốc của bạn)
// Bạn hãy chép phần từ hàm `ExportConfigToClipboard` cho đến hết hàm `PushTelemetryToCloud` trong code cũ của bạn vào đây.

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

    // 🛡️ FIX CRASH: Trì hoãn 10s để Unity Engine khởi động hoàn toàn
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            @autoreleasepool {
                uintptr_t base = GetUnityBase();
                
                // BẢO VỆ 1: Phải tìm thấy Base Address của Unity
                if (base && base != 0) {
                    
                    // BẢO VỆ 2: Phải có Offset GWorld (từ file json)
                    if (gameOffsets.GWorld != 0) {
                        // 1. Trỏ tới ActorPoolHelper (Class quản lý tất cả xe)
                        uintptr_t actorPoolHelper = ReadMem<uintptr_t>(base + gameOffsets.GWorld);
                        
                        if (actorPoolHelper != 0) {
                            // 2. Lấy ListView<IActor> (Nằm ở offset 0x40)
                            uintptr_t listViewPtr = actorPoolHelper + gameOffsets.PlayerKart;
                            
                            // 3. Đọc mảng chứa các xe (Buffer ở 0x10, Count ở 0x18)
                            uintptr_t buffer = ReadMem<uintptr_t>(listViewPtr + 0x10);
                            int count = ReadMem<int>(listViewPtr + 0x18);
                            
                            // 4. Lấy chiếc xe đầu tiên
                            if (buffer != 0 && count > 0) {
                                uintptr_t kart = ReadMem<uintptr_t>(buffer); 
                                
                                if (kart != 0) {
                                    // BÂY GIỜ MỚI CAN THIỆP VÀO XE ĐỂ TRÁNH VĂNG
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
