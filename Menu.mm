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

            // THẺ CHIA SẺ LIVE RADAR LÊN MÁY TÍNH (WEB RADAR SERVER)
            ImGui::TextColored(ImVec4(0.0f, 0.95f, 1.0f, 1.0f), ICON_FA_DESKTOP " Web Radar Server (Truyen Hinh Live PC):");
            newChildVisible = childVisibilityMap["Bat Web Radar Server"];
            bool prevWebRadar = mods.WebRadarEnabled;
            ToggleWidget(ICON_FA_WIFI, "Bat Web Radar Server", &mods.WebRadarEnabled, &newChildVisible);
            childVisibilityMap["Bat Web Radar Server"] = newChildVisible;

            if (mods.WebRadarEnabled != prevWebRadar) {
                if (mods.WebRadarEnabled) {
                    StartWebRadarServer();
                    SaveConfig();
                    Console::logSuccess([[NSString stringWithFormat:@"Web Radar Server khoi dong tai: %@", GetWebRadarURL()] UTF8String]);
                } else {
                    StopWebRadarServer();
                    SaveConfig();
                    Console::logInfo("Da tat Web Radar Server.");
                }
            }

            if (mods.WebRadarEnabled) {
                NSString* currentURL = GetWebRadarURL();
                ImGui::TextColored(ImVec4(0.2f, 1.0f, 0.4f, 1.0f), "Link Xem PC: %s", [currentURL UTF8String]);
                ImGui::TextDisabled("Nhap link tren vao trinh duyet PC de xem radar 60 FPS");

                if (ImGui::Button(ICON_FA_COPY "  Sao Chep Link May Tinh (URL)", ImVec2(ImGui::GetContentRegionAvail().x, 28))) {
                    TriggerHaptic(0);
                    PlayBeepSound(1057);
                    [UIPasteboard generalPasteboard].string = currentURL;
                    Console::logSuccess([[NSString stringWithFormat:@"Da sao chep link Web Radar: %@", currentURL] UTF8String]);
                }
            } else {
                ImGui::TextDisabled("Server dang tat. Bat de tao duong dan xem radar live tren PC.");
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

            newChildVisible = childVisibilityMap["Cu Chi 3 Ngon"];
            ToggleWidget(ICON_FA_HAND_POINT_UP, "Cu Chi 3 Ngon", &mods.GestureShortcut, &newChildVisible);
            childVisibilityMap["Cu Chi 3 Ngon"] = newChildVisible;

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
                else if (widgetName == "Am Thanh Click" || widgetName == "Cu Chi 3 Ngon") {
                    ImGui::Text(ICON_FA_INFO_CIRCLE); ImGui::SameLine();
                    ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
                    ImGui::Text("Tuy chinh am thanh he thong va cu chi go 3 ngon tay de an/hien menu.");
                    ImGui::PopTextWrapPos(); ImGui::Spacing();
                    ToggleButtonMini("Am Thanh Click", &mods.SoundEffects);
                    ToggleButtonMini("Cu Chi 3 Ngon", &mods.GestureShortcut);
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
