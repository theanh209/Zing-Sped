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

bool ToggleAnimations = false;
bool newChildVisible = false;
bool saveToggleStates = false;
std::map<std::string, bool> childVisibilityMap;

bool showLogs = false;
int ChildColor[4] = { 22, 21, 26, 255 };
int BGColor[4] = { 17, 17, 19, 255 };
int IconChildColor[4] = { 25, 26, 31, 255 };
int InactiveTextColor[4] = { 84, 82, 89, 255 };
int ActiveTextColor[4] = { 255, 255, 255, 255 };
int GrabColor[4] = { 72, 71, 78, 255 };
bool lightTheme = false;

int speed = 10; 
int animation_text = 255; 

static int PageNumber = 0; 
static bool isMenuOpen = true;
static bool isTransparentMode = false;
static bool autoDuaLapTrinh = false;

NSString *baseimage = @"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";

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
    style->Colors[ImGuiCol_FrameBgActive] = ImColor(85, 88, 95, 255);
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

bool SimpleToggleWidget(const char* label, bool* v) {
    ImGui::PushID(label);
    bool clicked = false;

    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(30/255.0f, 35/255.0f, 45/255.0f, isTransparentMode ? 0.4f : 0.75f));
    ImGui::BeginChild("##RowCard", ImVec2(ImGui::GetContentRegionAvail().x, 46), true, ImGuiWindowFlags_NoScrollbar);
    {
        ImGui::SetCursorPos(ImVec2(14, 14));
        ImGui::TextColored(ImVec4(0.95f, 0.95f, 0.97f, 1.0f), "%s", label);

        float switchWidth = 42.0f;
        float switchHeight = 22.0f;
        ImVec2 pos = ImGui::GetWindowPos();
        float availW = ImGui::GetWindowWidth();
        ImVec2 switchPos = ImVec2(pos.x + availW - switchWidth - 14.0f, pos.y + (46.0f - switchHeight) * 0.5f);

        ImGui::SetCursorScreenPos(switchPos);
        if (ImGui::InvisibleButton("##SwitchBtn", ImVec2(switchWidth, switchHeight))) {
            *v = !(*v);
            clicked = true;
            TriggerHaptic(0);
        }

        ImDrawList* drawList = ImGui::GetWindowDrawList();
        ImU32 bgCol = *v ? IM_COL32(90, 93, 102, 255) : IM_COL32(42, 46, 57, 255);
        drawList->AddRectFilled(switchPos, ImVec2(switchPos.x + switchWidth, switchPos.y + switchHeight), bgCol, switchHeight * 0.5f);

        float knobRadius = (switchHeight - 6.0f) * 0.5f;
        float knobX = *v ? (switchPos.x + switchWidth - knobRadius - 3.0f) : (switchPos.x + knobRadius + 3.0f);
        float knobY = switchPos.y + switchHeight * 0.5f;
        drawList->AddCircleFilled(ImVec2(knobX, knobY), knobRadius, IM_COL32(255, 255, 255, 255));
    }
    ImGui::EndChild();
    ImGui::PopStyleColor();
    ImGui::Spacing();
    ImGui::PopID();

    return clicked;
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

void LoadMenu() {
    if (!isMenuOpen) return; 

    ImGui::SetNextWindowSize(ImVec2(520, 400), ImGuiCond_FirstUseEver);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
    ImGui::Begin("##ZingSpeedMenu", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);

    ImGui::PushStyleColor(ImGuiCol_ChildBg, isTransparentMode ? ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.4f) : ImVec4(15/255.0f, 18/255.0f, 24/255.0f, 0.95f));
    
    ImGui::Columns(2, "MainLayout", false);
    ImGui::SetColumnWidth(0, 60.0f); 

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

    ImGui::BeginChild("##MainContent", ImVec2(ImGui::GetContentRegionAvail().x, 0), false);
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
                SimpleToggleWidget("Teleport Auto", &mods.TeleportAuto);
                SimpleToggleWidget("Teleport Button", &mods.TeleportButton);
                SimpleToggleWidget("Mini Boost", &mods.MiniBoot);
                SimpleToggleWidget("Thoát Nhanh", &mods.ThoatNhanh);
                SimpleToggleWidget("ECU 3 Lượt", &mods.ECU3Luot);
                SimpleToggleWidget("Gia Tốc", &mods.GiaToc);
            } 
            else if (PageNumber == 1) {
                if (SimpleToggleWidget("Auto Đua Lập Trình", &autoDuaLapTrinh)) {
                    mods.AutoDuaLapTrinh = autoDuaLapTrinh;
                    SaveConfig();
                }
                SimpleToggleWidget("Chỉnh tốc độ Replay", &mods.NitroNhanh);
            }
            else if (PageNumber == 2) {
                SimpleToggleWidget("Mod Skin", &mods.ModSkin);
                SimpleToggleWidget("Unlock Xe+Skin", &mods.UnlockXeSkin);
            }
            else if (PageNumber == 3) {
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(30/255.0f, 35/255.0f, 45/255.0f, 0.8f));
                if (ImGui::Button("Tác giả: Ng The Anh", ImVec2(ImGui::GetContentRegionAvail().x, 40))) {
                    TriggerHaptic(0);
                    CopyToClipboard("@tranggnekk");
                }
                ImGui::PopStyleColor();
            }
        }
        ImGui::EndChild();
    }
    ImGui::EndChild();

    ImGui::Columns(1);
    ImGui::PopStyleColor(); 
    ImGui::End();
    ImGui::PopStyleVar();
}

// --- KHỞI TẠO ĐỒNG BỘ ĐỂ HIỆN ICON VÀ MENU ---
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    timer(6) { // Đợi 6 giây để game load xong hoàn toàn UIWindow
        LoadMods();
        ApplyTheme(mods.ThemePreset);
        ApplyFPS(mods.TargetFPS);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
            [ImGuiDrawViewX showChange:YES];
        });

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
