// File: Mods.mm
#include "Mods.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#import <objc/runtime.h>
#include <string.h>

Mods mods;
GameOffsets gameOffsets;
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
    [defaults setFloat:mods.IconSize forKey:@"zst_IconSize"];
    [defaults setFloat:mods.IconOpacity forKey:@"zst_IconOpacity"];
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

    SaveConfig();
    TriggerHaptic(3);
    PlayBeepSound(1057);
    return true;
}

void ResetConfig() {
    mods = Mods();
    SaveConfig();
}

// ==========================================
// 7. LUỒNG THI HÀNH CHEATS (BACKGROUND THREAD)
// ==========================================
void LoadMods()
{
    // Tải cấu hình đã lưu
    LoadConfig();

    // Tự động nạp file Offsets.json trong Documents
    LoadDynamicOffsets();

    // Khởi tạo bộ chặn log / anti-report
    InitAntiReport();

    // Khởi tạo luồng chạy ngầm 60fps tối ưu
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            @autoreleasepool {
                uintptr_t base = GetUnityBase();
                if (base) {
                    // === KHU VỰC CAN THIỆP BỘ NHỚ ===
                    // Có thể sử dụng trực tiếp gameOffsets.GWorld, gameOffsets.NitroOffset, v.v.
                    uintptr_t gworld = gameOffsets.GWorld ? ReadMem<uintptr_t>(base + gameOffsets.GWorld) : 0;
                    uintptr_t kart = (gworld && gameOffsets.PlayerKart) ? ReadMem<uintptr_t>(gworld + gameOffsets.PlayerKart) : 0;

                    if (kart) {
                        if (mods.VoHanNitro && gameOffsets.NitroOffset) {
                            SafeWrite<float>(kart + gameOffsets.NitroOffset, mods.NitroDuration);
                        }
                        if (mods.GiaToc && gameOffsets.SpeedOffset) {
                            SafeWrite<float>(kart + gameOffsets.SpeedOffset, mods.GiaTocSpeed);
                        }
                    }

                    if (mods.AutoDuaLapTrinh) {
                        // Code Auto Bám Đường
                    }
                    if (mods.AntiCollision) {
                        // Code Giảm va chạm / Ổn định thân xe
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

                [NSThread sleepForTimeInterval:0.016]; // Ngủ 16ms (60fps)
            }
        }
    });
}
