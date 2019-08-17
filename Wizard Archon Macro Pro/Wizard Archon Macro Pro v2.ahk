;=========================================
; 暗黑III魔法师维尔御法者AHK宏
; Pro Edition v2.22 20190818
; Present by 是梦~` QQ:46317239
;=========================================
#NoEnv
;#Warn, All, StdOut
SetWorkingDir %A_ScriptDir%
SendMode Input
CoordMode, Pixel, Window
#SingleInstance Force
#MaxThreads 20
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
global K_WizardArchon := 2                 ;御法者技能按键，默认2键
global K_WizardArmor := 1                  ;护甲技能，默认1键
global K_WizardMagicWeapon := 4            ;魔法武器，默认4键

;定标
;/////////////////////////////////////////////////////////
;1234技能栏范围（适配1920*1080宽屏）
global P_SkillArea_X1 := 627
global P_SkillArea_Y1 := 997
global P_SkillArea_X2 := 891
global P_SkillArea_Y2 := 1060

;可自定义的参数
;/////////////////////////////////////////////////////////
P_MsgBoxTimeOut := 0.8       ;提示框超时的时间，单位秒，默认0.8秒
P_LAttackInterval := 30      ;左键攻击间隔，默认30毫秒，范围20~50
P_AutoMoveInterval := 50     ;自动移动/拾取间隔，默认50毫秒
P_AutoBuyInterval := 50      ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30      ;自动购买次数，默认30次
P_AutoBlastInterval := 320   ;御法者元素爆术施放间隔，默认320毫秒
P_DelayOfSlowTime := -600    ;激活御法者后施放时间延缓技能的延迟，默认600毫秒
;----------------------------
P_AutoProtectInterval := 400        ;自动施放保护技能探测间隔，默认400毫秒
P_AutoArchonInterval := 100         ;自动御法者探测间隔，默认100毫秒，范围50-200
P_HealthMonitorInterval := 200      ;血量探测间隔，默认200毫秒

;标志、状态变量（不可修改）
;/////////////////////////////////////////////////////////
All_On := 0                 ;总开关
;开关------------------------
F_AutoMove := 0             ;自动移动/拾取开关
F_AutoProtect := 1          ;自动施放保护技能（护甲、魔法武器）
F_AutoArchon := 0           ;自动御法者开关
F_HealthMonitoring := 1     ;血量监测，低于40%喝药水，死亡清理
;状态------------------------
S_RAttack := 0              ;右键自动攻击状态
S_AutoClick := 0            ;左键连点状态
S_AutoBlast := 0            ;御法者形态时，自动施放元素爆术（1技能）技能的状态
S_IsArchon := 0             ;御法者形态 0：白人，1：黑人
S_ChantodoBuff20 := 0       ;迦陀朵buff状态 0：非20层，1：20层
S_IsDead := 0               ;角色死亡状态 0：存活，1：死亡
S_CleanedUp := 0            ;角色死亡后清理状态 0：未清理，1：已清理

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
Gui Add, GroupBox, x10 y10 w510 h50, 键位设置
Gui Font
Gui Font, Bold cBlue
Gui Add, Text, x25 y26 w480 h23 +0x200, 1：护甲、2：御法者、[3：传送]、4：魔法武器、左：黑洞、右：奥术洪流 
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w510 h275, 热键设置
Gui Font
Gui Add, Text, x20 y90 w490 h20 +0x200, ·F1：开启/关闭宏功能（默认关闭，开启后保持护甲、魔法武器，血量低于40`%自动喝药水）
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F2：暂停/继续宏功能；·F7：退出脚本
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F3：自动购买[30]次装备（鼠标指针放到要购买的装备上）
Gui Add, Text, x20 y165 w480 h20 +0x200, ·F4：开启自动御法者功能（默认关闭，迦陀朵buff20层自动激活御法者、施放元素爆术）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·F5：关闭自动御法者功能
Gui Add, Text, x20 y215 w480 h20 +0x200, ·上滚轮：强制站立（按下Shift键），并开始持续左键技能攻击
Gui Add, Text, x20 y240 w480 h20 +0x200, ·下滚轮：开始持续右键技能攻击
Gui Add, Text, x20 y265 w480 h20 +0x200, ·右键：停止右键技能攻击
Gui Add, Text, x20 y290 w480 h20 +0x200, ·前进（侧）/中键：御法者形态时，强制停止正在自动施放的元素爆术
Gui Add, Text, x20 y315 w480 h20 +0x200, ·后退（侧）/[``]键：点击后开始移动/拾取（需要鼠标配合移动），再次点击停止
Gui Font, Bold cRed
Gui Add, Text, x15 y350 w480 h20 +0x200, 注意：仅适配1920x1080(16:9宽屏)！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w530 h375, 暗黑III魔法师维尔御法者AHK宏加强版v2.22（是梦~`` QQ:46317239）
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


;游戏检查函数
;/////////////////////////////////////////////////////////
;检查角色是否死亡
;返回值：True 死亡、False 存活
isDead() {
    PixelGetColor, lifebar_color1, 32, 123, RGB
    PixelGetColor, lifebar_color2, 32, 127, RGB
    return (lifebar_color1 = 0x000000 && lifebar_color2 = 0x000000) ? True : False
}

;检查角色血量是否小于指定的百分比
;默认0.4(40%)
;返回值：True 小于、False 不小于
healthLess(percent = 0.4) {
    PixelGetColor, lifebar_color1, % 32 + Floor(60 * percent), 123, RGB
    PixelGetColor, lifebar_color2, % 32 + Floor(60 * percent), 127, RGB
    PixelGetColor, lifebar_color3, 32, 125, RGB
    return (lifebar_color1 = 0x000000 && lifebar_color2 = 0x000000 && lifebar_color3 = 0x940000) ? True : False
}

;检查药水技能是否处于冷却状态
;返回值：True 冷却中、False 可用
isPotionCooling() {
    PixelGetColor, potion_color1, 1062, 1004, RGB
    PixelGetColor, potion_color2, 1062, 1007, RGB
    return (potion_color1 = 0x151617 && potion_color2 = 0x1D1E1F) ? False : True
}

;检查护甲是否超时
isArmorTimeout() {
    ;暴风护甲
    ImageSearch, armorX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\strom_armor.png
    If (!armorX) {
        ImageSearch, armorX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\strom_armor1.png
        If (!armorX) {
            ;能量护甲
            ImageSearch, armorX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\energy_armor.png
            If (!armorX) {
                ImageSearch, armorX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\energy_armor1.png
            }
        }
    }
    return armorX ? True : False
}

;检查魔法武器是否超时
isMagicWeaponTimeout() {
    ImageSearch, magicWeaponX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\magic_weapon.png
    If (!magicWeaponX) {
        ImageSearch, magicWeaponX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\magic_weapon1.png
    }
    return magicWeaponX ? True : False
}

;检查迦陀朵Buff是否已叠加到20层
isChantodoBuff20() {
    ;两个buff的范围
    ImageSearch, chantodoX, , 663, 908, 766, 958, %A_ScriptDir%\chantodo.png
    If (!chantodoX) {
        ;buff位于第2顺位
        ImageSearch, chantodoX, , 663, 908, 766, 958, %A_ScriptDir%\chantodo1.png
    }
    return chantodoX ? True : False
}

;检查角色是否御法者形态
isArchon() {
    ImageSearch, skill4X, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\skill4.png
    return skill4X ? True : False
}

;检查御法者技能是否处于冷却状态
isArchonCooling() {
    ImageSearch, archonX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\archon.png
    If (!archonX) {
        ;首次
        ImageSearch, archonX, , %P_SkillArea_X1%, %P_SkillArea_Y1%, %P_SkillArea_X2%, %P_SkillArea_Y2%, %A_ScriptDir%\archon1.png
    }
    return !archonX ? True : False
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

;药水
doPotion() {
    Send, {q}
}

;护甲
doArmor() {
    global S_IsArchon
    If (!S_IsArchon && isArmorTimeout()) {
        Send, {%K_WizardArmor%}
    }
}

;魔法武器
doMagicWeapon() {
    global S_IsArchon
    If (!S_IsArchon && isMagicWeaponTimeout()) {
        Send, {%K_WizardMagicWeapon%}
    }
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
    local loop_count := 0
    doArchon()
    Loop {
        S_IsArchon := isArchon() ? 1 : 0
        If (S_IsArchon) {
            autoFunction("lostArchon", P_AutoBlastInterval - 20000)
            S_ChantodoBuff20 := 0
            Break
        }
        loop_count++
        If (loop_count > 5) {
            ;已施放御法者技能，但游戏中未成功变身
            ;无限重试
            doArchon()
            loop_count := 0
        }
        Sleep, 20
    }
    Until (!All_On || S_IsDead)
}

;监测迦陀朵Buff，20层激活御法者
autoArchon() {
    global
    If (!S_IsDead && !S_IsArchon && !S_ChantodoBuff20) {
        S_ChantodoBuff20 := isChantodoBuff20() ? 1 : 0
        If (S_ChantodoBuff20) {
            Loop {
                ;黑人技能CD完成，或已经手动变身
                If (S_IsArchon || !isArchonCooling()) {
                    Break
                }
                Sleep, 20
            }
            Until (!F_AutoArchon || S_IsDead)

            If (F_AutoArchon && !S_IsDead && !S_IsBlack ) {
                SetTimer, ActiveArchon, -1
                ;在关闭自动黑人功能或角色死亡时中断黑人20秒等待
                Loop, 100 {
                    Sleep, 200
                }
                Until (!F_AutoArchon || S_IsDead)
            }
        }
    }
}

;角色死亡
characterDies() {
    global
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    If (S_RAttack) {
        stopRAttack()
    }
    If (S_IsArchon) {
        autoFunction("lostArchon", -1)
    }
    S_ChantodoBuff20 := 0
}

;角色血量监视
healthMonitor() {
    global
    S_IsDead := isDead() ? 1 : 0
    If (S_IsDead) {
        If (!S_CleanedUp) {
            ;角色死亡后，进行清理
            characterDies()
            S_CleanedUp := 1
        }
    }
    Else {
        ;血量小于40%，喝药水
        If (healthLess() && !isPotionCooling()) {
            doPotion()
        }
        S_CleanedUp := 0
    }
}


;功能标签
;/////////////////////////////////////////////////////////
;什么都不做，用于强制跳出循环
void:
return

;开启自动御法者
AutoArchonOn:
    F_AutoArchon := 1
    S_IsArchon := 0
    S_ChantodoBuff20 := 0
    autoFunction("autoArchon", P_AutoArchonInterval)
    showMsg("AutoArchon On")
return

;关闭自动御法者
AutoArchonOff:
    F_AutoArchon := 0
    stopAutoFunction("autoArchon")
    S_IsArchon := 0
    S_ChantodoBuff20 := 0
    showMsg("AutoArchon Off")
return

;在启动宏功能时执行
OnStart:
    If (F_AutoProtect) {
        If (K_WizardArmor Is Integer) {
            autoFunction("doArmor", P_AutoProtectInterval)
        }
        If (K_WizardMagicWeapon Is Integer) {
            autoFunction("doMagicWeapon", P_AutoProtectInterval)
        }
    }
    If (F_HealthMonitoring) {
        S_IsDead := 0
        autoFunction("healthMonitor", P_HealthMonitorInterval)
    }
return

;在停止宏功能时执行
OnStop: 
    If (F_AutoArchon) {
        Gosub, AutoArchonOff
    }
    If (F_AutoProtect) {
        If (K_WizardArmor Is Integer) {
            stopAutoFunction("doArmor")
        }
        If (K_WizardMagicWeapon Is Integer) {
            stopAutoFunction("doMagicWeapon")
        }
    }
    If (F_HealthMonitoring) {
        stopAutoFunction("healthMonitor")
        S_IsDead := 0
    }
return


;热键&宏
;/////////////////////////////////////////////////////////
;*****************************
;热键：【F1】
;功能：开启或关闭宏功能
;*****************************
$F1::
All_On := !All_On
If (All_On) {
    Gosub, OnStart
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
    Gosub, OnStop
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
;热键：【F4】
;功能：开启自动御法者
;*****************************
$F4::
If (All_On && !F_AutoArchon) {
    Goto, AutoArchonOn
}
return

;*****************************
;热键：【F5】
;功能：关闭自动御法者
;*****************************
$F5::
If (All_On && F_AutoArchon) {
    Goto, AutoArchonOff
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
    If (S_IsArchon) {
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
