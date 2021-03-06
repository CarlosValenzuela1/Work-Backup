﻿#SingleInstance Force

SetBatchLines -1
SetWinDelay, -1

CircleMenuItems = 
(
Google
DckDckGo
Awesome
Script4
Script5
Script6
Ç[VxE]
)

MyColors = 
( C
   specific       ; a literal word, all colors are in BGR
   0xe5f442       ; edge color

   t0xFF00FF      ; unselected BG color
   0xe5f442       ; unselected text color
   0xe5f442       ; selected BG color
   0xFFFFFF       ; selected text color

   ;;If you want transparent put: t0xFF00FF
   0x000000       ; unselected BG color specific to menu item 0
   0x000000       ; unselected text color specific to menu item 0
   0xe5f442       ; selected BG color specific to menu item 0
   0xFFFFFF       ; selected text color specific to menu item 0
)

~LCtrl & RButton:: ; our hotkey to initiate this menu
SetTitleMatchMode 3
IfWinExist %A_ScriptName%
   return ; don't trigger this if our messagebox is up
SetTitleMatchMode, 1

;;;; Make a GUI for the Circle Menu
Gui, +LastFound +AlwaysOnTop -Caption
Gui, Color, FF00FF
WinSet, TransColor, FF00FF
hwndCircleMenu:=WinExist()

Gui, Show, Hide
WinMove, , , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%
WinSet, Redraw
Gui, Show
;;;;; We have an invisible GUI for our menu
Coordmode, mouse, screen

MouseGetPos, mx, my ; where do we want our menu to appear ?
MyMenuChoice = new ; not really necessary unless you are handling

MenuOptions =
( C
   r125       ; set the outer radius of the circle menu
   x%mx%      ; x coord
   y%my%      ; y coord
   c0.3       ; relative fraction of the center circle's radius. Must be (0 < c < 1)
   t0xFF00FF  ; the window's transparent color, specify this if your window
              ; uses a different transparent color than fuschia
)

SetTimer, PollForCMenuSelect, 1 ; begin polling for changes in menu selection !!!!
Hotkey, LButton Up, ReleaseCMenu, on ; Designate an event to end the menu !!!!
return

; We have to poll for the current hover selection because the terminal event could be anything
PollForCMenuSelect:
   If ( MyMenuChoice != OldMenuChoice)
   {
      tmo := MenuOptions " " MyMenuChoice

      CMData := CircleMenu( hwndCircleMenu, CircleMenuItems, tmo, MyColors)
      OldMenuChoice := MyMenuChoice
   }
   MyMenuChoice := CircleMenuWatcher( CMData, "mouse" )
return

ReleaseCMenu: ; end the menu and stop watching for changes
   SetTimer, PollForCMenuSelect, off
   Hotkey, %A_ThisHotkey%, off
   Gui, Destroy
   WinKill, AHK_ID %hwndCircleMenu%

    ; this is how to get the text of the selected item
   ; rather than the numerical index of it
   picked := SubStr(CMData, InStr(CMData, "_t")+2)

   If picked = Google
      Run option1.ahk
   If picked = DckDckGo
      Run option2.ahk
   If picked = Awesome
      Run option3.ahk
   If picked = Smart
      msgbox and currently available...
   If picked = Da Bomb
      msgbox the one and only !
   If picked = The Best
      msgbox with whom you do not wish to mess.
   If picked = Chill
      msgbox Yeah!
   If picked = [Z] is
      Gui, Destroy
return

CircleMenuWatcher( dstring, watchwhat = "" )
{ 
   Stringsplit, datas, dstring, _, xyncr
   ; x y number lower upper
   mychoice = 0
   If ( watchwhat = "" ) || (InStr(watchwhat, "m") = 1)
   {
      MouseGetPos, nmx, nmy
      wr := Floor(((w1 := datas2 - nmy)**2 + (w2 := nmx - datas1)**2)**0.5)
      rads := (w1=0) ? ((w2<0)*0.5+0.25) : (ATan(w2/w1)
          / (8*ATan(1))+(w1>0)*(w2<0)+(w1<0)/2)
      If InStr(watchwhat, " dis")
         return % wr + rads
      If (wr > datas5 || wr < datas5 - datas4)
         return 0 ; radially out of bounds of the circular menu
      mychoice := Ceil( (datas3 * rads + 0.5) )
      If mychoice > %datas3%
         mychoice = 1
   }
   return % mychoice
}

; Param1 is the hwnd of the window you want to draw on
; Param2 is the string of menu items
; Optional Params 3 and 4 are strings of options for size/color
; This function is responsible for drawing on the given window
CircleMenu( hWnd, MenuString, Options = "", ColorsBGR = "" )
{ ; Current is the currently selected menu item
vxe:=DllCall("GetDC", UInt, hwnd)
; SetDefaults and handle options string
Radius = 120
Current := 0
TransColor = 0xFF00FF
Loop, Parse, Options, %a_space%`,`n, `r`t
{
   If InStr( A_LoopField, "x") = 1
      StringTrimLeft, mox, A_LoopField, 1
   If InStr( A_LoopField, "y") = 1
      StringTrimLeft, moy, A_LoopField, 1
   If InStr( A_LoopField, "r") = 1
      StringTrimLeft, Radius, A_LoopField, 1
   If (1+A_LoopField)
      Current := Floor(A_LoopField)
   If InStr( A_LoopField, "c") = 1
      StringTrimLeft, CenterRelative, A_LoopField, 1
   If InStr( A_LoopField, "t") = 1
      StringMid, TransColor, A_LoopField, 2, 8
}
Loop, Parse, ColorsBGR, x, `r%A_Tab%%A_Space%`,
{
   Item := Floor((A_Index-7) / 4)
   If A_Index = 1
      StringMid, ColorDesignation, A_LoopField, 1, 4
   Else If ColorDesignation = spec
   {
      Indec := Mod(A_Index - 3, 4) + 1
      If Item < 0 ; still getting the basic info
         Default%A_Index% := "0x" SubStr(A_LoopField, 1, 6)
      Else
         Item%Item%Color%Indec% := "0x" SubStr(A_LoopField, 1, 6)
   }
}
If !(Current + 1 > 0)
   Current = 0
Color0 := Default2 ? Default2 : "0x808080" ; edges
Color1 := Default3 ? Default3 : "0xFFFFFF" ; background
Color2 := Default4 ? Default4 : "0xFF0000" ; text
Color3 := Default5 ? Default5 : "0xFFBBAA" ; selected background
Color4 := Default6 ? Default6 : "0x0000FF" ; selected text

Loop, Parse, menustring, `n
   If ( SubStr(A_LoopField, 1, 1) = "Ç" )
      CenterText := SubStr(A_LoopField, 2)
   else
      menustring .= (A_Index = 1 ? (Menustring := "") : "`n") A_LoopField

Stringreplace, MenuString, MenuString, `n, `n, UseErrorLevel
MenuItems := ErrorLevel + 1

;;;;;;;;;;;;;; Get or convert coordinates
If !(mox+moy)
{
   moy := A_ScreenHeight // 2
   mox := A_ScreenWidth
}

;BREAK THIS DOWN INTO MULTIPLES IF STATEMENTS
; mox := (mox - Radius - 30 < 0) ? Radius + 30 : ( (mox + Radius 
; + 30 > A_ScreenWidth) ? (A_ScreenWidth - Radius - 30) : mox)
; moy := (moy - Radius - 30 < 0) ? Radius + 30 : ( (moy + Radius 
; + 30 > A_ScreenHeight) ? (A_ScreenHeight - Radius - 30) : moy )
; bLeft := (bRight := mox + Radius) - Radius * 2
; bTop := (bBase := moy + Radius) - Radius * 2


; mox := (mox - Radius - 30 < 0) ? Radius + 30 
;       : ( (mox + Radius + 30 > A_ScreenWidth) ? (A_ScreenWidth - Radius - 30) 
;       : mox)

; MsgBox, Before %mox%


;This works but it's not drawn
; if(mox - Radius - 30 < 0){
;    mox := (Radius + 30)
; } else if(mox + Radius + 30 > A_ScreenWidth) {
;    mox := (A_ScreenWidth - Radius - 30)
; } 

; MsgBox, After %mox%

moy := (moy - Radius - 30 < 0) ? Radius + 30 : ( (moy + Radius 
+ 30 > A_ScreenHeight) ? (A_ScreenHeight - Radius - 30) : moy )

bLeft := (bRight := mox + Radius) - Radius * 2
bTop := (bBase := moy + Radius) - Radius * 2

;;;;;;;;;;;; Pre-loop things to establish
hCurrBrush := DllCall("CreateSolidBrush", UInt, TransColor)
DllCall("SelectObject", UInt,vxe, UInt, hCurrBrush)
DllCall("Rectangle",UInt,vxe,UInt,0,UInt,0,UInt,A_ScreenWidth,UInt,A_ScreenHeight)
ThisRx := Floor(Sin((MenuItems - 0.5) / MenuItems * 2 * 3.14159) * Radius) + mox
ThisRy := Floor(-Cos((MenuItems - 0.5) / MenuItems * 2 * 3.14159) * Radius) + moy
hCurrPen := DllCall("CreatePen", UInt, 0, UInt, 3, UInt, Color0)
DllCall("SelectObject", UInt,vxe, UInt, hCurrPen)
;;;;;;;;;;;; draw the circle menu
Loop, Parse, MenuString, `n ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
{
If (A_Index = Current)
{
   clbColor := (Item%A_Index%Color3) ? (Item%A_Index%Color3) : Color3
   cliColor := (Item%A_Index%Color4) ?(Item%A_Index%Color4) : Color4
   FFRString := A_LoopField
}
else
{
   clbColor := (Item%A_Index%Color1) ? (Item%A_Index%Color1) : Color1
   cliColor := (Item%A_Index%Color2) ?(Item%A_Index%Color2) : Color2
}
DllCall("DeleteObject", UInt, hCurrBrush)
hCurrBrush := DllCall("CreateSolidBrush", UInt, clbColor)
DllCall("SelectObject", UInt,vxe, UInt, hCurrBrush)
;;;;;;;;;;;; get positions for two radials and the estimated text position
PrevRx := ThisRx
PrevRy := ThisRy
ThisRx := Floor(Sin((a_index - 0.5) / MenuItems * 2 * 3.14159) * Radius) + mox
ThisRy := Floor(-Cos((a_index - 0.5) / MenuItems * 2 * 3.14159) * Radius) + moy
ThisTextRx := Floor(Sin((a_index - 1) / MenuItems * 2 * 3.14159) * Radius * 0.7) + mox - StrLen(a_LoopField) * 4
ThisTextRy := Floor(-Cos((a_index - 1) / MenuItems * 2 * 3.14159) * Radius * 0.7) + moy - 8
;;;;;;;;;;;; Do the actual drawing of the pie slices
DllCall("Pie",UInt,vxe,UInt,bLeft,UInt,bTop,UInt,bRight,UInt,0
+bBase,UInt,ThisRx,UInt,ThisRy,UInt,PrevRx,UInt,PrevRy)
mytext := a_LoopField
DllCall("SetTextColor", UInt, vxe, UInt, cliColor)
DllCall("SetBkColor", UInt, vxe, UInt, clbColor)
DllCall("TextOut", UInt, vxe, UInt, ThisTextRx, UInt, ThisTextRy, UInt, &mytext, UInt, StrLen(mytext))
} ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If Current > 0
{
   DllCall("SetTextColor", UInt, vxe, UInt, Item0Color2 ? Item0Color2 : Color2)
   DllCall("SetBkColor", UInt, vxe, UInt, Item0Color1 ? Item0Color1 : Color1)
   DllCall("DeleteObject", UInt, hCurrBrush)
   hCurrBrush := DllCall("CreateSolidBrush", UInt, Item0Color1 ? Item0Color1 : Color1)
   DllCall("SelectObject", UInt,vxe, UInt, hCurrBrush)
}
else
{
   DllCall("SetTextColor", UInt, vxe, UInt, Item0Color4 ? Item0Color4 : Color4)
   DllCall("SetBkColor", UInt, vxe, UInt, Item0Color3 ? Item0Color3 : Color3)
   DllCall("DeleteObject", UInt, hCurrBrush)
   hCurrBrush := DllCall("CreateSolidBrush", UInt, Item0Color3 ? Item0Color3 : Color3)
   DllCall("SelectObject", UInt,vxe, UInt, hCurrBrush)
   FFRString := CenterText
}
cnr := 1 - (CenterRelative ? CenterRelative : 0.3)
If cnr < 0
   cnr = (cnr - 1) * ( -1 / 100)
DllCall("Ellipse", UInt, vxe, UInt, Floor(bLeft+Radius*cnr), UInt, Floor(bTop
+Radius*cnr), UInt, Floor(bRight-Radius*cnr), UInt, Floor(bBase-Radius*cnr))
If (CenterText != "")
{
   StringReplace, CenterText, CenterText, ``s, %A_Space%, all
   DllCall("TextOut", UInt, vxe, UInt, mox - StrLen(CenterText) 
   * 3, UInt, moy-8, UInt, &CenterText, UInt, StrLen(CenterText))
}
DllCall("ReleaseDC", UInt, 0, UInt, vxe)  ; Release
DllCall("DeleteObject", UInt, hCurrBrush)
DllCall("DeleteObject", UInt, hCurrPen)
; MsgBox % "x" mox "_y" moy "_n" MenuItems "_c" Floor(Radius * cnr) "_r" Radius "_t" FFRString
return % "x" mox "_y" moy "_n" MenuItems "_c" Floor(Radius * cnr) "_r" Radius "_t" FFRString
}

return

~LCtrl & s::
send ^s
Reload
return

F10::MsgBox, %hwndCircleMenu%


;x1384_y603_n6_c87_r125_t[VxE]