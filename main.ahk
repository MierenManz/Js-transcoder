#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
; Set everything in the settings back to normal

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
Gui, Add, Edit, x135 y17 w80 h20
Gui, Add, UpDown, vKBPS 0x80
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
        IniWrite, %KBPS%, %config%, main, BITRATE
    }
    if (Cvbr = 1) {
        IniWrite, true, %config%, main, CBR
    } else {
        IniWrite, false, %config%, main, CBR
    }
    IniWrite, %Gpu%, %config%, main, USE_GPU
    IniWrite, %H265%, %config%, main, USE_h265
    runwait, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js %inpFile%
    exitapp
}

guiClose:
{
    exitapp
}