#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Set everything in the settings back to normal
buttontext := "Select File"
config := A_ScriptDir . "\processing\config.ini"
IniWrite, true, %config%, main, CBR
IniWrite, empty, %config%, main, BITRATE
IniWrite, empty, %config%, main, OUTPUT
IniWrite, true, %config%, main, USE_h265
IniWrite, true, %config%, main, USE_GPU

; Start the gui making for a small control panel
gui, new
gui, add, Button, vFilesel gFileselect w80, %buttontext%
gui, Add, CheckBox, vCvbr, use CBR
gui, add, CheckBox, vH265, Use HEVC encoder
gui, Add, CheckBox, vGpu, Use GPU for transcoding
Gui, Add, Edit, vName w80 h20
Gui, add, Button, gSubmit w80, Start conversion
gui, show
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
    MsgBox, %Name%
    if (Cvbr = 1) {
        IniWrite, true, %config%, main, CBR
    } else {
        IniWrite, false, %config%, main, CBR
    }
    if (Gpu = 1) {
        IniWrite, true, %config%, main, USE_GPU
    } else {
        IniWrite, false, %config%, main, USE_GPU
    }
    if (H265 = 1) {
        IniWrite, true, %config%, main, USE_h265
    } else {
        IniWrite, false, %config%, main, USE_h265
    }
    runwait, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js %inpFile%
    exitapp
}

guiClose:
{
    exitapp
}