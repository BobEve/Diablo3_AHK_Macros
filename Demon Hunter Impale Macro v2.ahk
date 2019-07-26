;=========================================
; 暗黑III猎魔人暗影飞刀AHK宏
; v2.3 20190724 
; Present by 是梦~` QQ: 46317239
;=========================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
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
P_MsgBoxTimeOut := 0.8       ;提示框超时的时间，单位秒，默认0.8秒
P_VengeanceInterval := 150   ;复仇施放间隔，默认150毫秒
P_KnivesInterval := 150      ;刀扇施放间隔，默认150毫秒
P_AutoPickInterval := 50     ;自动拾取间隔，默认50毫秒
P_AutoBuyInterval := 50      ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30      ;自动购买次数，默认30次
;/////////////////////////////////////////////////////////

All_On := 0                 ;总开关
;开关----------
AutoPick_Flag := 0          ;左键自动拾取开关
AutoProtect_Flag := 0       ;自动施放保护技能开关
;状态----------
Attack_State := 0           ;右键攻击状态


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
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F1：开启或关闭宏功能（默认关闭，运行后需手动开启）
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F2：点击开始拾取（需要鼠标配合移动），再次点击停止
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F3：点击自动购买[30]次装备（鼠标放到要购买的装备上）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·2：暗影飞刀+影轮翻（非自动攻击时）、影轮翻（自动攻击时）
Gui Add, Text, x20 y215 w480 h20 +0x200, ·上滚轮：同上
Gui Add, Text, x20 y240 w480 h20 +0x200, ·滚轮点击/~：点击立即施放暗影之力，每隔[150]毫秒自动施放复仇、刀扇，再次点击停止
Gui Add, Text, x20 y265 w480 h20 +0x200, ·下滚轮：自动施放暗影飞刀
Gui Add, Text, x20 y290 w480 h20 +0x200, ·右键：关闭自动施放暗影飞刀
Gui Font, Bold cRed
Gui Add, Text, x15 y325 w480 h20 +0x200, 注意：[]表示可自定义；如需在游戏中使用上下滚轮，必先关闭宏功能！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w520 h350, 暗黑III猎魔人暗影飞刀AHK宏v2.3（是梦~`20190724）
Return

Gosub, 说明

;显示一个在指定时间内自动消失的提示框
showMsg(content) {
    global P_MsgBoxTimeOut
    MsgBox 64, 消息, %content%, %P_MsgBoxTimeOut%
}

;技能操作---------------------
;拾取
do_pick:
    Click, 1
return

;停止拾取
stop_pick:
    SetTimer, do_pick, Off
    AutoPick_Flag := 0
return

;暗影之力
do_shadow:
    Send, {1}
return

;影轮翻
do_roll:
    Send, {2}
return

;复仇
do_vengeance:
    Send, {3}
return

;刀扇
do_knives:
    Send, {4}
return

;停止自动施放复仇和刀扇
stop_protect:
    SetTimer, do_vengeance, Off
    SetTimer, do_knives, Off
    AutoProtect_Flag := 0
return


;热键&宏---------------------
;【F1键】开启或关闭宏功能
$F1::
All_On := !All_On
If (All_On) {
    showMsg("Macro On")
}
Else {
    If (AutoPick_Flag) {
        Gosub, stop_pick
    }
    IF (Attack_State) {
        Gosub, stop_attack
    }
    If (AutoProtect_Flag) {
        Gosub, stop_protect
    }
    showMsg("Macro Off")
}
return

;【F2】开启、关闭自动拾取
$F2::
If (All_On) {
    AutoPick_Flag := !AutoPick_Flag
    If (AutoPick_Flag) {
        If (Attack_State) {
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
    If (AutoPick_Flag) {
        Gosub, stop_pick
    }
    If (Attack_State) {
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
    If (Attack_State) {
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
    If (AutoPick_Flag) {
        Gosub, stop_pick
    }
    ;防止左右键冲突
    If (GetKeyState("LButton")) {
        Click, Left, , Up
    }
    Attack_State := 1
    Click, Right, , Down
}
return

;【鼠标右键】手动点击鼠标右键时结束自动攻击状态
~$RButton::
stop_attack:
If (Attack_State) {
    Click, Right, , Up
    Attack_State := 0
}
return

;【`键】数字1左边的键
~$`::
;【鼠标滚轮点击】立即施放1次暗影之力，每隔200毫秒自动施放复仇、刀扇
$MButton::
If (All_On) {
    AutoProtect_Flag := !AutoProtect_Flag
    If (AutoProtect_Flag) {
        Gosub, do_shadow
        SetTimer, do_vengeance, %P_VengeanceInterval%
        SetTimer, do_knives, %P_KnivesInterval%
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