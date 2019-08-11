;=========================================
; 暗黑III猎魔人暗影飞刀AHK宏
; v3.4 20190811
; Present by 是梦~` QQ: 46317239
;=========================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Window
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#IfWinActive, ahk_class D3 Main Window Class

;可自定义的参数
;/////////////////////////////////////////////////////////
P_MsgBoxTimeOut := 0.8              ;提示框超时的时间，单位秒，默认0.8秒
P_AutoPickInterval := 50            ;自动拾取间隔，默认50毫秒
P_AutoBuyInterval := 50             ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30             ;自动购买次数，默认30次

P_HealthMonitorInterval := 300      ;血量低于30%探测间隔，默认300毫秒
P_ShadowStateProbeInterval := 500   ;暗影之力状态探测间隔，默认500毫秒
P_VengeanceCDProbeInterval := 75    ;复仇CD探测间隔，默认75毫秒，50~100
P_KnivesCDProbeInterval := 75       ;刀扇CD探测间隔，默认75毫秒，50~100
;/////////////////////////////////////////////////////////

All_On := 0                 ;总开关
;开关----------
F_AutoPick := 0             ;左键自动拾取开关
F_AutoProtect := 0          ;自动施放保护技能开关
F_AutoPotion := 1           ;血量低于30%自动喝药水
F_KeepShadowOn := 1         ;保持暗影之力开启状态
;状态----------
S_RAttack := 0              ;右键攻击状态
S_IsDead := 0               ;角色死亡状态 0：存活，1：死亡
S_CleanedUp := 0            ;角色死亡后清理状态 0：未清理，1：已清理


;右下角菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 说明
Menu, Tray, Add
Menu, Tray, Standard

;说明窗口
说明:
Gui Font, Bold
Gui Add, GroupBox, x10 y10 w500 h50, 键位设置
Gui Font
Gui Font, Bold cBlue
Gui Add, Text, x25 y26 w480 h23 +0x200, 1 暗影之力、2 影轮翻、3 复仇、4 刀扇、左 战宠、右 暗影飞刀
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w500 h250, 热键设置
Gui Font
Gui Add, Text, x20 y90 w480 h20 +0x200, ·F7：暂停/继续、ALT+F7：退出
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F1：开启或关闭宏功能（默认关闭，开启后保持暗影之力、血量低于30`%自动喝药水）
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F2：点击开始拾取（需要鼠标配合移动），再次点击停止
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F3：点击自动购买[30]次装备（鼠标放到要购买的装备上）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·2：暗影飞刀+影轮翻（非自动攻击时）、影轮翻（自动攻击时）
Gui Add, Text, x20 y215 w480 h20 +0x200, ·上滚轮：同上
Gui Add, Text, x20 y240 w480 h20 +0x200, ·滚轮点击/~：自动保持复仇、刀扇状态（CD探测间隔[75]毫秒），再次点击停止
Gui Add, Text, x20 y265 w480 h20 +0x200, ·下滚轮：自动施放暗影飞刀
Gui Add, Text, x20 y290 w480 h20 +0x200, ·右键：关闭自动施放暗影飞刀
Gui Font, Bold cRed
Gui Add, Text, x15 y325 w480 h20 +0x200, 注意：[]表示可自定义；适配1920x1080(16:9宽屏)！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w520 h350, 暗黑III猎魔人暗影飞刀AHK宏v3.4（是梦~`20190811）
Return

Gosub, 说明

;函数-------------------------
;显示一个在指定时间内自动消失的提示框
showMsg(content) {
    global P_MsgBoxTimeOut
    MsgBox 64, 消息, %content%, %P_MsgBoxTimeOut%
}

;True：角色死亡
isDead() {
    PixelGetColor, lifebar_color1, 32, 123, RGB
    PixelGetColor, lifebar_color2, 32, 127, RGB
    global S_IsDead, S_CleanedUp
    S_IsDead := (lifebar_color1 = 0x000000 && lifebar_color2 = 0x000000) ? 1 : 0
    If (S_IsDead = 1) {
        return True
    }
    Else {
        S_CleanedUp := 0
        return False
    }
}

;True：药水冷却中
isPotionCooling() {
    PixelGetColor, potion_color1, 1062, 1004 ,RGB
    PixelGetColor, potion_color2, 1062, 1007 ,RGB
    return (potion_color1 = 0x151617 && potion_color2 = 0x1D1E1F) ? False : True
}


;技能操作---------------------
;拾取
do_pick:
    Click, 1
return

;停止拾取
stop_pick:
    SetTimer, do_pick, Off
    F_AutoPick := 0
return

;喝药水
do_potion:
    Send, {q}
return

;暗影之力
do_shadow:
    PixelGetColor, shadow_off_color1, 634, 1004 ,RGB
    PixelGetColor, shadow_off_color2, 683, 1053 ,RGB
    If (shadow_off_color1 = 0x3B3838 && shadow_off_color2 = 0x3C3952) {
        Send, {1}
    }
return

;影轮翻
do_roll:
    Send, {2}
return

;复仇
do_vengeance:
    PixelGetColor, vengeance_cd_color, 791, 1007 ,RGB
    If (vengeance_cd_color = 0x570E01 || vengeance_cd_color = 0x560D00) {
        Send, {3}
    }
return

;刀扇
do_knives:
    PixelGetColor, knives_cd_color, 858, 1007 ,RGB
    If (knives_cd_color = 0x652015 || knives_cd_color = 0x641F14) {
        Send, {4}
    }
return

;停止自动施放复仇和刀扇
stop_protect:
    SetTimer, do_vengeance, Off
    SetTimer, do_knives, Off
    F_AutoProtect := 0
return


;热键&宏---------------------
;【F1键】开启或关闭宏功能
$F1::
All_On := !All_On
If (All_On) {
    If (F_AutoPotion) {
        SetTimer, health_monitor, %P_HealthMonitorInterval%
    }
    If (F_KeepShadowOn) {
        SetTimer, do_shadow, %P_ShadowStateProbeInterval%
    }
    showMsg("Macro On")
}
Else {
    If (F_AutoPick) {
        Gosub, stop_pick
    }
    IF (S_RAttack) {
        Gosub, stop_attack
    }
    If (F_AutoProtect) {
        Gosub, stop_protect
    }
    If (F_AutoPotion) {
        SetTimer, health_monitor, Off
    }
    If (F_KeepShadowOn) {
        SetTimer, do_shadow, Off
    }
    showMsg("Macro Off")
}
return

;角色血量监视器
health_monitor:
If (isDead()) {
    If (!S_CleanedUp) {
        ;角色死亡
        Gosub, when_character_dies
        ;清扫标记
        S_CleanedUp := 1
    }
}
Else {
    PixelGetColor, lifebar_color1, % 32 + Floor(60 * 0.3), 123 ,RGB
    PixelGetColor, lifebar_color2, % 32 + Floor(60 * 0.3), 127 ,RGB
    ;血量低于30%
    If (lifebar_color1 = 0x000000 && lifebar_color2 = 0x000000) {
        If (!isPotionCooling()) {
            ;喝药水
            Gosub, do_potion
        }
    }
}
return

;当角色死亡时执行的清理工作
when_character_dies:
    ;do somthing...
return

;【F2】开启、关闭自动拾取
$F2::
If (All_On) {
    F_AutoPick := !F_AutoPick
    If (F_AutoPick) {
        If (S_RAttack) {
            Gosub, stop_attack
        }
        SetTimer, do_pick, %P_AutoPickInterval%
    }
    Else {
        Goto, stop_pick
    }
}
return

;【F3键】一键购买30次装备
$F3:: 
If (All_On) {
    If (F_AutoPick) {
        Gosub, stop_pick
    }
    If (S_RAttack) {
        Gosub, stop_attack
    }
    Loop, %P_AutoBuyQuantity% {
        Click, Right, 1
        Sleep, %P_AutoBuyInterval%
    }
}
return

;【2】手动施放影轮翻
$*2::
;【鼠标滚轮向上】
~$*WheelUp::
If (All_On) {
    If (S_RAttack) {
        Goto, do_roll
    }
    Else {
        If (GetKeyState("LButton")) {
            Click, Left, , Up
            Click, Right, 1
            Sleep, 200
            Click, Left, , Down
            Gosub, do_roll
        }
        Else {
            If (!GetKeyState("RButton")) {
                Click, Right, 1
            }
            Goto, do_roll
        }
    }
}
Else {
    Goto, do_roll
}
return

;【鼠标滚轮向下】自动施放鼠标右键攻击
~$*WheelDown::
If (All_On) {
    If (F_AutoPick) {
        Gosub, stop_pick
    }
    ;防止左右键冲突
    If (GetKeyState("LButton")) {
        Click, Left, , Up
    }
    S_RAttack := 1
    Click, Right, , Down
}
return

;【鼠标右键】手动点击鼠标右键时结束自动攻击状态
~$RButton::
stop_attack:
If (S_RAttack) {
    Click, Right, , Up
    S_RAttack := 0
}
return

;【`键】数字1左边的键
~$`::
;【鼠标滚轮点击】自动探测复仇、刀扇冷却状态，并自动施放
$MButton::
If (All_On) {
    F_AutoProtect := !F_AutoProtect
    If (F_AutoProtect) {
        ;Gosub, do_shadow
        SetTimer, do_vengeance, %P_VengeanceCDProbeInterval%
        SetTimer, do_knives, %P_KnivesCDProbeInterval%
    }
    Else {
        Goto, stop_protect
    }
}
return


;============================
;【F7】暂停/继续
$F7::Pause

;============================
;【ALT+F7】关闭本程序
$*!F7::ExitApp