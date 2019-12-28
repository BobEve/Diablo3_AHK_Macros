;=========================================
; 魔法师32秒循环双黑人奥陨宏（单刷版）
; v1.7 20191210 for D3 v2.6.7
; Present by 是梦~` QQ:46317239
; 说明：
; 1、此宏适用于法师带冰戒单刷，或2~3人组队的中层打法，不适用4人组队的高层打法
; 2、只在奥元素时打一发黑人陨石
; 3、在电元素2秒左右向下滚轮打黑人陨石
; 4、黑人结束后，手动刷黄道
;=========================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
#MaxThreads, 3
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

global P_On := 1
global P_AutoFullCircle := 0

global S_Running := 0


WinGetPos, , , GameWidth, GameHeight, ahk_class D3 Main Window Class
creatMsgBlock()
setText("一发宏")
main()
return

;热键-----------------------------------------------
$F2::
    P_On := !P_On
    If (P_On) {
        main()
    }
    Else {
        If (S_Running) {
            stopRunning()
        }
        stop()
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

$XButton2::
    If (P_On) {
        lostArchon()
    }
return

$WheelDown::
    If (P_On) {
        doStarPact()
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
    Send, {%K_ArcaneDynamo% Down}
    sleepFrams(fnum)
    Send, {%K_ArcaneDynamo% Up}
}

doGuide(fnum) {
    Click, Down, Right
    sleepFrams(fnum)
    Click, Up, Right
}

doGuideMS(ms) {
    Click, Down, Right
    realSleep(ms)
    Click, Up, Right
}

doWaveOfForce(fnum) {
    Send, {%K_WaveOfForce%}
    sleepFrams(fnum)
}

doMeteor(fnum) {
    Send, {%K_Meteor%}
    sleepFrams(fnum)
}

doArchon() {
    Send, {%K_Archon%}
    Sleep, 50
    SetTimer, doArchonBlast, 800
    SetTimer, lostArchon, -19200
}

doArchonBlast() {
    Send, {1}
}

lostArchon() {
    SetTimer, doArchonBlast, Off
}

doStarPact() {
    doWaveOfForce(38)
    doArcaneDynamo(84)
    ;doArcaneDynamo(81) ;1350ms
    doMeteor(36)
    sleepFrams(3)
    doArcaneDynamo(36)
    ;doArcaneDynamo(33) ;550ms 2发
    sleepFrams(5)
    ;doGuide(3)
    doGuideMS(3)
    doArchon()
}
