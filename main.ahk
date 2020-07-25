#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
; Set everything in the settings back to normal
stop := 0
config := A_ScriptDir . "\processing\config.ini"
IniWrite, true, %config%, main, CBR
IniWrite, empty, %config%, main, BITRATE
IniWrite, empty, %config%, main, OUTPUT
IniWrite, 1, %config%, main, USE_h265
IniWrite, 1, %config%, main, USE_GPU

; Start the gui making for a small control panel
gui, new
gui, add, Button, gFileselect vFilesel x2 y2 w80 h25, Select File
gui, Add, CheckBox, x2 y32 vCvbr,Use Constant Bitrate
gui, add, CheckBox, x2 y47 vH265,Use HEVC encoder
gui, Add, CheckBox, x2 y62 vGpu,Use GPU transcoding
Gui, add, Text, x145 y2, bitrate(kbps)
Gui, Add, Edit, x135 y17 w80 h20 Number
Gui, Add, UpDown, vKBPS 0x80 Range0-2147483647
Gui, add, Button, gSubmit x134 y47 w80 h30, Start conversion
gui, show,, AHK-Trans
return

Fileselect:
{   
    FileSelectFile, inpFile, 2
    GuiControl,, Filesel, File Selected!
    return
}

Submit:
{
    Gui, Submit
    if (KBPS = "0") {
        IniWrite, empty, %config%, main, BITRATE
    } else {
        msgbox %KBPS%
        IniWrite, %KBPS%, %config%, main, BITRATE
    }
    if (Cvbr = 1) {
        IniWrite, true, %config%, main, CBR
    } else {
        IniWrite, false, %config%, main, CBR
    }
    IniWrite, %Gpu%, %config%, main, USE_GPU
    IniWrite, %H265%, %config%, main, USE_h265
    gui, Destroy
    gui, outputlog:new, -0xC00000
    gui, outputlog:add, button, gClose x87 y5 w175 h25, Close window
    gui, outputlog:add, edit, r8 vDefaults ReadOnly x0 y35 w350
    gui, outputlog:add, edit, r1 vLOG ReadOnly x0 y146 w100
    gui, outputlog:add, edit, r10 vETR ReadOnly x100 y146 w100
    gui, outputlog:add, edit, r1 vETA ReadOnly x200 y146 w100
    gui, outputlog:show, w350 h535
    start := A_TickCount
    run, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js %inpFile%,,Hide
    return
}

guiClose:
{
    exitapp
}
Close:
{
    if (stop = "0") {
        msgbox, Sorry but the render is not finished yet!
        return
    } else {
        exitapp   
    }
}

f14::
{
    stop := 1
    return
}
f15::
{
    FileRead, fc, %A_ScriptDir%\processing\log.txt
    GuiControl, outputlog:, Defaults, %fc%
    return
}

f16::
{
    FileRead, fc, %A_ScriptDir%\processing\log.txt
    GuiControl, outputlog:, LOG, %fc%
    ;GuiControl, outputlog:, ETA, %eta%
    return
}
f13::
{
    FileRead, etr, %A_ScriptDir%\processing\etr.txt
    GuiControl, outputlog:, ETR, %etr%
    return
}