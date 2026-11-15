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

bool showLogs = false;
int ChildColor[4] = { 22, 21, 26, 255 };
int BGColor[4] = { 17, 17, 19, 255 };
int IconChildColor[4] = { 25, 26, 31, 255 };
int InactiveTextColor[4] = { 84, 82, 89, 255 };
int ActiveTextColor[4] = { 255, 255, 255, 255 };
int GrabColor[4] = { 72, 71, 78, 255 };
bool lightTheme = false;

static int PageNumber = 0;
static bool sidebarTab0 = true, sidebarTab1 = false, sidebarTab2 = false, sidebarTab3 = false, sidebarTab4 = false;

std::map<std::string, bool> childVisibilityMap;

static int deepFadeAnimation = 255;
static bool animationEx = false;
static float animationButton = 25;
static float position = 25;
int animation_text = 255;
int speed = 10;

static float columnOffset = 60.0f;
static float targetOffset = 60.0f;
float animationSpeed = 130.0f;
bool newChildVisible;
bool ToggleAnimations = false;

NSString *baseimage = @"DÁN_BASE64";

void SetStyles() {
    ImGuiStyle* style = &ImGui::GetStyle();
    style->WindowBorderSize = 0;
    style->WindowMinSize = ImVec2(400, 260);
    style->FrameRounding = 5.0f;
    style->GrabRounding = 5.0f;
    style->WindowRounding = 5.0f;
    style->PopupRounding = 5.0f;
    style->ChildRounding = 5.0f;
    style->ScrollbarSize = 15;
    style->Colors[ImGuiCol_WindowBg] = ImColor(BGColor[0], BGColor[1], BGColor[2], 255);
    style->Colors[ImGuiCol_FrameBg] = ImColor(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255);
    style->Colors[ImGuiCol_FrameBgHovered] = ImColor(std::min(255, IconChildColor[0] + 15), std::min(255, IconChildColor[1] + 15), std::min(255, IconChildColor[2] + 15), 255);
    style->Colors[ImGuiCol_FrameBgActive] = ImColor(std::min(255, IconChildColor[0] + 30), std::min(255, IconChildColor[1] + 30), std::min(255, IconChildColor[2] + 30), 255);
    style->Colors[ImGuiCol_TitleBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_TitleBgActive] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_Header] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_HeaderHovered] = ImColor(GrabColor[0], GrabColor[1], GrabColor[2], 180);
    style->Colors[ImGuiCol_HeaderActive] = ImColor(GrabColor[0], GrabColor[1], GrabColor[2], 255);
    style->Colors[ImGuiCol_ChildBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_Button] = ImColor(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255);
    style->Colors[ImGuiCol_ButtonHovered] = ImColor(GrabColor[0], GrabColor[1], GrabColor[2], 180);
    style->Colors[ImGuiCol_ButtonActive] = ImColor(GrabColor[0], GrabColor[1], GrabColor[2], 255);
    style->Colors[ImGuiCol_CheckMark] = ImColor(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], 255);
    style->Colors[ImGuiCol_SliderGrab] = ImColor(GrabColor[0], GrabColor[1], GrabColor[2], 255);
    style->Colors[ImGuiCol_SliderGrabActive] = ImColor(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], 255);
}

void ApplyCustomColors(float r, float g, float b, float bgR, float bgG, float bgB) {
    mods.UseCustomTheme = true;
    mods.CustomAccentColor[0] = r;
    mods.CustomAccentColor[1] = g;
    mods.CustomAccentColor[2] = b;
    mods.CustomBgColor[0] = bgR;
    mods.CustomBgColor[1] = bgG;
    mods.CustomBgColor[2] = bgB;

    BGColor[0] = (int)(bgR * 255.0f);
    BGColor[1] = (int)(bgG * 255.0f);
    BGColor[2] = (int)(bgB * 255.0f);

    ChildColor[0] = std::min(255, (int)(bgR * 255.0f + 12));
    ChildColor[1] = std::min(255, (int)(bgG * 255.0f + 12));
    ChildColor[2] = std::min(255, (int)(bgB * 255.0f + 16));

    IconChildColor[0] = std::min(255, (int)(bgR * 255.0f + 20));
    IconChildColor[1] = std::min(255, (int)(bgG * 255.0f + 22));
    IconChildColor[2] = std::min(255, (int)(bgB * 255.0f + 28));

    ActiveTextColor[0] = (int)(r * 255.0f);
    ActiveTextColor[1] = (int)(g * 255.0f);
    ActiveTextColor[2] = (int)(b * 255.0f);

    GrabColor[0] = (int)(r * 220.0f);
    GrabColor[1] = (int)(g * 220.0f);
    GrabColor[2] = (int)(b * 220.0f);

    InactiveTextColor[0] = std::min(255, (int)(r * 100.0f + 60));
    InactiveTextColor[1] = std::min(255, (int)(g * 100.0f + 60));
    InactiveTextColor[2] = std::min(255, (int)(b * 100.0f + 60));

    SetStyles();
}

void ApplyTheme(int preset) {
    mods.UseCustomTheme = false;
    mods.ThemePreset = preset;
    if (preset == 0) { // Dark Classic
        BGColor[0] = 17; BGColor[1] = 17; BGColor[2] = 19;
        ChildColor[0] = 22; ChildColor[1] = 21; ChildColor[2] = 26;
        IconChildColor[0] = 25; IconChildColor[1] = 26; IconChildColor[2] = 31;
        InactiveTextColor[0] = 84; InactiveTextColor[1] = 82; InactiveTextColor[2] = 89;
        ActiveTextColor[0] = 255; ActiveTextColor[1] = 255; ActiveTextColor[2] = 255;
        GrabColor[0] = 72; GrabColor[1] = 71; GrabColor[2] = 78;
    } else if (preset == 1) { // Neon Cyan (Cyberpunk)
        BGColor[0] = 12; BGColor[1] = 18; BGColor[2] = 26;
        ChildColor[0] = 16; ChildColor[1] = 26; ChildColor[2] = 38;
        IconChildColor[0] = 20; IconChildColor[1] = 36; IconChildColor[2] = 54;
        InactiveTextColor[0] = 80; InactiveTextColor[1] = 130; InactiveTextColor[2] = 160;
        ActiveTextColor[0] = 0; ActiveTextColor[1] = 235; ActiveTextColor[2] = 255;
        GrabColor[0] = 0; GrabColor[1] = 190; GrabColor[2] = 220;
    } else if (preset == 2) { // Racing Red
        BGColor[0] = 22; BGColor[1] = 14; BGColor[2] = 16;
        ChildColor[0] = 32; ChildColor[1] = 18; ChildColor[2] = 22;
        IconChildColor[0] = 46; IconChildColor[1] = 24; IconChildColor[2] = 28;
        InactiveTextColor[0] = 130; InactiveTextColor[1] = 85; InactiveTextColor[2] = 90;
        ActiveTextColor[0] = 255; ActiveTextColor[1] = 70; ActiveTextColor[2] = 85;
        GrabColor[0] = 225; GrabColor[1] = 45; GrabColor[2] = 65;
    } else if (preset == 3) { // Neon Purple
        BGColor[0] = 20; BGColor[1] = 14; BGColor[2] = 28;
        ChildColor[0] = 28; ChildColor[1] = 18; ChildColor[2] = 40;
        IconChildColor[0] = 40; IconChildColor[1] = 24; IconChildColor[2] = 58;
        InactiveTextColor[0] = 125; InactiveTextColor[1] = 90; InactiveTextColor[2] = 145;
        ActiveTextColor[0] = 210; ActiveTextColor[1] = 110; ActiveTextColor[2] = 255;
        GrabColor[0] = 175; GrabColor[1] = 70; GrabColor[2] = 230;
    } else if (preset == 4) { // Emerald Green
        BGColor[0] = 12; BGColor[1] = 22; BGColor[2] = 18;
        ChildColor[0] = 16; ChildColor[1] = 32; ChildColor[2] = 25;
        IconChildColor[0] = 22; IconChildColor[1] = 46; IconChildColor[2] = 36;
        InactiveTextColor[0] = 85; InactiveTextColor[1] = 135; InactiveTextColor[2] = 110;
        ActiveTextColor[0] = 50; ActiveTextColor[1] = 240; ActiveTextColor[2] = 150;
        GrabColor[0] = 35; GrabColor[1] = 190; GrabColor[2] = 115;
    } else if (preset == 5) { // Amber Gold (Hoàng Gia)
        BGColor[0] = 22; BGColor[1] = 18; BGColor[2] = 12;
        ChildColor[0] = 30; ChildColor[1] = 24; ChildColor[2] = 16;
        IconChildColor[0] = 45; IconChildColor[1] = 36; IconChildColor[2] = 22;
        InactiveTextColor[0] = 140; InactiveTextColor[1] = 115; InactiveTextColor[2] = 70;
        ActiveTextColor[0] = 255; ActiveTextColor[1] = 200; ActiveTextColor[2] = 50;
        GrabColor[0] = 230; GrabColor[1] = 170; GrabColor[2] = 30;
    } else if (preset == 6) { // Cyber Sunset / Sakura Pink
        BGColor[0] = 24; BGColor[1] = 14; BGColor[2] = 22;
        ChildColor[0] = 34; ChildColor[1] = 18; ChildColor[2] = 30;
        IconChildColor[0] = 50; IconChildColor[1] = 24; IconChildColor[2] = 44;
        InactiveTextColor[0] = 140; InactiveTextColor[1] = 85; InactiveTextColor[2] = 125;
        ActiveTextColor[0] = 255; ActiveTextColor[1] = 105; ActiveTextColor[2] = 180;
        GrabColor[0] = 240; GrabColor[1] = 75; GrabColor[2] = 160;
    }
    SetStyles();
}

#import <mach/mach.h>

static float matchTimer = 0.0f;

void ResetMatchTimer() {
    matchTimer = 0.0f;
}

// ==========================================
// ĐÃ XÓA TOÀN BỘ HÀM VẼ HUD, DRIFT GUIDE, SPEEDOMETER
// ==========================================
void RenderHUD() {}
void RenderDriftGuide() {}
void RenderSpeedometer() {}

void LoadMenu() {
    ImVec2 P1, P2;
    ImDrawList * pDrawList;
    const auto & CurrentWindowPos = ImGui::GetWindowPos();
    const auto & pWindowDrawList = ImGui::GetWindowDrawList();
    ImDrawList * menuDrawList = ImGui::GetWindowDrawList();
    if (ToggleAnimations) targetOffset = 0.0f;
    else targetOffset = 60.0f;
    if (columnOffset != targetOffset) {
        float deltaTime = ImGui::GetIO().DeltaTime;
        if (columnOffset < targetOffset) {
            columnOffset += animationSpeed * deltaTime;
            if (columnOffset > targetOffset) columnOffset = targetOffset;
        } else {
            columnOffset -= animationSpeed * deltaTime;
            if (columnOffset < targetOffset) columnOffset = targetOffset;
        }
    }
    ImGui::Columns(2);
    ImGui::SetColumnOffset(1, columnOffset);

    ImGui::BeginChild("##SideBar", ImVec2(50, 255), true);
    {
        ImGui::SetCursorPos(ImVec2(13, 17));
        if (sidebarTab0) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
        else ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        if (ImGui::Button(ICON_FA_USER "##Player", ImVec2(50, 30))) {
            TriggerHaptic(0);
            PageNumber = 0; position = 25; if (!sidebarTab0) animationEx = true; if (!sidebarTab0) animation_text = 0;
            sidebarTab0 = true; sidebarTab1 = false; sidebarTab2 = false; sidebarTab3 = false; sidebarTab4 = false;
        }
        ImGui::PopStyleColor(1);

        ImGui::SetCursorPos(ImVec2(13, 68));
        if (sidebarTab1) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
        else ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        if (ImGui::Button(ICON_FA_LOCK "##Weapons", ImVec2(50, 30))) {
            TriggerHaptic(0);
            PageNumber = 1; position = 75; if (!sidebarTab1) animationEx = true; if (!sidebarTab1) animation_text = 0;
            sidebarTab0 = false; sidebarTab1 = true; sidebarTab2 = false; sidebarTab3 = false; sidebarTab4 = false;
        }
        ImGui::PopStyleColor(1);

        ImGui::SetCursorPos(ImVec2(12, 118));
        if (sidebarTab2) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
        else ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        if (ImGui::Button(ICON_FA_CAR "##Cars", ImVec2(50, 30))) {
            TriggerHaptic(0);
            PageNumber = 2; position = 125; if (!sidebarTab2) animationEx = true; if (!sidebarTab2) animation_text = 0;
            sidebarTab0 = false; sidebarTab1 = false; sidebarTab2 = true; sidebarTab3 = false; sidebarTab4 = false;
        }
        ImGui::PopStyleColor(1);

        ImGui::SetCursorPos(ImVec2(12, 168));
        if (sidebarTab3) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
        else ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        if (ImGui::Button(ICON_FA_SERVER "##Server", ImVec2(50, 30))) {
            TriggerHaptic(0);
            PageNumber = 3; position = 175; if (!sidebarTab3) animationEx = true; if (!sidebarTab3) animation_text = 0;
            sidebarTab0 = false; sidebarTab1 = false; sidebarTab2 = false; sidebarTab3 = true; sidebarTab4 = false;
        }
        ImGui::PopStyleColor(1);

        ImGui::SetCursorPos(ImVec2(12, 218));
        if (sidebarTab4) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
        else ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        if (ImGui::Button(ICON_FA_CROWN "##Author", ImVec2(50, 30))) {
            TriggerHaptic(0);
            PageNumber = 4; position = 225; if (!sidebarTab4) animationEx = true; if (!sidebarTab4) animation_text = 0;
            sidebarTab0 = false; sidebarTab1 = false; sidebarTab2 = false; sidebarTab3 = false; sidebarTab4 = true;
        }
        ImGui::PopStyleColor(1);

        if (animationEx && deepFadeAnimation > 0) {
            deepFadeAnimation -= 8;
            if (deepFadeAnimation < 1) { animationButton = position; animationEx = false; }
        }
        if (!animationEx) { if (deepFadeAnimation < 255) deepFadeAnimation += 8; }
        if (animation_text <= 250) animation_text += 3;

        ImVec2 P1 = ImVec2(13, animationButton + 15);
        P1.x += CurrentWindowPos.x;
        P1.y += CurrentWindowPos.y;
        ImVec2 P2 = ImVec2(P1.x + 40, P1.y + 40);
        pDrawList = pWindowDrawList;
        pDrawList->AddRectFilled(P1, P2, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], deepFadeAnimation), 4.0f);
    }
    ImGui::EndChild();

    ImGui::NextColumn();
    ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(BGColor[0], BGColor[1], BGColor[2], 255));
    static float currentWidth = 0.0f;
    float targetWidth = ToggleAnimations ? ImGui::GetContentRegionAvail().x * 0.5f : ImGui::GetContentRegionAvail().x + 5;
    float animationSpeed = 5.0f;
    float deltaTime = ImGui::GetIO().DeltaTime;
    currentWidth += (targetWidth - currentWidth) * animationSpeed * deltaTime;
    if (fabs(targetWidth - currentWidth) < 0.01f) currentWidth = targetWidth;
    ImVec2 mainContentSize = ImVec2(currentWidth, 255);

    // ==========================================
    // TAB 0: CƠ BẢN (RACING CHEATS)
    // ==========================================
    if (PageNumber == 0) {
        ImGui::BeginChild("##MainContent", mainContentSize, true);
        {
            newChildVisible = childVisibilityMap["Teleport Auto"];
            ToggleWidget(ICON_FA_LOCATION_ARROW, "Teleport Auto", &mods.TeleportAuto, &newChildVisible);
            childVisibilityMap["Teleport Auto"] = newChildVisible;

            newChildVisible = childVisibilityMap["Mini Boot"];
            ToggleWidget(ICON_FA_ROCKET, "Mini Boot", &mods.MiniBoot, &newChildVisible);
            childVisibilityMap["Mini Boot"] = newChildVisible;

            newChildVisible = childVisibilityMap["Vo Han Nitro"];
            ToggleWidget(ICON_FA_BOLT, "Vo Han Nitro", &mods.VoHanNitro, &newChildVisible);
            childVisibilityMap["Vo Han Nitro"] = newChildVisible;

            newChildVisible = childVisibilityMap["ECU 3 Luot"];
            ToggleWidget(ICON_FA_TACHOMETER_ALT, "ECU 3 Luot", &mods.ECU3Luot, &newChildVisible);
            childVisibilityMap["ECU 3 Luot"] = newChildVisible;

            newChildVisible = childVisibilityMap["Gia Toc"];
            ToggleWidget(ICON_FA_GAS_PUMP, "Gia Toc", &mods.GiaToc, &newChildVisible);
            childVisibilityMap["Gia Toc"] = newChildVisible;

            ImGui::SameLine();
            ImGui::BeginGroup();
            newChildVisible = childVisibilityMap["Teleport Button"];
            ToggleWidget(ICON_FA_MOUSE_POINTER, "Teleport Button", &mods.TeleportButton, &newChildVisible);
            childVisibilityMap["Teleport Button"] = newChildVisible;

            newChildVisible = childVisibilityMap["Thoat Nhanh"];
            ToggleWidget(ICON_FA_SIGN_OUT_ALT, "Thoat Nhanh", &mods.ThoatNhanh, &newChildVisible);
            childVisibilityMap["Thoat Nhanh"] = newChildVisible;

            newChildVisible = childVisibilityMap["Nitro Nhanh"];
            ToggleWidget(ICON_FA_FORWARD, "Nitro Nhanh", &mods.NitroNhanh, &newChildVisible);
            childVisibilityMap["Nitro Nhanh"] = newChildVisible;

            newChildVisible = childVisibilityMap["Tu Dua Xe"];
            ToggleWidget(ICON_FA_CAR, "Tu Dua Xe", &mods.TuDuaXe, &newChildVisible);
            childVisibilityMap["Tu Dua Xe"] = newChildVisible;
            ImGui::EndGroup();

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            if (ImGui::RadioButton("1. Duong huong dan", mods.AutoDuaMode == 1)) mods.AutoDuaMode = 1;
            ImGui::SameLine();
            if (ImGui::RadioButton("2. Ra giua duong", mods.AutoDuaMode == 2)) mods.AutoDuaMode = 2;
            ImGui::SameLine();
            if (ImGui::RadioButton("3. Apex Out-In-Out", mods.AutoDuaMode == 3)) mods.AutoDuaMode = 3;
            ImGui::Spacing();

            static const char* mapNames[] = {
                "Map 157 - Ho Long Tinh",
                "Map 102 - Thanh Pho 11",
                "Map 120 - Dao 11",
                "Map 145 - Thu Danh Son",
                "Map 188 - Suoi Nuoc Nong",
                "Map 210 - Sa Mac Toc Do"
            };
            ImGui::TextColored(ImVec4(0.3f, 0.85f, 1.0f, 1.0f), ICON_FA_MAP_MARKED_ALT " Chon Ban Do (Map Selector):");
            if (ImGui::Combo("##SelectedMap", &mods.SelectedMapIndex, mapNames, IM_ARRAYSIZE(mapNames))) {
                TriggerHaptic(0);
                SaveConfig();
            }

            ImGui::Spacing();
            newChildVisible = childVisibilityMap["Auto Dua Lap Trinh"];
            ToggleWidget(ICON_FA_ROBOT, "Auto Dua Lap Trinh", &mods.AutoDuaLapTrinh, &newChildVisible);
            childVisibilityMap["Auto Dua Lap Trinh"] = newChildVisible;

            newChildVisible = childVisibilityMap["Tro Luc Be Lai Apex"];
            ToggleWidget(ICON_FA_CROSSHAIRS, "Tro Luc Be Lai Apex", &mods.AutoApexSteer, &newChildVisible);
            childVisibilityMap["Tro Luc Be Lai Apex"] = newChildVisible;

            newChildVisible = childVisibilityMap["Tu Dong Combo CWW"];
            ToggleWidget(ICON_FA_BOLT, "Tu Dong Combo CWW", &mods.AutoCWWSequence, &newChildVisible);
            childVisibilityMap["Tu Dong Combo CWW"] = newChildVisible;

            newChildVisible = childVisibilityMap["Thuat Toan Pure Pursuit & PID"];
            ToggleWidget(ICON_FA_MICROCHIP, "Thuat Toan Pure Pursuit & PID", &mods.UsePurePursuit, &newChildVisible);
            childVisibilityMap["Thuat Toan Pure Pursuit & PID"] = newChildVisible;

            newChildVisible = childVisibilityMap["Noi Suy Spline & Du Doan CWW"];
            ToggleWidget(ICON_FA_CHART_LINE, "Noi Suy Spline & Du Doan CWW", &mods.UseSplineInterpolation, &newChildVisible);
            childVisibilityMap["Noi Suy Spline & Du Doan CWW"] = newChildVisible;

            // Bộ tính năng thực chiến chiến thắng
            newChildVisible = childVisibilityMap["Giu Toc Cua (Min-Drift)"];
            ToggleWidget(ICON_FA_TACHOMETER_ALT, "Giu Toc Cua (Min-Drift)", &mods.LockMinDriftAngle, &newChildVisible);
            childVisibilityMap["Giu Toc Cua (Min-Drift)"] = newChildVisible;

            newChildVisible = childVisibilityMap["Auto Doan Drift (Snap Reset)"];
            ToggleWidget(ICON_FA_FAST_FORWARD, "Auto Doan Drift (Snap Reset)", &mods.AutoSnapDrift, &newChildVisible);
            childVisibilityMap["Auto Doan Drift (Snap Reset)"] = newChildVisible;

            newChildVisible = childVisibilityMap["Combo CWW Hoan Hao"];
            ToggleWidget(ICON_FA_BOLT, "Combo CWW Hoan Hao", &mods.PerfectCWWChain, &newChildVisible);
            childVisibilityMap["Combo CWW Hoan Hao"] = newChildVisible;

            newChildVisible = childVisibilityMap["Chong Vang & Tu Hoi Phuc"];
            ToggleWidget(ICON_FA_SHIELD_ALT, "Chong Vang & Tu Hoi Phuc", &mods.AntiBumpRecovery, &newChildVisible);
            childVisibilityMap["Chong Vang & Tu Hoi Phuc"] = newChildVisible;

            newChildVisible = childVisibilityMap["Cat Goc Duong Dua (Apex Cutter)"];
            ToggleWidget(ICON_FA_CUT, "Cat Goc Duong Dua (Apex Cutter)", &mods.ApexCornerCutter, &newChildVisible);
            childVisibilityMap["Cat Goc Duong Dua (Apex Cutter)"] = newChildVisible;

            if (mods.AutoDuaLapTrinh) {
                int validMap = (mods.SelectedMapIndex >= 0 && mods.SelectedMapIndex < 6) ? mods.SelectedMapIndex : 0;
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.2f, 1.0f), ICON_FA_CHECK_CIRCLE " Auto Lai: Dang chay quy dao toi uu!");
                ImGui::TextColored(ImVec4(0.3f, 0.85f, 1.0f, 1.0f), ICON_FA_LOCATION_ARROW " Toa Do Xe: X=%.1f | Z=%.1f (Yaw=%.1f deg)", g_playerPos.x, g_playerPos.z, g_playerYaw);
                ImGui::TextColored(ImVec4(1.0f, 0.85f, 0.2f, 1.0f), ICON_FA_MAP_PIN " Ban Do: %s [Moc WP: %d/%d]", mapNames[validMap], g_currentWaypointIndex + 1, g_totalWaypoints);
            }
        }
        ImGui::EndChild();
    }

    // ==========================================
    // TAB 1: NHÂN VẬT & TÀI KHOẢN
    // ==========================================
    if (PageNumber == 1) {
        ImGui::BeginChild("##MainContent1", mainContentSize, true);
        {
            newChildVisible = childVisibilityMap["Ky Sinh"];
            ToggleWidget(ICON_FA_HEART, "Ky Sinh", &mods.KySinh, &newChildVisible);
            childVisibilityMap["Ky Sinh"] = newChildVisible;
            
            newChildVisible = childVisibilityMap["Fake Ten"];
            ToggleWidget(ICON_FA_USER_SECRET, "Fake Ten", &mods.FakeTen, &newChildVisible);
            childVisibilityMap["Fake Ten"] = newChildVisible;
        }
        ImGui::EndChild();
    }

    // ==========================================
    // TAB 2: XE & CAMERA
    // ==========================================
    if (PageNumber == 2) {
        ImGui::BeginChild("##MainContent2", mainContentSize, true);
        {
            newChildVisible = childVisibilityMap["Mod Skin"];
            ToggleWidget(ICON_FA_TSHIRT, "Mod Skin", &mods.ModSkin, &newChildVisible);
            childVisibilityMap["Mod Skin"] = newChildVisible;

            newChildVisible = childVisibilityMap["Unlock Xe+Skin"];
            ToggleWidget(ICON_FA_UNLOCK, "Unlock Xe+Skin", &mods.UnlockXeSkin, &newChildVisible);
            childVisibilityMap["Unlock Xe+Skin"] = newChildVisible;
            
            newChildVisible = childVisibilityMap["Mod chi so xe"];
            ToggleWidget(ICON_FA_WRENCH, "Mod chi so xe", &mods.ModChiSoXe, &newChildVisible);
            childVisibilityMap["Mod chi so xe"] = newChildVisible;

            newChildVisible = childVisibilityMap["Camera FOV"];
            ToggleWidget(ICON_FA_EYE, "Camera FOV", &mods.CustomFOV, &newChildVisible);
            childVisibilityMap["Camera FOV"] = newChildVisible;

            ImGui::SameLine();
            ImGui::BeginGroup();

            newChildVisible = childVisibilityMap["Tam Drift & Apex Guide"];
            ToggleWidget(ICON_FA_COMPASS, "Tam Drift & Apex Guide", &mods.ShowDriftGuide, &newChildVisible);
            childVisibilityMap["Tam Drift & Apex Guide"] = newChildVisible;

            newChildVisible = childVisibilityMap["Tinh Goc Cua Toi Uu"];
            ToggleWidget(ICON_FA_TACHOMETER_ALT, "Tinh Goc Cua Toi Uu", &mods.OptimalDriftCalc, &newChildVisible);
            childVisibilityMap["Tinh Goc Cua Toi Uu"] = newChildVisible;

            newChildVisible = childVisibilityMap["Dong Ho Toc Do HUD"];
            ToggleWidget(ICON_FA_TACHOMETER_ALT, "Dong Ho Toc Do HUD", &mods.ShowSpeedometer, &newChildVisible);
            childVisibilityMap["Dong Ho Toc Do HUD"] = newChildVisible;

            newChildVisible = childVisibilityMap["Nhip Rung CWW Metronome"];
            ToggleWidget(ICON_FA_BELL, "Nhip Rung CWW Metronome", &mods.CWWMetronome, &newChildVisible);
            childVisibilityMap["Nhip Rung CWW Metronome"] = newChildVisible;

            ImGui::EndGroup();
        }
        ImGui::EndChild();
    }

    // ==========================================
    // TAB 3: TIỆN ÍCH & PHÒNG CHỜ (UTILITIES)
    // ==========================================
    if (PageNumber == 3) {
        ImGui::BeginChild("##MainContent3", mainContentSize, true);
        {
            newChildVisible = childVisibilityMap["HUD FPS & Ping"];
            ToggleWidget(ICON_FA_DESKTOP, "HUD FPS & Ping", &mods.ShowHUD, &newChildVisible);
            childVisibilityMap["HUD FPS & Ping"] = newChildVisible;

            newChildVisible = childVisibilityMap["Auto Ready"];
            ToggleWidget(ICON_FA_CHECK_CIRCLE, "Auto Ready", &mods.AutoReady, &newChildVisible);
            childVisibilityMap["Auto Ready"] = newChildVisible;

            newChildVisible = childVisibilityMap["Auto Start"];
            ToggleWidget(ICON_FA_PLAY_CIRCLE, "Auto Start", &mods.AutoStart, &newChildVisible);
            childVisibilityMap["Auto Start"] = newChildVisible;

            newChildVisible = childVisibilityMap["Chong AFK Kick"];
            ToggleWidget(ICON_FA_SHIELD_ALT, "Chong AFK Kick", &mods.AntiAFK, &newChildVisible);
            childVisibilityMap["Chong AFK Kick"] = newChildVisible;

            newChildVisible = childVisibilityMap["Thong So RAM & Pin"];
            ToggleWidget(ICON_FA_MICROCHIP, "Thong So RAM & Pin", &mods.ShowHardwareStats, &newChildVisible);
            childVisibilityMap["Thong So RAM & Pin"] = newChildVisible;

            ImGui::SameLine();
            ImGui::BeginGroup();

            newChildVisible = childVisibilityMap["Giam Va Cham Tuong"];
            ToggleWidget(ICON_FA_SHIELD_ALT, "Giam Va Cham Tuong", &mods.AntiCollision, &newChildVisible);
            childVisibilityMap["Giam Va Cham Tuong"] = newChildVisible;

            newChildVisible = childVisibilityMap["Chong Report Server"];
            ToggleWidget(ICON_FA_USER_SECRET, "Chong Report Server", &mods.AntiReport, &newChildVisible);
            childVisibilityMap["Chong Report Server"] = newChildVisible;

            newChildVisible = childVisibilityMap["Chan Log Analytics"];
            ToggleWidget(ICON_FA_BAN, "Chan Log Analytics", &mods.BlockAnalytics, &newChildVisible);
            childVisibilityMap["Chan Log Analytics"] = newChildVisible;

            ImGui::EndGroup();

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // THẺ LIVE MEMORY INSPECTOR
            uintptr_t ubase = GetUnityBase();
            ImGui::TextColored(ImVec4(0.2f, 0.8f, 1.0f, 1.0f), ICON_FA_MICROCHIP " Live Memory Inspector:");
            if (ubase) {
                ImGui::Text("Unity Base: 0x%llX", (unsigned long long)ubase);
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), "Framework Status: Running @ 60 FPS");
            } else {
                ImGui::TextColored(ImVec4(1.0f, 0.7f, 0.2f, 1.0f), "Unity Base: Dang tim kiem module game...");
            }
            ImGui::Text("SafeMemory Engine: Active & Protected");
            ImGui::Text("Offsets File: %s", gameOffsets.isLoadedFromFile ? "Da nap tu Offsets.json" : "Mac dinh");

            ImGui::Spacing();
            if (ImGui::Button(ICON_FA_SYNC "  Tai Lai Offsets.json", ImVec2(ImGui::GetContentRegionAvail().x * 0.5f - 4, 26))) {
                TriggerHaptic(0);
                PlayBeepSound(1057);
                LoadDynamicOffsets();
                Console::logSuccess("Da nap lai file Offsets.json tu Documents!");
            }
            ImGui::SameLine();
            if (ImGui::Button(ICON_FA_HISTORY "  Reset Dong Ho", ImVec2(ImGui::GetContentRegionAvail().x, 26))) {
                TriggerHaptic(0);
                PlayBeepSound(1104);
                ResetMatchTimer();
                Console::logInfo("Da dat lai dong ho bam gio tran!");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // THẺ CHIA SẺ LIVE RADAR LÊN MÁY TÍNH (CLOUD VERCEL & LOCAL SERVER)
            ImGui::TextColored(ImVec4(0.0f, 0.95f, 1.0f, 1.0f), ICON_FA_GLOBE " Cloud Web Radar (zingspeedvnmod.vercel.app):");
            
            // 1. Chia sẻ qua Cloud Hosting Vercel
            newChildVisible = childVisibilityMap["Chia Se Cloud Vercel"];
            bool prevCloudRadar = mods.CloudRadarEnabled;
            ToggleWidget(ICON_FA_CLOUD, "Chia Se Cloud Vercel", &mods.CloudRadarEnabled, &newChildVisible);
            childVisibilityMap["Chia Se Cloud Vercel"] = newChildVisible;

            if (mods.CloudRadarEnabled != prevCloudRadar) {
                SaveConfig();
                if (mods.CloudRadarEnabled) {
                    Console::logSuccess([[NSString stringWithFormat:@"Da bat Cloud Radar phong: %s", mods.CloudRoomCode] UTF8String]);
                } else {
                    Console::logInfo("Da tat Cloud Radar.");
                }
            }

            if (mods.CloudRadarEnabled) {
                NSString* cloudURL = GetCloudRadarURL();
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), "Link PC Cloud: %s", [cloudURL UTF8String]);
                ImGui::Text("Ma Phong Live: %s (5 Chu Hoa)", mods.CloudRoomCode);

                if (ImGui::Button(ICON_FA_SYNC "  Doi Ma Phong Moi", ImVec2(ImGui::GetContentRegionAvail().x * 0.45f, 26))) {
                    TriggerHaptic(0);
                    PlayBeepSound(1057);
                    GenerateNewCloudRoomCode();
                    SaveConfig();
                    Console::logSuccess([[NSString stringWithFormat:@"Ma phong moi: %s", mods.CloudRoomCode] UTF8String]);
                }
                ImGui::SameLine();
                if (ImGui::Button(ICON_FA_COPY "  Sao Chep Link Cloud", ImVec2(ImGui::GetContentRegionAvail().x, 26))) {
                    TriggerHaptic(0);
                    PlayBeepSound(1057);
                    [UIPasteboard generalPasteboard].string = cloudURL;
                    Console::logSuccess([[NSString stringWithFormat:@"Da sao chep link Cloud Radar: %@", cloudURL] UTF8String]);
                }
            } else {
                ImGui::TextDisabled("Bat Cloud de tao link zingspeedvnmod.vercel.app/map/XXXXX");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // 2. Chia sẻ qua Web Server Cục Bộ (LAN / Wi-Fi)
            ImGui::TextColored(ImVec4(0.3f, 0.8f, 1.0f, 1.0f), ICON_FA_WIFI " Web Server Cuc Bo (Wi-Fi / Hotspot):");
            newChildVisible = childVisibilityMap["Bat Server Cuc Bo"];
            bool prevWebRadar = mods.WebRadarEnabled;
            ToggleWidget(ICON_FA_SERVER, "Bat Server Cuc Bo", &mods.WebRadarEnabled, &newChildVisible);
            childVisibilityMap["Bat Server Cuc Bo"] = newChildVisible;

            if (mods.WebRadarEnabled != prevWebRadar) {
                if (mods.WebRadarEnabled) {
                    StartWebRadarServer();
                    SaveConfig();
                    Console::logSuccess([[NSString stringWithFormat:@"Server cuc bo: %@", GetWebRadarURL()] UTF8String]);
                } else {
                    StopWebRadarServer();
                    SaveConfig();
                    Console::logInfo("Da tat Server cuc bo.");
                }
            }

            if (mods.WebRadarEnabled) {
                NSString* currentURL = GetWebRadarURL();
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), "Link Xem PC (LAN): %s", [currentURL UTF8String]);

                if (ImGui::Button(ICON_FA_COPY "  Sao Chep Link LAN", ImVec2(ImGui::GetContentRegionAvail().x, 26))) {
                    TriggerHaptic(0);
                    PlayBeepSound(1057);
                    [UIPasteboard generalPasteboard].string = currentURL;
                    Console::logSuccess([[NSString stringWithFormat:@"Da sao chep link LAN: %@", currentURL] UTF8String]);
                }
            }
        }
        ImGui::EndChild();
    }

    // ==========================================
    // TAB 4: AUTHOR ZHEE DEV & SHOWCASE CÀI ĐẶT
    // ==========================================
    if (PageNumber == 4) {
        ImGui::BeginChild("##MainContent4", mainContentSize, true);
        {
            float time = (float)ImGui::GetTime();

            // 1. TIÊU ĐỀ ANIMATED GRADIENT CẦU VỒNG
            float r = sinf(time * 2.5f + 0.0f) * 0.45f + 0.55f;
            float g = sinf(time * 2.5f + 2.0f) * 0.45f + 0.55f;
            float b = sinf(time * 2.5f + 4.0f) * 0.45f + 0.55f;
            ImVec4 rainbow = ImVec4(r, g, b, 1.0f);

            ImGui::SetCursorPosX((ImGui::GetContentRegionAvail().x - ImGui::CalcTextSize(ICON_FA_CROWN "  ZHEE DEV - ZINGSPEED TWEAK  " ICON_FA_CROWN).x) * 0.5f);
            ImGui::TextColored(rainbow, ICON_FA_CROWN "  ZHEE DEV - ZINGSPEED TWEAK  " ICON_FA_CROWN);

            ImGui::Spacing();

            // 2. AUTHOR SHOWCASE PROFILE CARD
            ImVec2 cardPos = ImGui::GetCursorScreenPos();
            ImVec2 cardSize = ImVec2(ImGui::GetContentRegionAvail().x - 4, 82);
            ImDrawList* drawList = ImGui::GetWindowDrawList();

            // Nền Card và viền phát sáng (Glow border)
            drawList->AddRectFilled(cardPos, ImVec2(cardPos.x + cardSize.x, cardPos.y + cardSize.y), IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], 240), 6.0f);
            drawList->AddRect(cardPos, ImVec2(cardPos.x + cardSize.x, cardPos.y + cardSize.y), IM_COL32((int)(r*255), (int)(g*255), (int)(b*255), 200), 6.0f, 0, 1.5f);

            ImGui::SetCursorPos(ImVec2(ImGui::GetCursorPosX() + 8, ImGui::GetCursorPosY() + 6));
            ImGui::TextColored(ImVec4(1.0f, 0.85f, 0.25f, 1.0f), ICON_FA_USER_SHIELD " Tác giả: Zhee Dev (@zheedevVn)");
            
            ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 8);
            ImGui::TextColored(ImVec4(0.85f, 0.85f, 0.9f, 1.0f), "Lead Developer & Reverse Engineer");

            // Status online nhấp nháy
            bool blink = ((int)(time * 2.0f) % 2 == 0);
            ImVec4 statusColor = blink ? ImVec4(0.2f, 1.0f, 0.4f, 1.0f) : ImVec4(0.1f, 0.8f, 0.3f, 0.8f);
            ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 8);
            ImGui::TextColored(statusColor, "● STATUS: ONLINE & ACTIVATED (v1.0.0 Metal)");

            ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 10);

            // 3. THAO TÁC LIÊN HỆ & SAO CHÉP LINK
            if (ImGui::Button(ICON_FA_LINK "  Sao Chep GitHub", ImVec2(ImGui::GetContentRegionAvail().x * 0.5f - 4, 25))) {
                TriggerHaptic(0);
                CopyToClipboard("https://github.com/zheedevVn/ZingSpeedTweakIOS");
                Console::logSuccess("Da sao chep link GitHub vao Clipboard!");
            }
            ImGui::SameLine();
            if (ImGui::Button(ICON_FA_PAPER_PLANE "  Support Issues", ImVec2(ImGui::GetContentRegionAvail().x, 25))) {
                TriggerHaptic(0);
                CopyToClipboard("https://github.com/zheedevVn/ZingSpeedTweakIOS/issues");
                Console::logInfo("Da sao chep link Support!");
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // 4. BỘ CHỌN THEME PRESETS & TÙY CHỈNH MÀU SẮC MENU
            ImGui::TextColored(ImVec4(0.4f, 0.85f, 1.0f, 1.0f), ICON_FA_PALETTE "  Mau Sac Menu & Giao Dien:");
            if (ImGui::RadioButton("Dark", mods.ThemePreset == 0 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(0); SaveConfig(); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Cyan", mods.ThemePreset == 1 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(1); SaveConfig(); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Red", mods.ThemePreset == 2 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(2); SaveConfig(); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Purple", mods.ThemePreset == 3 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(3); SaveConfig(); }
            
            if (ImGui::RadioButton("Green", mods.ThemePreset == 4 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(4); SaveConfig(); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Gold", mods.ThemePreset == 5 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(5); SaveConfig(); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Pink", mods.ThemePreset == 6 && !mods.UseCustomTheme)) { TriggerHaptic(0); ApplyTheme(6); SaveConfig(); }

            // Chế độ Tự Chọn Màu Riêng (Custom RGB Theme)
            ImGui::Spacing();
            if (ImGui::Checkbox(ICON_FA_SLIDERS_H "  Tu Chon Mau Rieng (Custom RGB)", &mods.UseCustomTheme)) {
                TriggerHaptic(0);
                if (mods.UseCustomTheme) {
                    ApplyCustomColors(mods.CustomAccentColor[0], mods.CustomAccentColor[1], mods.CustomAccentColor[2],
                                      mods.CustomBgColor[0], mods.CustomBgColor[1], mods.CustomBgColor[2]);
                } else {
                    ApplyTheme(mods.ThemePreset);
                }
                SaveConfig();
            }

            if (mods.UseCustomTheme) {
                ImGui::Indent(8.0f);
                ImGui::TextColored(ImVec4(1.0f, 0.85f, 0.3f, 1.0f), "Tuy chinh chi tiet bang mau RGB:");
                
                bool colorChanged = false;
                if (ImGui::ColorEdit3("Mau Diem Nhan (Accent)", mods.CustomAccentColor, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_PickerHueWheel)) {
                    colorChanged = true;
                }
                if (ImGui::ColorEdit3("Mau Nen (Background)", mods.CustomBgColor, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_PickerHueWheel)) {
                    colorChanged = true;
                }

                // RGB sliders
                if (ImGui::SliderFloat("Accent R", &mods.CustomAccentColor[0], 0.0f, 1.0f, "R: %.2f")) colorChanged = true;
                if (ImGui::SliderFloat("Accent G", &mods.CustomAccentColor[1], 0.0f, 1.0f, "G: %.2f")) colorChanged = true;
                if (ImGui::SliderFloat("Accent B", &mods.CustomAccentColor[2], 0.0f, 1.0f, "B: %.2f")) colorChanged = true;
                if (ImGui::SliderFloat("Nen R", &mods.CustomBgColor[0], 0.0f, 0.35f, "Nen R: %.2f")) colorChanged = true;
                if (ImGui::SliderFloat("Nen G", &mods.CustomBgColor[1], 0.0f, 0.35f, "Nen G: %.2f")) colorChanged = true;
                if (ImGui::SliderFloat("Nen B", &mods.CustomBgColor[2], 0.0f, 0.35f, "Nen B: %.2f")) colorChanged = true;

                // Palette gợi ý nhanh
                ImGui::Text("Mau goi y:");
                if (ImGui::Button("Ice Blue", ImVec2(70, 22))) {
                    mods.CustomAccentColor[0] = 0.0f; mods.CustomAccentColor[1] = 0.88f; mods.CustomAccentColor[2] = 1.0f;
                    colorChanged = true;
                }
                ImGui::SameLine();
                if (ImGui::Button("Gold", ImVec2(55, 22))) {
                    mods.CustomAccentColor[0] = 1.0f; mods.CustomAccentColor[1] = 0.78f; mods.CustomAccentColor[2] = 0.15f;
                    colorChanged = true;
                }
                ImGui::SameLine();
                if (ImGui::Button("Pink", ImVec2(55, 22))) {
                    mods.CustomAccentColor[0] = 1.0f; mods.CustomAccentColor[1] = 0.4f; mods.CustomAccentColor[2] = 0.7f;
                    colorChanged = true;
                }
                ImGui::SameLine();
                if (ImGui::Button("Green", ImVec2(55, 22))) {
                    mods.CustomAccentColor[0] = 0.15f; mods.CustomAccentColor[1] = 0.95f; mods.CustomAccentColor[2] = 0.5f;
                    colorChanged = true;
                }

                if (colorChanged) {
                    ApplyCustomColors(mods.CustomAccentColor[0], mods.CustomAccentColor[1], mods.CustomAccentColor[2],
                                      mods.CustomBgColor[0], mods.CustomBgColor[1], mods.CustomBgColor[2]);
                    SaveConfig();
                }
                ImGui::Unindent(8.0f);
            }

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // 4.5. TÙY CHỈNH FPS & MỞ KHÓA 120HZ PROMOTION
            float currentFramerate = ImGui::GetIO().Framerate;
            float frameTimeMs = 1000.0f / (currentFramerate > 0.0f ? currentFramerate : 60.0f);
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), ICON_FA_TACHOMETER_ALT "  FPS & Tan So Quet (Unity & Menu):");
            ImGui::Text("Muc tieu: %d FPS | Thuc te: %.1f FPS (%.1f ms)", mods.TargetFPS, currentFramerate, frameTimeMs);

            bool fpsChanged = false;
            if (ImGui::RadioButton("30 FPS", mods.TargetFPS == 30)) { mods.TargetFPS = 30; fpsChanged = true; }
            ImGui::SameLine();
            if (ImGui::RadioButton("60 FPS", mods.TargetFPS == 60)) { mods.TargetFPS = 60; fpsChanged = true; }
            ImGui::SameLine();
            if (ImGui::RadioButton("90 FPS", mods.TargetFPS == 90)) { mods.TargetFPS = 90; fpsChanged = true; }
            ImGui::SameLine();
            if (ImGui::RadioButton("120 FPS", mods.TargetFPS == 120)) { mods.TargetFPS = 120; fpsChanged = true; }

            if (ImGui::SliderInt("Tuy Chon FPS", &mods.TargetFPS, 30, 120, "%d FPS")) {
                fpsChanged = true;
            }

            if (fpsChanged) {
                TriggerHaptic(0);
                ApplyFPS(mods.TargetFPS);
                SaveConfig();
                Console::logSuccess([[NSString stringWithFormat:@"Da ap dung tan so quet: %d FPS", mods.TargetFPS] UTF8String]);
            }

            ImGui::Spacing();

            // 5. CÁC TÙY CHỌN HỆ THỐNG
            newChildVisible = childVisibilityMap["Streamer Mode"];
            ToggleWidget(ICON_FA_EYE_SLASH, "Streamer Mode", &StreamerMode, &newChildVisible);
            childVisibilityMap["Streamer Mode"] = newChildVisible;

            newChildVisible = childVisibilityMap["Menu Logs"];
            if (ToggleWidget(ICON_FA_TERMINAL, "Menu Logs", &showLogs, &newChildVisible)) {}
            childVisibilityMap["Menu Logs"] = newChildVisible;
            if (showLogs) Console::render();

            newChildVisible = childVisibilityMap["Am Thanh Click"];
            ToggleWidget(ICON_FA_VOLUME_UP, "Am Thanh Click", &mods.SoundEffects, &newChildVisible);
            childVisibilityMap["Am Thanh Click"] = newChildVisible;

            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            ImGui::TextColored(ImVec4(0.2f, 0.9f, 1.0f, 1.0f), ICON_FA_USER_COG " Phuong Thuc Mo Menu Tweak:");

            // Lựa chọn 1: Chạm 3 ngón tay
            bool prevGesture = mods.GestureShortcut;
            newChildVisible = childVisibilityMap["Cu Chi 3 Ngon"];
            ToggleWidget(ICON_FA_HAND_POINT_UP, "1. Cham 3 Ngon Tay De Mo", &mods.GestureShortcut, &newChildVisible);
            childVisibilityMap["Cu Chi 3 Ngon"] = newChildVisible;

            // Lựa chọn 2: Nút nổi icon
            bool prevFloating = mods.ShowFloatingIcon;
            newChildVisible = childVisibilityMap["Nut Noi Icon"];
            ToggleWidget(ICON_FA_IMAGE, "2. Nut Noi Icon (Cho Con)", &mods.ShowFloatingIcon, &newChildVisible);
            childVisibilityMap["Nut Noi Icon"] = newChildVisible;

            // Bảo vệ an toàn: Không để người dùng bị tắt cả 2 cách mở Menu
            if (mods.ShowFloatingIcon != prevFloating || mods.GestureShortcut != prevGesture) {
                if (!mods.ShowFloatingIcon && !mods.GestureShortcut) {
                    mods.GestureShortcut = true;
                    Console::logWarning("Phai bat it nhat 1 cach mo Menu (da tu dong giu Cham 3 Ngon)!");
                }
                UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                SaveConfig();
            }

            ImGui::TextDisabled("Ban co the dung Cham 3 ngon, Nut noi icon hoac ca hai.");
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();

            // 6. NÚT CHIA SẺ CẤU HÌNH CLIPBOARD
            if (ImGui::Button(ICON_FA_COPY "  Sao Chep Config", ImVec2(ImGui::GetContentRegionAvail().x * 0.5f - 4, 26))) {
                if (ExportConfigToClipboard()) {
                    Console::logSuccess("Da sao chep ma cau hinh vao Clipboard!");
                }
            }
            ImGui::SameLine();
            if (ImGui::Button(ICON_FA_PASTE "  Dan & Ap Dung", ImVec2(ImGui::GetContentRegionAvail().x, 26))) {
                if (ImportConfigFromClipboard()) {
                    if (mods.UseCustomTheme) {
                        ApplyCustomColors(mods.CustomAccentColor[0], mods.CustomAccentColor[1], mods.CustomAccentColor[2],
                                          mods.CustomBgColor[0], mods.CustomBgColor[1], mods.CustomBgColor[2]);
                    } else {
                        ApplyTheme(mods.ThemePreset);
                    }
                    ApplyFPS(mods.TargetFPS);
                    UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                    Console::logSuccess("Da nap cau hinh thanh cong tu Clipboard!");
                } else {
                    Console::logError("Ma cau hinh trong Clipboard khong hop le!");
                }
            }

            ImGui::Spacing();

            // 7. NÚT LƯU CẤU HÌNH & KHÔI PHỤC
            if (ImGui::Button(ICON_FA_SAVE "  Luu Cau Hinh", ImVec2(ImGui::GetContentRegionAvail().x * 0.5f - 4, 28))) {
                TriggerHaptic(3);
                SaveConfig();
                Console::logSuccess("Da luu cau hinh thanh cong!");
            }
            ImGui::SameLine();
            if (ImGui::Button(ICON_FA_UNDO "  Khoi Phuc Mac Dinh", ImVec2(ImGui::GetContentRegionAvail().x, 28))) {
                TriggerHaptic(1);
                ResetConfig();
                ApplyTheme(0);
                ApplyFPS(60);
                UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                Console::logWarning("Da khoi phuc cau hinh mac dinh!");
            }
        }
        ImGui::EndChild();
    }

    // ==========================================
    // DRAWER: NGĂN KÉO CÀI ĐẶT CHI TIẾT WIDGET
    // ==========================================
    for (const auto & pair: childVisibilityMap) {
        const std::string & widgetName = pair.first;
        bool isVisible = pair.second;
        if (isVisible) {
            ImGui::SameLine();
            ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], animation_text));
            ImGui::BeginChild(("##newChild_" + widgetName).c_str(), ImVec2(ImGui::GetContentRegionAvail().x + 5, ImGui::GetContentRegionAvail().y), true);
            {
                ImVec2 titleBarSize = ImVec2(ImGui::GetContentRegionAvail().x, 25);
                ImVec2 titleBarPos = ImGui::GetCursorScreenPos();
                float rounding = 5.0f;
                ImGui::GetWindowDrawList() -> AddRectFilled(titleBarPos, ImVec2(titleBarPos.x + titleBarSize.x, titleBarPos.y + titleBarSize.y), IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text), rounding, ImDrawFlags_RoundCornersTop);
                std::string titleText = widgetName + " Settings";
                ImVec2 textSize = ImGui::CalcTextSize(titleText.c_str());
                float textX = titleBarPos.x + (titleBarSize.x - textSize.x) / 2.0f;
                ImGui::SetCursorScreenPos(ImVec2(textX, titleBarPos.y + (titleBarSize.y - textSize.y) / 2.0f));
                ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
                ImGui::Text("%s", titleText.c_str());
                ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 5);
                ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);
                ImGui::SetWindowFontScale(0.8f);

                if (widgetName == "Teleport Auto" || widgetName == "Teleport Button" || widgetName == "Mini Boot") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tinh nang Teleport giup di chuyen nhanh tren map.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    bool tmp = false;
                    ToggleButtonMini("Dich den diem A", &tmp);
                    ToggleButtonMini("Dich den diem B", &tmp);
                }
                else if (widgetName == "Vo Han Nitro" || widgetName == "Nitro Nhanh") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Chinh sua luong va thoi gian Nitro.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    SliderFloatMini("Thoi Gian Nitro", &mods.NitroDuration, 1.0f, 10.0f);
                }
                else if (widgetName == "Gia Toc" || widgetName == "Mod chi so xe") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tuy chinh toc do xe khi kich hoat.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    SliderFloatMini("Toc Do Xe", &mods.GiaTocSpeed, 50.0f, 300.0f);
                }
                else if (widgetName == "Camera FOV") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tuy chinh goc nhin Camera (FOV).");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    SliderFloatMini("Goc Nhin (FOV)", &mods.CameraFOV, 45.0f, 120.0f);
                }
                else if (widgetName == "HUD FPS & Ping") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Hien thi bang chi so FPS va Ping realtime goc phai man hinh.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                }
                else if (widgetName == "Tro Luc Be Lai Apex" || widgetName == "Auto Dua Lap Trinh") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Ho tro tu be lai bam sat vach cua Apex va tra thang tay lai.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    SliderFloatMini("Do Nhay Tro Luc", &mods.DriftAssistanceLevel, 1.0f, 3.0f);
                    static const char* lines[] = { "Out-In-Out Toi Uu", "Cut Ngan Short-Cut", "An Toan Safe" };
                    ImGui::Combo("Che Do Cua", &mods.RacingLineType, lines, IM_ARRAYSIZE(lines));
                }
                else if (widgetName == "Tu Dong Combo CWW") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tu dong kich hoat combo phun nitro kep CWW/WCW ngay khi thoat cua.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Kich Hoat CWW", &mods.AutoCWWSequence);
                }
                else if (widgetName == "Thuat Toan Pure Pursuit & PID") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Thuat toan Pure Pursuit ket hop bo dieu khien PID triet tieu dao dong lech tim duong.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Kich Hoat Pure Pursuit", &mods.UsePurePursuit);
                    ToggleButtonMini("Bo Dieu Khien PID", &mods.UsePIDController);
                    SliderFloatMini("He So Kp (Ti Le)", &mods.PID_Kp, 0.1f, 3.0f);
                    SliderFloatMini("He So Ki (Tich Phan)", &mods.PID_Ki, 0.0f, 0.3f);
                    SliderFloatMini("He So Kd (Vi Phan)", &mods.PID_Kd, 0.0f, 1.5f);
                    SliderFloatMini("Lookahead Ratio", &mods.LookaheadRatio, 0.1f, 0.5f);
                }
                else if (widgetName == "Noi Suy Spline & Du Doan CWW") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Noi suy da thuc bac 3 Catmull-Rom giup duong chay mem mai va du doan chinh xac frame nhan nut CWW.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Noi Suy Spline", &mods.UseSplineInterpolation);
                    ToggleButtonMini("Du Doan CWW (ms)", &mods.PredictCWWMillisecond);
                }
                else if (widgetName == "Giu Toc Cua (Min-Drift)") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Ghim goc drift tai nguong toi thieu (28-32 do) vua du tich day binh Nitro ma xe khong bi tut toc, duy tri ~200 km/h.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Khoa Goc Min-Drift", &mods.LockMinDriftAngle);
                    SliderFloatMini("Goc Drift Toi Thieu", &mods.MinDriftAngleVal, 25.0f, 38.0f);
                }
                else if (widgetName == "Auto Doan Drift (Snap Reset)") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tu dong be nguoc lai 0.05s ngay khi du binh Nitro de giat thang than xe tuc thi, triet tieu hoan toan thoi gian re duoi.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Auto Doan Drift", &mods.AutoSnapDrift);
                }
                else if (widgetName == "Combo CWW Hoan Hao") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Kich hoat chuoi combo CWW Boost chuan micro-second giup 100%% dat van toc toi da 312-318 km/h khong bao gio hut nhip.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("CWW Chuan Khung Hinh", &mods.PerfectCWWChain);
                }
                else if (widgetName == "Chong Vang & Tu Hoi Phuc") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tu dong triet tieu phan luc va gia toc xoay khi bi doi thu tong huc hoac va thanh cau, tu dong lay lai lai huong tim duong.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Chong Vang & Tu Hoi Phuc", &mods.AntiBumpRecovery);
                    SliderFloatMini("Do Nhay Hoi Phuc (s)", &mods.RecoverySensitivity, 0.05f, 0.50f);
                }
                else if (widgetName == "Cat Goc Duong Dua (Apex Cutter)") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Thu hep quy dao om sat mep le trong (Apex) giup rut ngan 8-12%% tong quang duong chay moi vong.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Cat Goc Apex", &mods.ApexCornerCutter);
                    SliderFloatMini("Khoang Cach Le (m)", &mods.ApexMargin, 0.10f, 0.60f);
                }
                else if (widgetName == "Tam Drift & Apex Guide" || widgetName == "Tinh Goc Cua Toi Uu") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tam can goc drift ly tuong (38-45 do) giup giu toi da toc do va kich hoat CWW Boost nhanh nhat ve nhat.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Tinh Goc Toi Uu", &mods.OptimalDriftCalc);
                }
                else if (widgetName == "Chong AFK Kick") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Giu ket noi mang phong cho va ngan chan bi he thong kick vi treo may khong thao tac.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                }
                else if (widgetName == "Dong Ho Toc Do HUD" || widgetName == "Nhip Rung CWW Metronome") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Dong ho toc do Cyberpunk va nhip rung phan hoi nhac nho thoi diem phan xa CWW.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Nhip Rung CWW", &mods.CWWMetronome);
                }
                else if (widgetName == "Thong So RAM & Pin") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Theo doi dung luong RAM su dung va muc phan tram pin realtime.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                }
                else if (widgetName == "Streamer Mode" || widgetName == "Menu Logs") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tuy chinh nut icon menu va rung phan hoi.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    SliderFloatMini("Co Icon Menu", &mods.IconSize, 35.0f, 75.0f);
                    UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                    SliderFloatMini("Do Mo Icon", &mods.IconOpacity, 0.2f, 1.0f);
                    UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                    ToggleButtonMini("Rung Phan Hoi", &mods.HapticFeedback);
                }
                else if (widgetName == "Am Thanh Click" || widgetName == "Cu Chi 3 Ngon" || widgetName == "1. Cham 3 Ngon Tay De Mo" || widgetName == "2. Nut Noi Icon (Cho Con)" || widgetName == "Nut Noi Icon") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tuy chinh phuong thuc mo Menu: Cham 3 ngon tay hoac Nut noi icon hinh chu cho con.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Am Thanh Click", &mods.SoundEffects);
                    if (ToggleButtonMini("1. Cham 3 Ngon", &mods.GestureShortcut)) {
                        if (!mods.GestureShortcut && !mods.ShowFloatingIcon) mods.ShowFloatingIcon = true;
                        UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                        SaveConfig();
                    }
                    if (ToggleButtonMini("2. Nut Noi Icon", &mods.ShowFloatingIcon)) {
                        if (!mods.ShowFloatingIcon && !mods.GestureShortcut) mods.GestureShortcut = true;
                        UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
                        SaveConfig();
                    }
                }
                ImGui::SetWindowFontScale(1.0f); ImGui::PopStyleColor();
            }
            ImGui::EndChild(); ImGui::PopStyleColor();
        }
    }
    ImGui::Columns(1);
    LightTheme();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(5) {
    LoadMods();
    if (mods.UseCustomTheme) {
        ApplyCustomColors(mods.CustomAccentColor[0], mods.CustomAccentColor[1], mods.CustomAccentColor[2],
                          mods.CustomBgColor[0], mods.CustomBgColor[1], mods.CustomBgColor[2]);
    } else {
        ApplyTheme(mods.ThemePreset);
    }
    ApplyFPS(mods.TargetFPS);
    UpdateFloatingIcon(mods.IconSize, mods.IconOpacity);
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor colorWithRed:0.15 green:0.65 blue:1.0 alpha:1.0];
    [alert showSuccess:@"ZingSpeedTweakIOS"
              subTitle:@"Mod Menu loaded successfully!\nTac gia: Zhee Dev\nChuc ban choi game vui ve!"
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
