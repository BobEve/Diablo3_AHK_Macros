#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
#MaxThreads, 10
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines, -1
#IfWinActive, ahk_class D3 Main Window Class

;按键设置
global K_Archon := 2
global K_WaveOfForce := 1
global K_ArcaneDynamo := 3
global K_Meteor := 4
global K_ForceMove := "W"


global MillisecondsPerFrame := (1000 / 60)
global Circle := 32000
global StartTime := 0
global CurrentTime := 0
global DisplayedTime := 0
global ElapsedTime := 0

global GameWidth := 
global GameHeight :=

global ShenMuPosX := 
global ShenMuPosY := 

global P_On := 1
global P_AutoFullCircle := 0
global P_WarnInTeamChat := 0

global S_Running := 0
global S_NeedRunShenMu := 0

global totalTimeSpent := 11984


WinGetPos, , , GameWidth, GameHeight, ahk_class D3 Main Window Class
creatMsgBlock()
main()
setText("双黑奥陨(就绪)")
return

;热键-----------------------------------------------
$F1::
    P_On := !P_On
    If (P_On) {
        setText("双黑奥陨(就绪)")
        main()
    }
    Else {
        If (S_Running) {
            stopRunning()
        }
        If (P_AutoFullCircle) {
            stopFullCircle()
            P_AutoFullCircle := 0
        }
        stop()
        setText("双黑奥陨(关闭)")
    }
return

$F2::
    If (!P_On) {
        P_WarnInTeamChat := !P_WarnInTeamChat
        setText(P_WarnInTeamChat ? "队伍提醒开启" : "队伍提醒关闭")
        Sleep, 1000
        setText("双黑奥陨(关闭)")
    }
return

$F3::
    If (S_Running) {
        stopRunning()
    }
    Loop, 30 {
        Click, Right
        Sleep, % MillisecondsPerFrame * 2
    }
return

~$WheelUp::
    If (P_On && !S_Running) {
        startRunning()
    }
return

~$LButton::
    If (P_On && S_Running) {
        stopRunning()
    }
return

;黑人起手，在奥元素0.5~2.5秒
$XButton1::
    If (P_On) {
        P_AutoFullCircle := !P_AutoFullCircle
        If (P_AutoFullCircle) {
            If (P_WarnInTeamChat) {
                sendChat("奥开宏")
            }
            startFromArchon()
            SetTimer, autoFullCircle, 10
        }
        Else {
            stopFullCircle()
            If (P_WarnInTeamChat) {
                sendChat("宏关闭")
                SetTimer, warnArchon, Off
                SetTimer, warnArchonCountDown6, Off
                SetTimer, warnLostArchon, Off
            }
        }
    }
return

;黑人陨石起手，在电元素1.5~3秒
;砸一发陨石后：重置时钟、开始自动循环
$XButton2::
    If (P_On && !P_AutoFullCircle) {
        If (S_Running) {
            stopRunning()
        }
        P_AutoFullCircle := 1
        If (P_WarnInTeamChat) {
            sendChat("电开宏")
        }
        startFromArchonMeteor()
        SetTimer, autoFullCircle, 10
    }
return

$MButton::
    If (P_On && P_AutoFullCircle) {
        lostArchon()
    }
return

~$LCtrl::
    If (P_On && P_AutoFullCircle) {
        markShenMu()
    }
return

$F7:: ExitApp

;入口-----------------------------------------------
main() {
    startClock()
    SetTimer, showTime, 50
}

stop() {
    stopClock()
    SetTimer, showTime, Off
    ShenMuPosX := 
    ShenMuPosY := 
    S_NeedRunShenMu := 0
}

;程序函数-----------------------------------------------
creatMsgBlock() {
    global timeView, textView, isMsgBlockCreated
    xPos := Floor(0.65 * GameWidth)
    yPos := Floor(0.01 * GameHeight)
    Gui, +AlwaysOnTop +Disabled -Caption -SysMenu +Owner +LastFound
    Gui, Color, 00B001
    Gui, Margin, 5, 5
    WinSet, TransColor, 00B001
    Gui, font, s18 c00B000 w600, 宋体
    Gui, Add, Text , x0 y0 w230 h24 +0x200 vtextView Right BackgroundTrans,  
    Gui, font, s21 c00B000 w400, Arial
    Gui, Add, Text , x230 y0 w50 h24 +0x200 vtimeView Center BackgroundTrans,  
    Gui, Show, NoActivate x%xPos% y%yPos% NA, ""
    isMsgBlockCreated := 1
}

destoryMsgBlock() {
    Gui, Destroy
    isMsgBlockCreated := 0
}

clearTime() {
    GuiControl, , timeView,
}

setTime(value) {
    GuiControl, , timeView, %value%
    SetTimer, clearTime, -1000
}

setText(value) {
    GuiControl, , textView, %value%
}

startClock() {
    StartTime := A_TickCount
    SetTimer, clock, 10
}

stopClock() {
    SetTimer, clock, Off
}

clock() {
    ;Critical
    ElapsedTime := A_TickCount - StartTime
    If (ElapsedTime >= Circle) {
        StartTime := A_TickCount
        ElapsedTime := 0
    }
    Else {
        ;CurrentTime := Floor(ElapsedTime / 1000)
        CurrentTime := Floor(Mod(A_TickCount - StartTime, Circle) / 1000)
    }
}

resetClock() {
    StartTime := A_TickCount
}

showTime() {
    if !WinActive("ahk_class D3 Main Window Class") {
        return
    }
    If (DisplayedTime != CurrentTime) {
        setTime(DisplayedTime := CurrentTime)
    }
}

;发送队伍聊天消息
sendChat(text) {
    Send, {Enter}
    Send, %text%
    Send, {Enter}
}

sleepFrams(fnum) {
    If (fnum > 0) {
        Sleep, % Floor(MillisecondsPerFrame * fnum)
    }
}

realSleep(duration) {
    If (duration > 0) {
        DllCall("Sleep", "UInt", duration)
    }
}


;技能函数-----------------------------------------------
startRunning(duration := 0) {
    Send, {%K_ForceMove% Down}
    S_Running := 1
    If (duration) {
        SetTimer, stopRunning, % 0 - duration
    }
}

stopRunning() {
    Send, {%K_ForceMove% Up}
    S_Running := 0
}

doArcaneDynamo(fnum) {
    If (P_AutoFullCircle) {
        Send, {%K_ArcaneDynamo% Down}
        sleepFrams(fnum)
        Send, {%K_ArcaneDynamo% Up}
    }
}

doGuide(fnum) {
    If (P_AutoFullCircle) {
        Click, Down, Right
        sleepFrams(fnum)
        Click, Up, Right
    }
}

doWaveOfForce(fnum) {
    If (P_AutoFullCircle) {
        Send, {%K_WaveOfForce%}
        sleepFrams(fnum)
    }
}

doMeteor(fnum) {
    If (P_AutoFullCircle) {
        Send, {%K_Meteor%}
        sleepFrams(fnum)
    }
}

doArchon() {
    If (P_AutoFullCircle) {
        Send, {%K_Archon%}
        Sleep, 50
        ;SetTimer, doArchonBlast, 800
        SetTimer, lostArchon, -19200
        setText("自动循环(黑人)")
        If (P_WarnInTeamChat) {
            SetTimer, warnArchon, -200
            SetTimer, warnArchonCountDown6, -13600
            SetTimer, warnLostArchon, -19600
        }
    }
}

doArchonBlast() {
    Send, {1}
}

lostArchon() {
    SetTimer, doArchonBlast, Off
}

warnArchon() {
    sendChat("法师黑人状态")
}

warnArchonCountDown6() {
    sendChat("黑人状态剩余6秒")
}

warnLostArchon() {
    sendChat("法师白人状态")
}

markShenMu() {
    MouseGetPos, ShenMuPosX, ShenMuPosY
    S_NeedRunShenMu := 1
}

runShenMu() {
    local r_time, currentX, currentY
    r_time := A_TickCount
    if (ShenMuPosX && ShenMuPosY) {
        MouseGetPos, currentX, currentY
        MouseMove, ShenMuPosX, ShenMuPosY, 0
        Send, {%K_ForceMove%}
        ;此处可以计算一下鼠标坐标偏移
        MouseMove, currentX, currentY
        ShenMuPosX := ShenMuPosY := 
        S_NeedRunShenMu := 0
    }
}

autoFullCircle() {
    local t := Floor(ElapsedTime / 10) * 10
    If (t >= 20090 && t <= 20110) {
        If (S_Running) {
            stopRunning() 
        }
        doFullCircleQueue()
    }
}

startFromArchon() {
    resetClock()
    doArchon()
    totalTimeSpent := 11984
}

startFromArchonMeteor() {
    doWaveOfForce(38)
    doArcaneDynamo(84)
    doMeteor(36)
    sleepFrams(2)
    doArcaneDynamo(36)
    sleepFrams(3)
    doGuide(6)
    resetClock()
    doArchon()
    totalTimeSpent := 11984
}

doFullCircleQueue() {
    ;Critical
    local adjustmentTime := 0
    local fullCircleStartTime := A_TickCount
    
    setText("自动循环(白人)")
    sleepFrams(6)
    ;刷黄道
    doWaveOfForce(38)
    doGuide(18)
    doWaveOfForce(38)
    doGuide(18)
    doWaveOfForce(38)
    doGuide(18)

    setText("自动循环(第一发)")
    If (P_WarnInTeamChat) {
        sendChat("第一发！")
    }
    doWaveOfForce(38)
    ;第1颗陨石
    doArcaneDynamo(84)
    doMeteor(36)
    doArcaneDynamo(36)
    doGuide(12)

    setText("自动循环(定位)")
    ;间隔
    doArcaneDynamo(55 - P_WarnInTeamChat)
    doGuide(18)
    doWaveOfForce(38)
    doGuide(18)

    setText("自动循环(第二发)")
    If (P_WarnInTeamChat) {
        sendChat("第二发！")
    }
    doWaveOfForce(38)
    ;第2颗陨石
    doArcaneDynamo(84)

    ;元素循环误差调节
    adjustmentTime := Ceil((11984 - totalTimeSpent) * 0.8)
    realSleep(adjustmentTime)

    If (S_NeedRunShenMu) {
        doMeteor(18)
        runShenMu()
        sleepFrams(60)
    }
    Else {
        doMeteor(36)
        sleepFrams(2)
        doArcaneDynamo(36)
        sleepFrams(3)
    }
    doGuide(6)
    totalTimeSpent := A_TickCount - fullCircleStartTime
    
    doArchon()
}

stopFullCircle() {
    SetTimer, autoFullCircle, Off
    lostArchon()
    setText("双黑奥陨(就绪)")
}
