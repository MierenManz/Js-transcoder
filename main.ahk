#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
gui, new
gui, Add, CheckBox, vCvbr, use CBR
gui, Add, CheckBox, vGpu, Use gpu
gui, add, CheckBox, vH265, Use HEVC encoder
Gui, add, Button, gSubmitw80, Start conversion
gui, show
return

Submit:
{
    
}