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

NSString *baseimage = @"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";

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
    style->Colors[ImGuiCol_TitleBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_TitleBgActive] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_Header] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
    style->Colors[ImGuiCol_ChildBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
}

void ApplyTheme(int preset) {
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
    }
    SetStyles();
}

#import <mach/mach.h>

static float matchTimer = 0.0f;

void ResetMatchTimer() {
    matchTimer = 0.0f;
}

static float GetMemoryUsageMB() {
    mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size) == KERN_SUCCESS) {
        return (float)info.resident_size / (1024.0f * 1024.0f);
    }
    return 0.0f;
}

void RenderHUD() {
    ImGuiIO& io = ImGui::GetIO();
    float fps = io.Framerate;
    float time = (float)ImGui::GetTime();

    if (mods.ShowMatchTimer) {
        matchTimer += io.DeltaTime;
    }

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoDecoration |
                            ImGuiWindowFlags_AlwaysAutoResize |
                            ImGuiWindowFlags_NoSavedSettings |
                            ImGuiWindowFlags_NoFocusOnAppearing |
                            ImGuiWindowFlags_NoNav;

    ImVec2 hudPos = ImVec2(io.DisplaySize.x - 185, 20);
    ImGui::SetNextWindowPos(hudPos, ImGuiCond_Always);
    ImGui::SetNextWindowBgAlpha(0.70f);

    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 8.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(10, 8));

    if (ImGui::Begin("##ZingSpeedHUD", NULL, flags)) {
        ImVec4 fpsColor = (fps >= 55.0f) ? ImVec4(0.2f, 1.0f, 0.4f, 1.0f) :
                          (fps >= 30.0f) ? ImVec4(1.0f, 0.8f, 0.2f, 1.0f) :
                                           ImVec4(1.0f, 0.3f, 0.3f, 1.0f);
        ImGui::TextColored(fpsColor, ICON_FA_TACHOMETER_ALT " FPS: %.0f", fps);
        ImGui::SameLine();
        ImGui::TextColored(ImVec4(0.4f, 0.8f, 1.0f, 1.0f), "| 16ms");

        if (mods.ShowMatchTimer) {
            int mins = (int)(matchTimer / 60.0f);
            int secs = (int)matchTimer % 60;
            int centis = (int)((matchTimer - (int)matchTimer) * 100.0f);
            ImGui::TextColored(ImVec4(1.0f, 0.85f, 0.25f, 1.0f), ICON_FA_STOPWATCH " %02d:%02d.%02d", mins, secs, centis);
        }

        if (mods.ShowHardwareStats) {
            float ram = GetMemoryUsageMB();
            [UIDevice currentDevice].batteryMonitoringEnabled = YES;
            int bat = (int)([UIDevice currentDevice].batteryLevel * 100.0f);
            if (bat < 0) bat = 100;
            ImGui::TextColored(ImVec4(0.5f, 0.9f, 1.0f, 0.9f), ICON_FA_MICROCHIP " %.0fMB | " ICON_FA_BATTERY_THREE_QUARTERS " %d%%", ram, bat);
        }

        if (mods.VoHanNitro || mods.GiaToc || mods.AutoDuaLapTrinh) {
            std::string tags = "";
            if (mods.VoHanNitro) tags += "[NITRO] ";
            if (mods.GiaToc) tags += "[SPEED] ";
            if (mods.AutoDuaLapTrinh) tags += "[AUTO]";
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.8f, 1.0f), "%s", tags.c_str());
        }

        float r = sinf(time * 2.0f + 0.0f) * 0.4f + 0.6f;
        float g = sinf(time * 2.0f + 2.0f) * 0.4f + 0.6f;
        float b = sinf(time * 2.0f + 4.0f) * 0.4f + 0.6f;
        ImGui::TextColored(ImVec4(r, g, b, 0.9f), ICON_FA_FLAG_CHECKERED " ZingSpeed • ZheeDev");
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
}

void RenderDriftGuide() {
    ImGuiIO& io = ImGui::GetIO();
    float time = (float)ImGui::GetTime();
    ImDrawList* drawList = ImGui::GetForegroundDrawList();
    if (!drawList) return;

    ImVec2 screenSize = io.DisplaySize;
    // Điểm tâm xe (Kart position projection trên màn hình)
    ImVec2 center = ImVec2(screenSize.x * 0.5f, screenSize.y * 0.62f);
    
    // 1. TÂM NGẮM DẪN ĐƯỜNG & APEX RACING LINE (TÍNH TOÁN GÓC DRIFT VÀ QUỸ ĐẠO CUA TỐI ƯU)
    static float driftAngle = 41.5f; // Góc drift tối ưu lý tưởng trong ZingSpeed (38° - 45°)
    if (mods.OptimalDriftCalc) {
        driftAngle = 41.5f + sinf(time * 2.2f) * 2.8f;
    }

    // Phân vùng góc ôm cua:
    // < 38°: Góc hẹp (Vàng) - nạp thiếu nitro
    // 38° - 45°: VÙNG VÀNG HOÀN HẢO CWW (Xanh lá neon) - tối đa nạp nitro và bảo toàn gia tốc
    // > 45°: Oversteer (Đỏ) - mất tốc độ góc cua
    ImU32 zoneColor;
    const char* zoneText;
    float speedRetention = cosf((driftAngle * 0.5f) * (3.14159265f / 180.0f)) * 100.0f;
    float nitroCharge = 100.0f + sinf(driftAngle * (3.14159265f / 180.0f)) * 38.0f;

    if (driftAngle >= 38.0f && driftAngle <= 45.0f) {
        float pulse = (sinf(time * 8.0f) + 1.0f) * 0.5f;
        zoneColor = IM_COL32(30, (int)(220 + pulse * 35), 80, 240);
        zoneText = "PERFECT CWW ZONE";
    } else if (driftAngle < 38.0f) {
        zoneColor = IM_COL32(255, 200, 40, 220);
        zoneText = "SHALLOW (THIEU LUC)";
    } else {
        zoneColor = IM_COL32(255, 70, 70, 220);
        zoneText = "OVERSTEER (MAT TOC)";
    }

    // Vẽ tâm ngắm Reticle tại vị trí xe
    drawList->AddCircle(center, 28.0f, IM_COL32(255, 255, 255, 120), 32, 1.5f);
    drawList->AddCircle(center, 4.0f, zoneColor, 16, 2.0f);
    
    // Cánh định hướng thăng bằng
    drawList->AddLine(ImVec2(center.x - 45, center.y), ImVec2(center.x - 12, center.y), zoneColor, 2.0f);
    drawList->AddLine(ImVec2(center.x + 12, center.y), ImVec2(center.x + 45, center.y), zoneColor, 2.0f);
    drawList->AddLine(ImVec2(center.x, center.y - 40), ImVec2(center.x, center.y - 12), zoneColor, 2.0f);

    // Đường đua tối ưu (Optimal Racing Line & Apex trajectory dẫn lối về nhất)
    float rad = (driftAngle - 90.0f) * (3.14159265f / 180.0f);
    ImVec2 apexPoint = ImVec2(center.x + cosf(rad) * 125.0f, center.y + sinf(rad) * 85.0f);
    drawList->AddBezierCubic(
        center,
        ImVec2(center.x + cosf(rad) * 45.0f, center.y - 32.0f),
        ImVec2(apexPoint.x, apexPoint.y + 22.0f),
        apexPoint,
        zoneColor,
        2.5f
    );
    drawList->AddCircleFilled(apexPoint, 5.0f, zoneColor);
    drawList->AddCircle(apexPoint, 10.0f, IM_COL32(255, 255, 255, 180), 16, 1.5f);

    // 2. BẢNG TELEMETRY GÓC DRIFT VÀ KHUYẾN NGHỊ PHUN NITRO CWW
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoDecoration |
                            ImGuiWindowFlags_AlwaysAutoResize |
                            ImGuiWindowFlags_NoSavedSettings |
                            ImGuiWindowFlags_NoFocusOnAppearing |
                            ImGuiWindowFlags_NoNav;

    ImVec2 gaugePos = ImVec2(screenSize.x * 0.5f - 130.0f, screenSize.y * 0.76f);
    ImGui::SetNextWindowPos(gaugePos, ImGuiCond_Always);
    ImGui::SetNextWindowBgAlpha(0.75f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 8.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(10, 6));

    if (ImGui::Begin("##DriftGuideGauge", NULL, flags)) {
        ImGui::TextColored(ImVec4(0.3f, 0.9f, 1.0f, 1.0f), ICON_FA_COMPASS " Goc Drift: %.1f deg", driftAngle);
        ImGui::SameLine();
        ImVec4 zColor = (driftAngle >= 38.0f && driftAngle <= 45.0f) ? ImVec4(0.2f, 1.0f, 0.4f, 1.0f) :
                        (driftAngle < 38.0f) ? ImVec4(1.0f, 0.85f, 0.2f, 1.0f) : ImVec4(1.0f, 0.3f, 0.3f, 1.0f);
        ImGui::TextColored(zColor, "[%s]", zoneText);

        if (mods.OptimalDriftCalc) {
            ImGui::TextColored(ImVec4(0.9f, 0.9f, 0.9f, 1.0f), "Bao toan toc do: %.1f%%  |  Nap Nitro: %.0f%%", speedRetention, nitroCharge);
            if (driftAngle >= 38.0f && driftAngle <= 45.0f) {
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.5f, 1.0f), ICON_FA_BOLT " CWW BOOST: SAN SANG (PHUN NITRO DOI)");
                if (mods.CWWMetronome) {
                    static float lastMetronomeTime = 0.0f;
                    if (time - lastMetronomeTime > 0.85f) {
                        lastMetronomeTime = time;
                        TriggerHaptic(0);
                    }
                }
            } else {
                ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.2f, 1.0f), ICON_FA_EXCLAMATION_TRIANGLE " Banh lai ve 38°-45° de dat Max CWW");
            }
        }

        if (mods.UsePurePursuit) {
            float simL = mods.LookaheadRatio * 225.0f;
            ImGui::TextColored(ImVec4(0.4f, 0.9f, 1.0f, 1.0f), ICON_FA_ROBOT " Pure Pursuit: L = %.1fm | PID Active", simL);
        }
        if (mods.UseSplineInterpolation) {
            ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), ICON_FA_CHART_LINE " Catmull-Rom: C1 Spline Smooth");
        }
        if (mods.LockMinDriftAngle) {
            ImGui::TextColored(ImVec4(0.2f, 0.85f, 1.0f, 1.0f), ICON_FA_TACHOMETER_ALT " Min-Drift Lock: %.1f deg (Giu ~200 km/h)", mods.MinDriftAngleVal);
        }
        if (mods.AutoSnapDrift) {
            ImGui::TextColored(ImVec4(1.0f, 0.8f, 0.2f, 1.0f), ICON_FA_BOLT " Snap Drift: Auto Reset 0.05s");
        }
        if (mods.ApexCornerCutter) {
            ImGui::TextColored(ImVec4(0.5f, 1.0f, 0.5f, 1.0f), ICON_FA_CUT " Apex Cutter: Rut ngan 8-12%%");
        }
        ImGui::TextColored(ImVec4(0.3f, 1.0f, 0.7f, 1.0f), ICON_FA_MAP_MARKER_ALT " Toa Do: X: %.1f | Z: %.1f | Yaw: %.1f deg [WP: %d/%d]",
            g_playerPos.x, g_playerPos.z, g_playerYaw, g_currentWaypointIndex + 1, g_totalWaypoints);
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
}

void RenderSpeedometer() {
    ImGuiIO& io = ImGui::GetIO();
    float time = (float)ImGui::GetTime();
    ImDrawList* drawList = ImGui::GetForegroundDrawList();
    if (!drawList) return;

    ImVec2 screenSize = io.DisplaySize;
    // Đặt ở góc dưới bên phải màn hình lái xe
    ImVec2 center = ImVec2(screenSize.x - 90.0f, screenSize.y - 85.0f);
    float radius = 55.0f;

    // Tính toán tốc độ hiển thị mượt mà
    static float currentSpeed = 0.0f;
    float targetSpeed = 215.0f + sinf(time * 1.5f) * 12.0f;
    if (mods.VoHanNitro || mods.NitroNhanh) {
        targetSpeed += 65.0f + sinf(time * 3.0f) * 10.0f;
    }
    if (mods.GiaToc) {
        targetSpeed = mods.GiaTocSpeed;
    }
    currentSpeed += (targetSpeed - currentSpeed) * io.DeltaTime * 4.0f;

    float maxSpeed = 350.0f;
    float speedRatio = currentSpeed / maxSpeed;
    if (speedRatio > 1.0f) speedRatio = 1.0f;
    if (speedRatio < 0.0f) speedRatio = 0.0f;

    // Nền đồng hồ đo tốc độ (Cyber Ring)
    drawList->AddCircleFilled(center, radius + 5.0f, IM_COL32(15, 18, 24, 210), 48);
    drawList->AddCircle(center, radius + 5.0f, IM_COL32(40, 50, 70, 240), 48, 2.0f);

    // Vạch đo góc từ 135 độ đến 405 độ (270 độ span)
    float startAngle = 2.35619449f; // 135 deg in rad
    float endAngle = 7.06858347f;   // 405 deg in rad
    float currentAngle = startAngle + (endAngle - startAngle) * speedRatio;

    // Vẽ vòng rỗng
    drawList->PathArcTo(center, radius - 6.0f, startAngle, endAngle, 36);
    drawList->PathStroke(IM_COL32(45, 55, 75, 180), false, 4.0f);

    // Vòng phát sáng theo tốc độ
    ImU32 arcColor = (currentSpeed > 280.0f) ? IM_COL32(255, 60, 80, 240) :
                     (currentSpeed > 220.0f) ? IM_COL32(0, 230, 255, 240) :
                                               IM_COL32(50, 220, 120, 240);
    drawList->PathArcTo(center, radius - 6.0f, startAngle, currentAngle, 36);
    drawList->PathStroke(arcColor, false, 5.0f);

    // Kim tốc độ
    ImVec2 needleEnd = ImVec2(center.x + cosf(currentAngle) * (radius - 12.0f),
                              center.y + sinf(currentAngle) * (radius - 12.0f));
    drawList->AddLine(center, needleEnd, arcColor, 2.5f);
    drawList->AddCircleFilled(center, 4.0f, IM_COL32(255, 255, 255, 255));

    // Chữ số hiển thị tốc độ số (Digital Readout)
    char speedBuf[32];
    snprintf(speedBuf, sizeof(speedBuf), "%d", (int)currentSpeed);
    ImVec2 txtSize = ImGui::CalcTextSize(speedBuf);
    drawList->AddText(ImVec2(center.x - txtSize.x * 0.5f, center.y - 18.0f), IM_COL32(255, 255, 255, 255), speedBuf);
    
    const char* unitText = "KM/H";
    ImVec2 unitSize = ImGui::CalcTextSize(unitText);
    drawList->AddText(ImVec2(center.x - unitSize.x * 0.5f, center.y + 2.0f), IM_COL32(180, 200, 220, 220), unitText);

    // Vạch Nitro status bar nhỏ phía dưới
    ImVec2 barP1 = ImVec2(center.x - 26, center.y + radius + 8);
    ImVec2 barP2 = ImVec2(center.x + 26, center.y + radius + 14);
    drawList->AddRectFilled(barP1, barP2, IM_COL32(20, 25, 35, 200), 3.0f);
    float nitroFill = (mods.VoHanNitro) ? 1.0f : (sinf(time * 2.0f) * 0.3f + 0.7f);
    ImVec2 barFill = ImVec2(barP1.x + 52.0f * nitroFill, barP2.y);
    drawList->AddRectFilled(barP1, barFill, IM_COL32(0, 210, 255, 240), 3.0f);
}

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

            // 4. BỘ CHỌN THEME PRESETS
            ImGui::TextColored(ImVec4(0.4f, 0.8f, 1.0f, 1.0f), ICON_FA_PALETTE "  Giao dien Theme:");
            if (ImGui::RadioButton("Dark", mods.ThemePreset == 0)) { TriggerHaptic(0); ApplyTheme(0); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Cyan", mods.ThemePreset == 1)) { TriggerHaptic(0); ApplyTheme(1); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Red", mods.ThemePreset == 2)) { TriggerHaptic(0); ApplyTheme(2); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Purple", mods.ThemePreset == 3)) { TriggerHaptic(0); ApplyTheme(3); }
            ImGui::SameLine();
            if (ImGui::RadioButton("Green", mods.ThemePreset == 4)) { TriggerHaptic(0); ApplyTheme(4); }

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
                    ApplyTheme(mods.ThemePreset);
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
    ApplyTheme(mods.ThemePreset);
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
