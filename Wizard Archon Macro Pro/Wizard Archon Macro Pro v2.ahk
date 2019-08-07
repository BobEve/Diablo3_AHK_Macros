;=========================================
; 暗黑III魔法师维尔御法者AHK宏
; Pro Edition v2.9 20190807
; Present by 是梦~` QQ: 46317239
;=========================================
#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Window
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

;技能设置
;/////////////////////////////////////////////////////////
K_WizardArchon := 2          ;黑人技能按键，默认2键
;护甲与魔法武器不可放置在2技能栏，只允许在1、3、4技能栏放置
K_WizardArmor := 1           ;护甲技能，默认1键
K_WizardMagicWeapon := 4     ;魔法武器，默认4键
;/////////////////////////////////////////////////////////
;1234技能栏范围（适配1920*1080宽屏）
P_SkillArea_X1 := 627
P_SkillArea_Y1 := 997
P_SkillArea_X2 := 891
P_SkillArea_Y2 := 1060
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
;----------------------------
P_AutoProtectInterval := 500        ;自动保护探测间隔，默认500毫秒
P_HealthMonitorInterval := 300      ;血量低于30%探测间隔，默认300毫秒
P_AutoBlackInterval := 100          ;自动黑人探测间隔，默认100毫秒，范围50-200
P_ChantodoMonitorInterval := 100    ;迦陀朵Buff探测间隔，默认100毫秒，范围50-200
;/////////////////////////////////////////////////////////

All_On := 0                 ;总开关
;开关----------
F_AutoPick := 0             ;自动拾取开关
F_AutoTp := 0               ;自动传送开关
F_AutoBlack := 0            ;自动黑人开关
F_AutoProtect := 1          ;自动开护甲、魔法武器
;状态----------
S_LAttack := 0              ;左键自动攻击状态
S_RAttack := 0              ;右键自动攻击状态
S_AutoWave := 0             ;自动施放1技能状态
S_IsBlack := 0              ;黑人状态 0：白人，1：黑人
S_ChantodoBuff20 := 0       ;迦陀朵buff状态 0：非20层，1：20层
S_IsDead := 0               ;角色死亡状态 0：存活，1：死亡


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
Gui Add, GroupBox, x10 y10 w510 h50, 键位设置
Gui Font
Gui Font, Bold cBlue
Gui Add, Text, x25 y26 w480 h23 +0x200, [1、护甲]、2：御法者、3：传送、[4、魔法武器]、左：黑洞、右：奥术洪流
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w510 h275, 热键设置
Gui Font
Gui Add, Text, x20 y90 w480 h20 +0x200, ·F7：暂停/继续、ALT+F7：退出
Gui Add, Text, x20 y115 w490 h20 +0x200, ·F1：开启/关闭宏功能（默认关闭，开启后保持护甲、魔法武器，血量低于30`%自动喝药水）
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F2：点击后开始拾取（需要鼠标配合移动），再次点击停止
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F3：自动购买[30]次装备（鼠标放到要购买的装备上）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·F4：开启自动黑人功能（默认关闭，迦陀朵buff20层自动开黑人、施放冲击波）
Gui Add, Text, x20 y215 w480 h20 +0x200, ·F5：关闭自动黑人功能
Gui Add, Text, x20 y240 w480 h20 +0x200, ·上滚轮：强制站立（按下Shift键），并自动进行左键技能攻击
Gui Add, Text, x20 y265 w480 h20 +0x200, ·下滚轮：停止上滚轮功能，并自动施放右键技能攻击
Gui Add, Text, x20 y290 w480 h20 +0x200, ·滚轮点击：每隔[880]毫秒自动施放传送技能，再次点击停止
Gui Add, Text, x20 y315 w480 h20 +0x200, ·右键：关闭自动右键技能攻击
Gui Font, Bold cRed
Gui Add, Text, x15 y350 w480 h20 +0x200, 注意：[]表示可自定义；仅适配1920x1080(16:9宽屏)！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w530 h375, 暗黑III魔法师维尔御法者AHK宏加强版v2.9（是梦~`20190807）
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
    global S_IsDead
    S_IsDead := (lifebar_color1 = 0x000000 && lifebar_color2 = 0x000000) ? 1 : 0
    return S_IsDead = 1
}

;True：药水冷却中
isPotionCooling() {
    PixelGetColor, potion_color1, 1062, 1004 ,RGB
    PixelGetColor, potion_color2, 1062, 1007 ,RGB
    return (potion_color1 = 0x151617 && potion_color2 = 0x1D1E1F) ? False : True
}


;技能操作---------------------
;什么都不做
void:
return

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

;喝药水
do_potion:
    Send, {q}
return

;护甲
do_armor:
If (!S_IsBlack) {
    ;暴风护甲
    ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\strom_armor.png
    If (ErrorLevel > 0) {
        ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\strom_armor1.png
        If (ErrorLevel > 0) {
            ;能量护甲
            ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\energy_armor.png
            If (ErrorLevel > 0) {
                ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\energy_armor1.png
            }
        }
    }
    If (ErrorLevel = 0) {
        Send, {%K_WizardArmor%}
    }
}
return

;魔法武器
do_magicWeapon:
If (!S_IsBlack) {
    ;魔法武器
    ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\magic_weapon.png
    If (ErrorLevel > 0) {
        ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\magic_weapon1.png
    }
    If (ErrorLevel = 0) {
        Send, {%K_WizardMagicWeapon%}
    }
}
return

;关闭自动保护
stop_protect:
    SetTimer, do_armor, Off
    SetTimer, do_magicWeapon, Off
return

;御法者
do_archon:
    Send, {%K_WizardArchon%}
    S_IsBlack := 1
    S_ChantodoBuff20 := 0
    Gosub, archon_ready
    SetTimer, lost_archon, -20000
return

;判断游戏中变身黑人成功
archon_ready:
loop_count := 0
Loop {
    If (S_IsDead) {
        Goto, void
    }
    Else {
        ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\skill4.png
        If (ErrorLevel = 0) {
            Break
        }
        loop_count++
        If (loop_count > 5) {
            Goto, do_archon
        }
    }
    Sleep, 20
}
Until (!All_On)
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
    If (F_AutoProtect) {
        Gosub, auto_protect_on
    }
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
    If (F_AutoBlack) {
        Gosub, auto_black_off
    }
    If (F_AutoProtect) {
        Gosub, auto_protect_off
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

;【F4键】开启御法者监视器
;白人状态下20层buff时，自动开黑人、开时间延缓
;黑人状态下自动施放冲击波
$F4::
If (All_On && !F_AutoBlack) {
    F_AutoBlack := 1
    S_IsBlack := 0
    S_ChantodoBuff20 := 0
    SetTimer, chantodo_monitor, %P_ChantodoMonitorInterval%
    Goto, auto_black
}
return

;【F5键】关闭御法者监视器
$F5::
If (All_On) {
    Goto, auto_black_off
}
return

auto_black_off:
    F_AutoBlack := 0
    SetTimer, chantodo_monitor, Off
    S_ChantodoBuff20 := 0
return

;迦陀朵buff监视器
chantodo_monitor:
    ;仅在白人状态下执行
    If (!S_IsBlack && !S_ChantodoBuff20) {
        ;两个buff的范围
        ImageSearch, FoundX, FoundY, 663, 908, 766, 958, %A_ScriptDir%\chantodo.png
        If (ErrorLevel > 0) {
            ;buff位于第2顺位
            ImageSearch, FoundX, FoundY, 663, 908, 766, 958, %A_ScriptDir%\chantodo1.png
        }
        S_ChantodoBuff20 := ErrorLevel = 0 ? 1 : 0
    }
return

;自动黑人功能
auto_black:
showMsg("AutoBlack On")
Loop {
    If (All_On && F_AutoBlack) {
        If (S_ChantodoBuff20) {
            Loop {
                If (S_IsDead) {
                    Goto, void
                }
                Else {
                    ;等待黑人技能CD
                    ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\archon.png
                    If (ErrorLevel > 0) {
                        ;首次
                        ImageSearch, FoundX, FoundY, %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\archon1.png
                    }
                    If (ErrorLevel = 0 || S_IsBlack) {
                        Break
                    }
                }
                Sleep, 20
            }
            Until (!All_On)

            If (!S_IsBlack) {
                Gosub, active_archon
                Sleep, 20000
            }
        }
        Else {
            ;空闲，等待下次监测
            Sleep, %P_AutoBlackInterval%
        }
    }
    Else {
        If (F_AutoBlack) {
            F_AutoBlack := 0
        }
        showMsg("AutoBlack Off")
        Break
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
        SetTimer, do_slowTime, %P_DelayOfSlowTime%
        SetTimer, do_wave, %P_AutoWaveInterval%
        S_AutoWave := 1
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

;角色血量监视器
health_monitor:
    If (isDead()) {
        ;角色死亡
        Gosub, when_player_dead
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

auto_protect_on:
If (F_AutoProtect) {
    SetTimer, do_armor, %P_AutoProtectInterval%
    SetTimer, do_magicWeapon, %P_AutoProtectInterval%
    S_IsDead := 0
    SetTimer, health_monitor, %P_HealthMonitorInterval%
    showMsg("AutoProtect On")
}
return

auto_protect_off: 
    Gosub, stop_protect
    SetTimer, health_monitor, Off
    S_IsDead := 0
    showMsg("AutoProtect Off")
return

;当角色死亡时，停止所有主动操作
when_player_dead:
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
S_IsBlack := 0
S_ChantodoBuff20 := 0
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
        If (F_AutoPick) {
            F_AutoPick := 0
        }
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


;============================
;【F7】暂停/继续
$F7::Pause

;============================
;【ALT+F7关闭本程序】
$!F7::ExitApp
