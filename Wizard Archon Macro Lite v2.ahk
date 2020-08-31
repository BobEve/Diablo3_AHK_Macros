;=========================================
; 暗黑III魔法师维尔御法者AHK宏
; Lite Edition v2.11 20190816
; Present by 是梦~` QQ:46317239
;=========================================
#NoEnv
;#Warn, All, StdOut
SetWorkingDir %A_ScriptDir%
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#IfWinActive, ahk_class D3 Main Window Class

;技能按键设置
;/////////////////////////////////////////////////////////
global K_WizardArchon := 2   ;御法者技能按键，默认2键

;可自定义的参数
;/////////////////////////////////////////////////////////
P_MsgBoxTimeOut := 0.8       ;提示框超时的时间，单位秒，默认0.8秒
P_LAttackInterval := 30      ;左键攻击间隔，默认30毫秒，范围20~50
P_AutoMoveInterval := 50     ;自动移动/拾取间隔，默认50毫秒
P_AutoBuyInterval := 50      ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30      ;自动购买次数，默认30次
P_AutoBlastInterval := 320   ;御法者元素爆术施放间隔，默认320毫秒
P_DelayOfSlowTime := -600    ;激活御法者后施放时间延缓技能的延迟，默认600毫秒

;标志、状态变量（不可修改）
;/////////////////////////////////////////////////////////
All_On := 0                 ;总开关
;开关----------
F_AutoMove := 0             ;自动移动/拾取开关
F_AutoCastInArchon := 1     ;御法者激活后自动施放时间延缓及元素爆术的开关
;状态----------
S_RAttack := 0              ;右键自动攻击状态
S_AutoClick := 0            ;左键连点状态
S_AutoBlast := 0            ;御法者形态时，自动施放元素爆术（1技能）技能的状态
S_IsArchon := 0             ;御法者形态 0：白人，1：黑人


;脚本主体
;/////////////////////////////////////////////////////////
;注册可自定义热键
Hotkey, ~$%K_WizardArchon%, ActiveArchon

;右下角菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 说明
Menu, Tray, Add
Menu, Tray, Standard

;说明窗口
说明:
Gui Font, Bold
Gui Add, GroupBox, x10 y10 w500 h50, 键位设置
Gui Font, cBlue
Gui Add, Text, x25 y26 w480 h23 +0x200, 1：护甲、2：御法者、[3：传送]、4：魔法武器、左：黑洞、右：奥术洪流
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w500 h275, 热键设置
Gui Font
Gui Add, Text, x20 y90 w480 h20 +0x200, ·F1：开启/关闭宏功能（默认关闭，运行后需手动开启）
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F2：暂停/继续宏功能；·F7：退出脚本
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F3：自动购买[30]次装备（鼠标指针放到要购买的装备上）
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F5：开启或关闭，每当御法者激活后自动施放时间延缓及元素爆术
Gui Add, Text, x20 y190 w480 h20 +0x200, ·[2]键：激活御法者形态，自动施放时间延缓、每隔[320]毫秒施放元素爆术
Gui Add, Text, x20 y215 w480 h20 +0x200, ·上滚轮：强制站立（按下Shift键），并开始持续左键技能攻击
Gui Add, Text, x20 y240 w480 h20 +0x200, ·下滚轮：开始持续右键技能攻击
Gui Add, Text, x20 y265 w480 h20 +0x200, ·右键：停止右键技能攻击
Gui Add, Text, x20 y290 w480 h20 +0x200, ·前进（侧）/中键：御法者形态时，强制停止正在自动施放的元素爆术
Gui Add, Text, x20 y315 w480 h20 +0x200, ·后退（侧）/[~]键：点击后开始移动/拾取（需要鼠标配合移动），再次点击停止
Gui Font, Bold cRed
Gui Add, Text, x15 y350 w480 h20 +0x200, 注意：如需在游戏中使用上下滚轮，必须先关闭宏功能！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w520 h375, 暗黑III魔法师维尔御法者AHK宏简化版v2.11（是梦~`` QQ:46317239）
Return

Gosub, 说明


;通用函数
;/////////////////////////////////////////////////////////
;显示一个在指定时间内自动消失的提示框
showMsg(content) {
    global P_MsgBoxTimeOut
    MsgBox 64, 消息, %content%, %P_MsgBoxTimeOut%
}

autoFunction(func, interval) {
    SetTimer, %func%, %interval%
}

stopAutoFunction(func) {
    SetTimer, %func%, Off
}

;技能操作
;/////////////////////////////////////////////////////////
;鼠标左键点击
doLClick() {
    Click, Left, 1
}

;鼠标左键连点
autoLClick(pressShift, interval) {
    If (pressShift = 1 && !GetKeyState("Shift")) {
        Send, {Shift Down}
    }
    Else If (pressShift = 0 && GetKeyState("Shift")) {
        Send, {Shift Up}
    }
    autoFunction("doLClick", interval)
    global S_AutoClick := 1
}

;停止鼠标左键连点
stopAutoLClick(keepState := 0) {
    If (!keepState) {
        stopAutoFunction("doLClick")
    }
    If (GetKeyState("Shift")) {
        Send, {Shift Up}
    }
    global S_AutoClick := 0, F_AutoMove := 0
}

;鼠标右键攻击（按下）
doRAttack() {
    Click, Down, Right
    global S_RAttack := 1
}

;停止鼠标右键攻击（松开）
stopRAttack() {
    Click, Up, Right
    global S_RAttack := 0
}

;御法者
doArchon() {
    Send, {%K_WizardArchon%}
}

;御法者元素爆术（黑人1技能）
doArchonBlast() {
    global
    If (S_IsArchon) {
        Send, {1}
    }
}

;御法者时间延缓（黑人2技能）
doArchonSlowTime() {
    global
    If (S_IsArchon) {
        Send, {2}
    }
}

;自动元素爆术
autoBlast() {
    global 
    autoFunction("doArchonBlast", P_AutoBlastInterval)
    S_AutoBlast := 1
}

;停止自动元素爆术
stopAutoBlast() {
    stopAutoFunction("doArchonBlast")
    global S_AutoBlast := 0
}

;御法者形态消失
lostArchon() {
    global
    S_IsArchon := 0
    If (S_AutoBlast) {
        stopAutoBlast()
    }
    If (S_AutoClick && !F_AutoMove) {
        ;如果御法者状态结束时，正处于左键连点攻击模式
        ;则转换到自动移动/拾取模式
        autoLClick(0, P_AutoMoveInterval)
        F_AutoMove := 1
    }
}

;激活御法者形态
getArchon() {
    global
    doArchon()
    S_IsArchon := 1
    Sleep, 100   ;给系统、游戏的反应时间
    SetTimer, lostArchon, % P_AutoBlastInterval - 20000
}


;热键&宏
;/////////////////////////////////////////////////////////
;*****************************
;热键：【F1】
;功能：开启或关闭宏功能
;*****************************
$F1::
All_On := !All_On
If (All_On) {
    showMsg("Macro On")
}
Else {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    If (S_RAttack) {
        stopRAttack()
    }
    If (S_AutoBlast) {
        stopAutoBlast()
    }
    showMsg("Macro Off")
}
return

;*****************************
;热键：【F3】
;功能：一键购买装备
;*****************************
$F3:: 
If (All_On) {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    If (S_RAttack) {
        stopRAttack()
    }
    Loop, %P_AutoBuyQuantity% {
        Click, Right, 1
        Sleep, %P_AutoBuyInterval%
    }
}
return

;*****************************
;热键：【F5】
;功能：开启或关闭，每当御法者激活后自动施放时间延缓及元素爆术
;*****************************
$F5::
If (All_On) {
    F_AutoCastInArchon := !F_AutoCastInArchon
    If (F_AutoCastInArchon) {
        showMsg("AutoCastInArchon On")
    }
    Else {
        If (S_AutoBlast) {
            stopAutoBlast()
        }
        showMsg("AutoCastInArchon Off")
    }
}
return

;*****************************
;热键：【2】可自定义
;功能：激活御法者形态；变身成功后，自动施放时间延缓（1次）、元素爆术（循环）
;*****************************
;~$2::
ActiveArchon:
If (All_On && !S_IsArchon) {
    getArchon()
    If (F_AutoCastInArchon) {
        autoFunction("doArchonSlowTime", P_DelayOfSlowTime)
        autoBlast()
    }
}
Else {
    Send, {%K_WizardArchon%}
}
return

;*****************************
;热键：【上滚轮】
;功能：开始鼠标左键攻击
;*****************************
~$*WheelUp::
If (All_On && (!S_AutoClick || F_AutoMove)) {
    If (S_RAttack) {
        stopRAttack()
    }
    autoLClick(1, P_LAttackInterval)
    F_AutoMove := 0
}
return

;*****************************
;热键：【下滚轮】
;功能：开始鼠标右键攻击
;*****************************
~$*WheelDown::
If (All_On && !S_RAttack) {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    doRAttack()
}
return

;*****************************
;热键：【右键】主动点击鼠标右键时
;功能：停止鼠标右键攻击
;*****************************
~$RButton::
If (All_On && S_RAttack) {
    stopRAttack()
}
return

;*****************************
;热键：【`键】数字1前面的键、【后退】鼠标侧键
;功能：开启、关闭自动移动/拾取
;*****************************
~$`::
$XButton1::
If (All_On) {
    F_AutoMove := !F_AutoMove
    If (F_AutoMove) {
        If (S_RAttack) {
            stopRAttack()
        }
        autoLClick(0, P_AutoMoveInterval)
    }
    Else {
        stopAutoLClick(0)
    }
}
return

;*****************************
;热键：【中键】滚轮、【前进】鼠标侧键
;功能：御法者形态时，强制停止正在自动施放的元素爆术
;*****************************
$MButton::
$XButton2::
If (All_On && S_AutoBlast) {
    stopAutoBlast()
}
return


;*****************************
;热键：【F2】
;功能：暂停/继续
;*****************************
$F2::Pause

;*****************************
;热键：【F7】
;功能：退出脚本
;*****************************
$F7::ExitApp
