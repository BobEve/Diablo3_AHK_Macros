;暗黑3魔法师32秒双黑散奥宏(是梦~`优化版 V2.1 20190913)
#NoEnv
; #Warn  ; Enable warnings to assist with detecting common errors.
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

;使用要求
;攻速 1.54（萃取黄道，不带勾玉），CDR 54.83以上（至少4条8CDR词缀）
;技能设置
;1 原力波、2 黑人、3 黑洞/护甲、4 陨石、左 电刑、右 冰霜射线

; 1 表示使用原始的技能序列
OriginalSeq := 0
; 第2颗陨石后跑圈开关，0表示不跑
PaoTrigger := 1
; 元素戒周期
CoeCircle := 32000
; 脚本运行间隔，默认10毫秒
Interval := 10

;【F1键】总开关
Hotkey, $F1, ToggleOff
Hotkey, $F2, TogglePao
;【鼠标侧键前进键】手动对齐元素戒，0秒应该在奥元素内
Hotkey, $XButton2, MatchCoe
;【鼠标侧键后退键】自动模式开关
Hotkey, $XButton1, ToggleAuto
;【空格】记录鼠标当前位置坐标（标记神目圈）
Hotkey, ~$Space, MarkShenMu


DianxingKey := "LButton" ;电刑按键
YindaoKey := "RButton" ;引导按键
YuanliboKey := 1 ;原力波按键
HeirenKey := 2 ;黑人按键
HeidongKey := 3 ;黑洞/护甲
YunshiKey := 4 ;陨石按键
;【W键】强制移动、走位
YidongKey := "W" ;强制移动按键，强制移动期间不会发技能（除了黑人）
ZhanliKey := "Shift" ;强制站立键，只会在用左键是使用


Init()
return

InitWizProfile() {
  global
  StopAll()
  SkillTypes := { SendKey : 0, CallFunc : 1 }
  Skills := []
  Skills.push( new CoeDisplay() )

  ; 0秒变身
  SKills.push( new Skill(HeirenKey, 0, 500, false) )
  ; 黑人期间打1维持勾玉
  SKills.push( new Skill(1, 500, 19000, false, SkillTypes.SendKey, false) )

  if (OriginalSeq) {
    ; 原始的技能序列（总是自动跑圈）
    ; 第一发陨石
    SKills.push( new Skill(YindaoKey, 20100, 300) )
    SKills.push( new Skill(YuanliboKey, 20400, 630) )
    SKills.push( new Skill(YindaoKey, 21200, 300) )
    SKills.push( new Skill(YuanliboKey, 21550, 630) )
    SKills.push( new Skill(YindaoKey, 22200, 300) )
    SKills.push( new Skill(YuanliboKey, 22200, 630) )
    SKills.push( new Skill(YindaoKey, 22850, 300) )
    SKills.push( new Skill(YuanliboKey, 23250, 630) )
    SKills.push( new Skill(DianxingKey, 23900, 400) )
    SKills.push( new Skill(YunshiKey, 24760, 200) )
    SKills.push( new Skill(DianxingKey, 25310, 500) )
    SKills.push( new Skill(YindaoKey, 25860, 400) )
    ; 第一发陨石结束到第二发陨石间歇时间
    SKills.push( new Skill(DianxingKey, 26550, 1000) ) 
    SKills.push( new Skill(YuanliboKey, 27550, 630) )
    SKills.push( new Skill(YindaoKey, 28200, 300) )
    SKills.push( new Skill(YuanliboKey, 28500, 630) )
    SKills.push( new Skill(DianxingKey, 29130, 1300) ) 
    ; 重要！第二发陨石的发起时间
    SKills.push( new Skill(YunshiKey, 30700, 200) )
    SKills.push( new Skill("PaoShenMu", 30970, 100, true, SkillTypes.CallFunc) )
    SKills.push( new Skill(YindaoKey, 31850, 100) )
  }
  else {
    ; 优化的技能序列（支持开关自动跑圈）
    ; 第一发陨石
    SKills.push( new Skill(YindaoKey, 20100, 300) )
    SKills.push( new Skill(YuanliboKey, 20400, 100) ) ;后摇700
    SKills.push( new Skill(YindaoKey, 21100, 300) )
    SKills.push( new Skill(YuanliboKey, 21400, 100) ) ;后摇700
    SKills.push( new Skill(YindaoKey, 22100, 300) )
    SKills.push( new Skill(YuanliboKey, 22400, 100) ) ;后摇700
    SKills.push( new Skill(DianxingKey, 23100, 1400) )
    SKills.push( new Skill(YunshiKey, 24500, 100) ) ;后摇600
    SKills.push( new Skill(DianxingKey, 25100, 500) )
    SKills.push( new Skill(YindaoKey, 25600, 600) )
    ; 第一发陨石结束到第二发陨石间歇时间
    SKills.push( new Skill(DianxingKey, 26200, 1400) ) 
    SKills.push( new Skill(YuanliboKey, 27600, 100) ) ;后摇700
    SKills.push( new Skill(YindaoKey, 28300, 300) )
    SKills.push( new Skill(YuanliboKey, 28600, 100) ) ;后摇700
    SKills.push( new Skill(DianxingKey, 29300, 1400) ) 
    ; 重要！第二发陨石的发起时间
    SKills.push( new Skill(YunshiKey, 30700, 100) ) ;后摇600
    if (PaoTrigger) {
      Skills.push( new Skill("PaoShenMu", 30970, 100, true, SkillTypes.CallFunc) )
    }
    else {
      Skills.push( new Skill(DianxingKey, 31300, 550) )
    }
    SKills.push( new Skill(YindaoKey, 31850, 100) )
  }
  
  return
}

Init() {
  global

  OFF := false
  InAuto := false
  ;RButtonDown := false
  MoveDown := false
  CurrentTime := 0
  CoeStartTime := 0
  Skills := []
  
  ShenMuPosX := ShenMuPosY :=

  WinGetPos, , , Width, Height, ahk_class D3 Main Window Class
  InfoTextX := Floor(0.4 * Width)
  InfoTextY := Floor(0.2 * Height)
  ResetX := Floor(0.504 * Width)
  ResetY := Floor(0.679 * Height)

  InitWizProfile()
  ShowInfo("暗黑III魔法师32秒双黑散奥宏`r`n【是梦~``优化版 V2.1】", 3000)
  SetTimer, MainRun, %Interval%
}

; type: 0 击键、1 函数
class Skill {
  KeyOrFunc := 
  Start := 0
  End := 0
  Started := false
  StopOnMove := true
  Type := 0
  KeepDown := true

  __New(pKeyOrFunc, pStart, pTime, pStopOnMove := true, pType := 0, pKeepDown := true) {
    this.KeyOrFunc := pKeyOrFunc
    this.Start := pStart
    this.End := pStart + pTime
    this.StopOnMove := pStopOnMove
    this.Type := pType
    this.KeepDown := pKeepDown
  }
  
  Hit() {
    shouldRun := this.CheckStatus()
    if (shouldRun) {
      if (this.Type = 0 && !this.KeepDown) {
        key := this.KeyOrFunc
        Send, {%key%}
        return
      }
      if (!this.Started) {
        this.StartSkill()
      }
    }
    else {
      if (this.Started) {
        this.EndSkill()
      }
    }
  }
    
  ShouldRun() {
    global
    return !OFF && InAuto
  }

  CheckStatus() {
    global MoveDown, CurrentTime
    if (!this.ShouldRun()) {
      return false
    }
    if (this.StopOnMove && MoveDown) {
      return false
    }
    time := CurrentTime
    if (time < this.Start || time > this.End) {
      return false
    }
    return true
  }
  
  StartSkill() {
    global ZhanliKey
	  this.Started := true
    if (this.Type = 0) {
      key := this.KeyOrFunc
      if (key = "LButton") {
        Send, {%ZhanliKey% Down}
      }
      Send, {%key% Down}
    }
    else if (this.Type = 1) {
      func := this.KeyOrFunc
      if (IsFunc(func)) {
        %func%()
      }
    }
  }
  
  EndSkill() {
    global ZhanliKey
	  this.Started := false
    if (this.Type = 0) {
      key := this.KeyOrFunc
      if (key = "LButton") {
        Send, {%ZhanliKey% Up}
      }
      Send, {%key% Up}
    }
  }
}

class CrazyClick {
  TriggerKey := 
  SendKey := 

  __New(pTriggerKey, pSendKey) {
    this.TriggerKey := pTriggerKey
    this.SendKey := pSendKey
  }
  
  Hit() {
    global OFF
    if (OFF) {
      return
    }
    if GetKeyState(this.TriggerKey, "P") {
	    key := this.SendKey
      Send, {%key%}
    }
  }
}

class CoeDisplay {
  time := 0

  Hit() {
    global CurrentTime
    if (OFF) {
      return
    }
    time := Floor(CurrentTime / 1000)
    if (this.time != time) {
      ShowInfo(time)
      this.time := time
    }
  }
}


MainRun: 
  if (OFF) {
    return
  }
  if !WinActive("ahk_class D3 Main Window Class") {
    return
  }

  CurrentTime := Mod(A_TickCount - CoeStartTime, CoeCircle)
  ;RButtonDown := GetKeyState("RButton", "P")
  MoveDown := GetKeyState(YidongKey, "P")
  For index, skill in Skills {
    skill.Hit()
  }
return

StopAll() {
  For index, skill in Skills {
    skill.EndSkill()
  }
}

ToggleOff:
  OFF := !OFF
  InAuto := false
  if (OFF) {
    StopAll()
    ShowInfo("宏 关闭")
  } 
  else {
    ShowInfo("宏 开启")
  }
return

ToggleAuto:
  InAuto := !InAuto
  if (InAuto) {
    ShowInfo("自动模式 开启")
  } 
  else {
    ShowInfo("自动模式 关闭")
  }
return

MatchCoe:
  CoeStartTime := A_TickCount
  ShowInfo("CoE已校准")
  Sleep, 600
return

ClearInfo() {
	global
  if (InfoTime < A_TickCount - 1000) {
	  GuiControl, , InfoText,
  }
  return
}

ShowInfo(text, timeout := 400) {
  global
  InfoTime := A_TickCount
  if WinExist("ahk_class AutoHotkeyGUI") {
    GuiControl, , InfoText, %text%
    return
  }
  CustomColor = 000000
  ;Placeholder := "         "
  Gui +LastFound +E0x0000008 -Caption +E0x8000000 +E0x00080000 +Disabled
  Gui, Color, %CustomColor%
  ;Gui, Font, s48
  Gui, Font, s40, 黑体, w100
  Gui, Font, s40, Arial, w400
  ;Gui, Add, Text, vInfoText cLime Center , %Placeholder%%text%%Placeholder%
  Gui, Add, Text, w800 vInfoText cLime Center , %text%
  WinSet, TransColor, %CustomColor% 150
  Gui, Show, xCenter y%InfoTextY%
  SetTimer, ClearInfo, %timeout%
  return
}

; 开关自动跑神目功能
TogglePao:
  PaoTrigger := !PaoTrigger
  if (!OFF) {
    SetTimer, MainRun, off
    ShowInfo(PaoTrigger ? "自动跑神目 开启" : "自动跑神目 关闭")
    Sleep, 600
    InitWizProfile()
    SetTimer, MainRun, %Interval%
  }
  else {
    ShowInfo(PaoTrigger ? "自动跑神目 开启" : "自动跑神目 关闭")
    Sleep, 600
  }
return

MarkShenMu:
  MouseGetPos, ShenMuPosX, ShenMuPosY
return

PaoShenMu() {
  global
  local currentX, currentY
  if (ShenMuPosX && ShenMuPosY) {
    MouseGetPos, currentX, currentY
    MouseMove, ShenMuPosX, ShenMuPosY, 0
    Send, {%YidongKey%}
    Sleep, 10
    ;此处可以计算一下鼠标坐标偏移
    MouseMove, currentX, currentY
    ShenMuPosX := ShenMuPosY := 
  }
}
