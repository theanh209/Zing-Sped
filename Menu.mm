// File: Menu.mm
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#include <map>
#include <string>
#include <cmath>
#include "Menu.h"
#include "ImGui/MenuUtils.h"
#import "Includes/SCLAlertView/SCLAlertView.h"

#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

// --- BIẾN TOÀN CỤC ---
bool showLogs = false;
int ChildColor[4] = { 22, 21, 26, 255 };
int BGColor[4] = { 17, 17, 19, 255 };
int IconChildColor[4] = { 25, 26, 31, 255 };
int InactiveTextColor[4] = { 84, 82, 89, 255 };
int ActiveTextColor[4] = { 255, 255, 255, 255 };
int GrabColor[4] = { 72, 71, 78, 255 };
bool lightTheme = false;

// Fix các lỗi linker
int speed = 10; 
int animation_text = 255; 

static int PageNumber = 0; 
static bool isMenuOpen = true;
static bool isTransparentMode = false;
static bool autoDuaLapTrinh = false;

std::map<std::string, bool> childVisibilityMap;

static float columnOffset = 60.0f;
static float targetOffset = 60.0f;
float animationSpeed = 130.0f;
bool newChildVisible;
bool ToggleAnimations = false;

NSString *baseimage = @"DÁN_BASE64";

// --- STYLE & THEME ---
void SetStyles() {
    ImGuiStyle* style = &ImGui::GetStyle();
    style->WindowBorderSize = 0;
    style->WindowMinSize = ImVec2(480, 380);
    style->FrameRounding = 5.0f;
    style->GrabRounding = 5.0f;
    style->WindowRounding = 8.0f; 
    style->PopupRounding = 5.0f;
    style->ChildRounding = 8.0f;
    style->ScrollbarSize = 15;
    
    ImVec4 bgColor = isTransparentMode ? ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.4f) : ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.95f);
    ImVec4 childBg = isTransparentMode ? ImVec4(30/255.0f, 35/255.0f, 45/255.0f, 0.4f) : ImVec4(30/255.0f, 35/255.0f, 45/255.0f, 0.8f);
    
    style->Colors[ImGuiCol_WindowBg] = bgColor;
    style->Colors[ImGuiCol_ChildBg] = childBg;
    style->Colors[ImGuiCol_FrameBg] = ImColor(45, 50, 65, 180);
    style->Colors[ImGuiCol_FrameBgHovered] = ImColor(55, 60, 75, 200);
    style->Colors[ImGuiCol_FrameBgActive] = ImColor(65, 70, 85, 220);
    style->Colors[ImGuiCol_TitleBg] = ImColor(25, 30, 40, 255);
    style->Colors[ImGuiCol_TitleBgActive] = ImColor(35, 40, 50, 255);
    style->Colors[ImGuiCol_Header] = ImColor(30, 35, 45, 200);
    style->Colors[ImGuiCol_HeaderHovered] = ImColor(50, 55, 65, 220);
    style->Colors[ImGuiCol_HeaderActive] = ImColor(60, 65, 75, 240);
    style->Colors[ImGuiCol_Button] = ImColor(45, 50, 65, 180);
    style->Colors[ImGuiCol_ButtonHovered] = ImColor(60, 65, 80, 200);
    style->Colors[ImGuiCol_ButtonActive] = ImColor(70, 75, 90, 220);
    
    style->Colors[ImGuiCol_CheckMark] = ImColor(255, 255, 255, 255); 
    style->Colors[ImGuiCol_SliderGrab] = ImColor(72, 71, 78, 255);
    style->Colors[ImGuiCol_SliderGrabActive] = ImColor(138, 147, 163, 255);
}

void ApplyCustomColors(float r, float g, float b, float bgR, float bgG, float bgB) {
    mods.UseCustomTheme = true;
    mods.CustomAccentColor[0] = r; mods.CustomAccentColor[1] = g; mods.CustomAccentColor[2] = b;
    mods.CustomBgColor[0] = bgR; mods.CustomBgColor[1] = bgG; mods.CustomBgColor[2] = bgB;

    BGColor[0] = (int)(bgR * 255.0f); BGColor[1] = (int)(bgG * 255.0f); BGColor[2] = (int)(bgB * 255.0f);
    ChildColor[0] = std::min(255, (int)(bgR * 255.0f + 12)); ChildColor[1] = std::min(255, (int)(bgG * 255.0f + 12)); ChildColor[2] = std::min(255, (int)(bgB * 255.0f + 16));
    IconChildColor[0] = std::min(255, (int)(bgR * 255.0f + 20)); IconChildColor[1] = std::min(255, (int)(bgG * 255.0f + 22)); IconChildColor[2] = std::min(255, (int)(bgB * 255.0f + 28));
    ActiveTextColor[0] = (int)(r * 255.0f); ActiveTextColor[1] = (int)(g * 255.0f); ActiveTextColor[2] = (int)(b * 255.0f);
    GrabColor[0] = (int)(r * 220.0f); GrabColor[1] = (int)(g * 220.0f); GrabColor[2] = (int)(b * 220.0f);
    InactiveTextColor[0] = std::min(255, (int)(r * 100.0f + 60)); InactiveTextColor[1] = std::min(255, (int)(g * 100.0f + 60)); InactiveTextColor[2] = std::min(255, (int)(b * 100.0f + 60));

    SetStyles();
}

void ApplyTheme(int preset) {
    mods.UseCustomTheme = false;
    mods.ThemePreset = preset;
    if (preset == 0) { 
        BGColor[0] = 17; BGColor[1] = 17; BGColor[2] = 19;
        ChildColor[0] = 22; ChildColor[1] = 21; ChildColor[2] = 26;
        IconChildColor[0] = 25; IconChildColor[1] = 26; IconChildColor[2] = 31;
        InactiveTextColor[0] = 84; InactiveTextColor[1] = 82; InactiveTextColor[2] = 89;
        ActiveTextColor[0] = 255; ActiveTextColor[1] = 255; ActiveTextColor[2] = 255;
        GrabColor[0] = 72; GrabColor[1] = 71; GrabColor[2] = 78;
    }
    SetStyles();
}

// --- HUD & OVERLAYS ---
void RenderHUD() { /* ... */ }
void RenderDriftGuide() { /* ... */ }
void RenderSpeedometer() { /* ... */ }

// --- MENU CHÍNH ---
void LoadMenu() {
    if (!isMenuOpen) return; 

    ImGui::SetNextWindowSize(ImVec2(520, 400), ImGuiCond_FirstUseEver);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
    ImGui::Begin("##ZingSpeedMenu", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);

    ImGui::PushStyleColor(ImGuiCol_ChildBg, isTransparentMode ? ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.4f) : ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.95f));
    
    ImGui::Columns(2, "MainLayout", false);
    ImGui::SetColumnWidth(0, 60.0f); 

    // SIDEBAR TRÁI
    ImGui::BeginChild("##Sidebar", ImVec2(60, 0), true);
    {
        ImVec4 iconColor = ImVec4(InactiveTextColor[0]/255.0f, InactiveTextColor[1]/255.0f, InactiveTextColor[2]/255.0f, 1.0f);
        ImVec4 activeColor = ImVec4(255, 255, 255, 1.0f);

        if (PageNumber == 0) ImGui::PushStyleColor(ImGuiCol_Text, activeColor); else ImGui::PushStyleColor(ImGuiCol_Text, iconColor);
        if (ImGui::Button(ICON_FA_USER "##Tab0", ImVec2(44, 44))) { PageNumber = 0; TriggerHaptic(0); }
        ImGui::PopStyleColor();

        if (PageNumber == 1) ImGui::PushStyleColor(ImGuiCol_Text, activeColor); else ImGui::PushStyleColor(ImGuiCol_Text, iconColor);
        if (ImGui::Button(ICON_FA_CAR "##Tab1", ImVec2(44, 44))) { PageNumber = 1; TriggerHaptic(0); }
        ImGui::PopStyleColor();

        if (PageNumber == 2) ImGui::PushStyleColor(ImGuiCol_Text, activeColor); else ImGui::PushStyleColor(ImGuiCol_Text, iconColor);
        if (ImGui::Button(ICON_FA_TSHIRT "##Tab2", ImVec2(44, 44))) { PageNumber = 2; TriggerHaptic(0); }
        ImGui::PopStyleColor();

        if (PageNumber == 3) ImGui::PushStyleColor(ImGuiCol_Text, activeColor); else ImGui::PushStyleColor(ImGuiCol_Text, iconColor);
        if (ImGui::Button(ICON_FA_COG "##Tab3", ImVec2(44, 44))) { PageNumber = 3; TriggerHaptic(0); }
        ImGui::PopStyleColor();
    }
    ImGui::EndChild();

    ImGui::NextColumn();

    // KHU VỰC NỘI DUNG & DRAWER
    bool isDrawerOpen = false;
    for (const auto & pair : childVisibilityMap) {
        if (pair.second) { isDrawerOpen = true; break; }
    }

    float mainContentWidth = isDrawerOpen ? (ImGui::GetContentRegionAvail().x * 0.5f) : ImGui::GetContentRegionAvail().x;
    
    ImGui::BeginChild("##MainContent", ImVec2(mainContentWidth, 0), false);
    {
        ImGui::BeginChild("##Header", ImVec2(0, 50), false);
        {
            ImGui::SetCursorPos(ImVec2(15, 15));
            if (PageNumber == 0) ImGui::Text(ICON_FA_USER "  USER");
            else if (PageNumber == 1) ImGui::Text(ICON_FA_CAR "  XE & TÊN");
            else if (PageNumber == 2) ImGui::Text(ICON_FA_TSHIRT "  SKIN & MODS");
            else if (PageNumber == 3) ImGui::Text(ICON_FA_COG "  SETTINGS");

            ImGui::SameLine(ImGui::GetContentRegionAvail().x - 85);
            if (ImGui::Button(ICON_FA_GEM "##Gem", ImVec2(34, 34))) {
                isTransparentMode = !isTransparentMode;
                TriggerHaptic(0);
                SetStyles();
            }
            ImGui::SameLine();
            if (ImGui::Button(ICON_FA_TIMES "##Close", ImVec2(34, 34))) {
                isMenuOpen = false;
                TriggerHaptic(0);
            }
            ImGui::Separator();
        }
        ImGui::EndChild();

        ImGui::BeginChild("##TabContent", ImVec2(0, 0), false);
        {
            if (PageNumber == 0) {
                newChildVisible = childVisibilityMap["Teleport Auto"];
                ToggleWidget(ICON_FA_LOCATION_ARROW, "Teleport Auto", &mods.TeleportAuto, &newChildVisible);
                childVisibilityMap["Teleport Auto"] = newChildVisible;

                newChildVisible = childVisibilityMap["Teleport Button"];
                ToggleWidget(ICON_FA_MOUSE_POINTER, "Teleport Button", &mods.TeleportButton, &newChildVisible);
                childVisibilityMap["Teleport Button"] = newChildVisible;

                newChildVisible = childVisibilityMap["Mini Boost"];
                ToggleWidget(ICON_FA_ROCKET, "Mini Boost", &mods.MiniBoot, &newChildVisible);
                childVisibilityMap["Mini Boost"] = newChildVisible;

                newChildVisible = childVisibilityMap["Thoát Nhanh"];
                ToggleWidget(ICON_FA_SIGN_OUT_ALT, "Thoát Nhanh", &mods.ThoatNhanh, &newChildVisible);
                childVisibilityMap["Thoát Nhanh"] = newChildVisible;

                newChildVisible = childVisibilityMap["ECU 3 Lượt"];
                ToggleWidget(ICON_FA_TACHOMETER_ALT, "ECU 3 Lượt", &mods.ECU3Luot, &newChildVisible);
                childVisibilityMap["ECU 3 Lượt"] = newChildVisible;

                newChildVisible = childVisibilityMap["Gia Tốc"];
                ToggleWidget(ICON_FA_GAS_PUMP, "Gia Tốc", &mods.GiaToc, &newChildVisible);
                childVisibilityMap["Gia Tốc"] = newChildVisible;
            } 
            else if (PageNumber == 1) {
                if (ToggleWidget(ICON_FA_ROBOT, "Auto Đua Lập Trình", &autoDuaLapTrinh, &newChildVisible)) {
                    TriggerHaptic(0);
                    mods.AutoDuaLapTrinh = autoDuaLapTrinh;
                    SaveConfig();
                }
                childVisibilityMap["Auto Đua Lập Trình"] = newChildVisible;

                if (autoDuaLapTrinh) {
                    ImGui::Spacing();
                    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(40/255.0f, 35/255.0f, 25/255.0f, 0.6f));
                    ImGui::BeginChild("##WarningBox", ImVec2(0, 55), true);
                    ImGui::SetCursorPos(ImVec2(10, 10));
                    ImGui::TextColored(ImVec4(0.85f, 0.62f, 0.15f, 1.0f), "|");
                    ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x - 10);
                    ImGui::TextWrapped("Tránh bật/tắt khi đang đua, có thể bị game báo gian lận. Nên bật ngoài sảnh và trước khi bắt đầu.");
                    ImGui::PopTextWrapPos();
                    ImGui::EndChild();
                    ImGui::PopStyleColor();

                    ImGui::Spacing();
                    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(45/255.0f, 50/255.0f, 65/255.0f, 0.5f));
                    ImGui::BeginChild("##StatusBox", ImVec2(0, 40), true);
                    ImGui::SetCursorPos(ImVec2(10, 12));
                    ImGui::TextColored(ImVec4(0.0f, 0.9f, 1.0f, 1.0f), "●");
                    ImGui::SameLine();
                    ImGui::Text("Đã bật: Chờ đếm ngược 3s sẽ tự chạy");
                    ImGui::EndChild();
                    ImGui::PopStyleColor();
                }

                ImGui::Spacing();
                newChildVisible = childVisibilityMap["Chỉnh tốc độ Replay"];
                ToggleWidget(ICON_FA_FORWARD, "Chỉnh tốc độ Replay", &mods.NitroNhanh, &newChildVisible);
                childVisibilityMap["Chỉnh tốc độ Replay"] = newChildVisible;
            }
            else if (PageNumber == 2) {
                newChildVisible = childVisibilityMap["Mod Skin"];
                ToggleWidget(ICON_FA_TSHIRT, "Mod Skin", &mods.ModSkin, &newChildVisible);
                childVisibilityMap["Mod Skin"] = newChildVisible;

                newChildVisible = childVisibilityMap["Unlock Xe+Skin"];
                ToggleWidget(ICON_FA_UNLOCK, "Unlock Xe+Skin", &mods.UnlockXeSkin, &newChildVisible);
                childVisibilityMap["Unlock Xe+Skin"] = newChildVisible;
            }
            else if (PageNumber == 3) {
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(30/255.0f, 35/255.0f, 45/255.0f, 0.8f));
                
                if (ImGui::Button(ICON_FA_CROWN "  Tác giả: Ng The Anh", ImVec2(ImGui::GetContentRegionAvail().x, 40))) {
                    TriggerHaptic(0);
                    CopyToClipboard("@tranggnekk");
                }
                
                ImGui::Spacing();
                
                if (ImGui::Button("  Offset", ImVec2(ImGui::GetContentRegionAvail().x, 40))) {
                    TriggerHaptic(0);
                    LoadDynamicOffsets();
                }
                
                ImGui::PopStyleColor();
            }
        }
        ImGui::EndChild();
    }
    ImGui::EndChild();

    if (isDrawerOpen) {
        ImGui::SameLine();
        ImGui::BeginChild("##Drawer", ImVec2(0, 0), true);
        {
            for (const auto & pair : childVisibilityMap) {
                if (pair.second) {
                    ImGui::SetCursorPos(ImVec2(10, 10));
                    ImGui::TextColored(ImVec4(0.8f, 0.8f, 0.8f, 1.0f), "%s Settings", pair.first.c_str());
                    ImGui::Separator();
                    ImGui::Spacing();
                    ImGui::TextWrapped("Cấu hình chi tiết cho tính năng %s.", pair.first.c_str());
                    break; 
                }
            }
        }
        ImGui::EndChild();
    }

    ImGui::Columns(1);
    ImGui::PopStyleColor(); 
    ImGui::End();
    ImGui::PopStyleVar();
}

// --- KHỞI TẠO BAN ĐẦU ---
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
    LoadMods();
    ApplyTheme(mods.ThemePreset);
    ApplyFPS(mods.TargetFPS);
    UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor colorWithRed:0.15 green:0.65 blue:1.0 alpha:1.0];
    [alert showSuccess:@"ZingSpeedTweakIOS"
              subTitle:@"Mod Menu loaded successfully!\nTac gia: Ng The Anh\nChuc ban choi game vui ve!"
      closeButtonTitle:@"OK"
              duration:5.0f];
  });
}

struct MyStruct {
  MyStruct() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  }
};
MyStruct mystruct;
