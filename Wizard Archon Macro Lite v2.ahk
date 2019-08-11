;=========================================
; 暗黑III魔法师维尔御法者AHK宏
; Lite Edition v2.5 20190811
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

;技能设置
;/////////////////////////////////////////////////////////
K_WizardArchon := 2          ;黑人技能按键，默认2键
;/////////////////////////////////////////////////////////

;可自定义的参数
;/////////////////////////////////////////////////////////
P_MsgBoxTimeOut := 0.8       ;提示框超时的时间，单位秒，默认0.8秒
P_LAttackInterval := 50      ;鼠标左键连点间隔，默认50毫秒
P_AutoWaveInterval := 320    ;自动施放冲击波间隔，默认320毫秒
P_DelayOfSlowTime := -600    ;开黑人后施放时间延缓技能的延迟，默认600毫秒
P_AutoTpInterval := 880      ;自动传送间隔，默认880毫秒
P_AutoPickInterval := 50     ;自动拾取间隔，默认50毫秒
P_AutoBuyInterval := 50      ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30      ;自动购买次数，默认30次
;/////////////////////////////////////////////////////////

All_On := 0                 ;总开关
;开关----------
F_AutoPick := 0             ;自动拾取开关
F_AutoTp := 0               ;自动传送开关
F_BlackAutoCast := 1        ;开黑人自动施放技能开关
;状态----------
S_LAttack := 0              ;左键自动攻击状态
S_RAttack := 0              ;右键自动攻击状态
S_AutoWave := 0             ;自动施放1技能状态
S_IsBlack := 0              ;黑人状态   0：白人、1：黑人

;注册可自定义热键
Hotkey, ~$%K_WizardArchon%, active_archon

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
Gui Add, Text, x25 y26 w480 h23 +0x200, 1、护甲、2：御法者、3：传送、4、魔法武器、左：黑洞、右：奥术洪流
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w500 h275, 热键设置
Gui Font
Gui Add, Text, x20 y90 w480 h20 +0x200, ·F7：暂停/继续、ALT+F7：退出
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F1：开启或关闭宏功能（默认关闭，运行后需手动开启）
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F2：点击后开始拾取（需要鼠标配合移动），再次点击停止
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F3：自动购买[30]次装备（鼠标放到要购买的装备上）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·F5：开启或关闭在黑人状态时自动施放技能（时间延缓、冲击波）
Gui Add, Text, x20 y215 w480 h20 +0x200, ·[2]键：开御法者后，自动开时间延缓，每隔[320]毫秒施放冲击波（~键停止）
Gui Add, Text, x20 y240 w480 h20 +0x200, ·上滚轮：强制站立（按下Shift键），并自动进行左键技能攻击
Gui Add, Text, x20 y265 w480 h20 +0x200, ·下滚轮：停止上滚轮功能，并自动施放右键技能攻击
Gui Add, Text, x20 y290 w480 h20 +0x200, ·滚轮点击：每隔[880]毫秒自动施放传送技能，再次点击停止
Gui Add, Text, x20 y315 w480 h20 +0x200, ·右键：关闭自动右键技能攻击
Gui Font, Bold cRed
Gui Add, Text, x15 y350 w480 h20 +0x200, 注意：[]表示可自定义；如需在游戏中使用上下滚轮，必先关闭宏功能！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w520 h375, 暗黑III魔法师维尔御法者AHK宏简化版v2.5（是梦~`20190811）
Return

Gosub, 说明

;显示一个在指定时间内自动消失的提示框
showMsg(content) {
    global P_MsgBoxTimeOut
    MsgBox 64, 消息, %content%, %P_MsgBoxTimeOut%
}

;技能操作---------------------
;鼠标左键攻击
do_lattack:
    Click, Left, 1
return

;停止鼠标左键自动攻击
stop_lattack:
    SetTimer, do_lattack, Off
    Send, {Shift Up}
    S_LAttack := 0    
return

;传送
do_tp:
    Send, {3}
return

;停止自动传送
stop_tp:
    SetTimer, do_tp, Off
return

;御法者
do_archon:
    Send, {%K_WizardArchon%}
    S_IsBlack := 1
    Sleep, 50   ;给系统、游戏的反应时间
    SetTimer, lost_archon, -20000
return

;御法者状态消失
lost_archon:
    S_IsBlack := 0
    If (S_AutoWave) {
        Gosub, stop_wave
    }
return

;施放时间延缓
do_slowTime:
    send, {2}
return

;施放黑人冲击波(1技能)
do_wave:
    Send, {1}
return

;停止施放黑人冲击波
stop_wave:
    SetTimer, do_wave, Off
    S_AutoWave := 0
return


;热键&宏---------------------
;【F1键】开启或关闭宏功能
$F1::
All_On := !All_On
If (All_On) {
    showMsg("Macro On")
}
Else {
    If (S_LAttack) {
        Gosub, stop_lattack
        F_AutoPick := 0
    }
    If (S_RAttack) {
        Gosub, stop_rattack
    }
    If (F_AutoTp) {
        Gosub, stop_tp
        F_AutoTp := 0
    }
    If (S_AutoWave) {
        Gosub, stop_wave
    }
    showMsg("Macro Off")
}
return

;【F2】开启、关闭自动拾取
$F2::
If (All_On) {
    F_AutoPick := !F_AutoPick
    If (F_AutoPick) {
        If (S_LAttack) {
            Send, {Shift Up}
        }
        Else {
            If (S_RAttack) {
                Gosub, stop_rattack
            }
            SetTimer, do_lattack, %P_AutoPickInterval%
            S_LAttack := 1
        }
    }
    Else {
        Goto, stop_lattack
    }
}
return

;【F3键】一键购买装备
$F3:: 
If (All_On) {
    If (S_LAttack) {
        Gosub, stop_lattack
        F_AutoPick := 0
    }
    If (S_RAttack) {
        Gosub, stop_rattack
    }
    Loop, %P_AutoBuyQuantity% {
        Click, Right, 1
        Sleep, %P_AutoBuyInterval%
    }
}
return

;【F5】开启、关闭黑人状态自动技能（冲击波、时间延缓）
$F5::
If (All_On) {
    F_BlackAutoCast := !F_BlackAutoCast
    If (F_BlackAutoCast) {
        showMsg("BlackAutoCast On")
    }
    If (!F_BlackAutoCast) {
        If (S_AutoWave) {
            Gosub, stop_wave
        }
        showMsg("BlackAutoCast Off")
    }
}
return

;【鼠标滚轮向上】开启鼠标左键攻击
~$*WheelUp::
;S_LAttack防止重复调用
If (All_On && (!S_LAttack || F_AutoPick)) {
    If (S_RAttack) {
        Gosub, stop_rattack
    }
    Send, {Shift Down}  ;按下Shift
    If (F_AutoPick) {
        F_AutoPick := 0
    }
    Else {
        SetTimer, do_lattack, %P_LAttackInterval%
        S_LAttack := 1
    }
}
return

;【鼠标滚轮向下】鼠标右键攻击（手动点击鼠标右键时可弹起）
~$*WheelDown::
If (All_On) {
    If (S_LAttack) {
        Gosub, stop_lattack
        F_AutoPick := 0
    }
    Click, Down, Right  ;按下鼠标右键
    S_RAttack := 1
}
return

;【鼠标右键】主动点击鼠标右键时
~$RButton::
stop_rattack:
If (S_RAttack) {
    Click, Up, Right    ;松开鼠标右键
    S_RAttack := 0
}
return

;【鼠标滚轮点击】开启、关闭自动传送
$MButton::
If (All_On) {
    F_AutoTp := !F_AutoTp
    If (F_AutoTp) {
        SetTimer, do_tp, %P_AutoTpInterval%
    }
    Else {
        Goto, stop_tp
    }
}
return

;【默认2键】可自定义热键
;施放御法者
;开时间延缓
;自动施放冲击波，20秒后停止
;~$2::
active_archon:
If (All_On) {
    If (!S_IsBlack) {
        Gosub, do_archon
        If (F_BlackAutoCast) {
            SetTimer, do_slowTime, %P_DelayOfSlowTime%
            SetTimer, do_wave, %P_AutoWaveInterval%
            S_AutoWave := 1
        }
    }
    Else {
        Send, {%K_WizardArchon%}
    }
}
Else {
    Send, {%K_WizardArchon%}
}
return

;【`键】数字1左边的键
;强制停止自动施放黑人冲击波
~$`::
If (All_On) {
    If (S_AutoWave) {
        Gosub, stop_wave
    }
}
return


;============================
;【F7】暂停/继续
$F7::Pause

;============================
;【ALT+F7关闭本程序】
$*!F7::ExitApp