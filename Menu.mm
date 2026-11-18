#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#include <map>
#include <string>
#include <cmath>
#include "Menu.h"
#include "ImGui/MenuUtils.h"
#import "ImGui/ImGuiDrawViewX.h"

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

// Dán base vô đây
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

// --- BÀI TEST SINH TỬ ---
__attribute__((constructor))
static void initMenu() {
    // Đợi 4 giây cho game load xong UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // TEST 1: Dylib có thực sự được nạp vào tiến trình game không?
        NSLog(@"[TEST_SINH_TU] 1. Dylib da load vao game thanh cong!");
        
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"TEST 1" message:@"Dylib da load!" preferredStyle:UIAlertControllerStyleAlert];
        [alert1 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert1 animated:YES completion:nil];

        // TEST 2: Hàm khởi tạo UI (ImGui/Metal) có bị crash không?
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"[TEST_SINH_TU] 2. Bat dau khoi tao ImGui...");
            [ImGuiDrawViewX showChange:YES];
            
            // TEST 3: Nếu qua được TEST 2, kiểm tra xem ImGui có thực sự chạy vòng lặp render không?
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"[TEST_SINH_TU] 3. ImGui da khoi tao xong. Neu khong thay menu thi do loi render Metal!");
                
                UIAlertController *alert3 = [UIAlertController alertControllerWithTitle:@"TEST 3" message:@"Code chay den day la song sot. Neu khong thay menu => loi ImGui Metal." preferredStyle:UIAlertControllerStyleAlert];
                [alert3 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert3 animated:YES completion:nil];
            });
        });

        // Load config và mods (để tránh lỗi offset)
        LoadConfig();
        ApplyTheme(mods.ThemePreset);
        ApplyFPS(mods.TargetFPS);
        LoadMods(); 
    });
}
