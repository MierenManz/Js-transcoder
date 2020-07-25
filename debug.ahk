#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
debug := A_ScriptDir . "\processing\debug.txt"
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
; Start the gui making for a small control panel
gui, new, -0xC00000
gui, add, button, gClose x0 y0 w80 h30, Close window
gui, add, Button, gFileselect vFilesel x0 y30 w80 h27, Select File
gui, show, w80 h57
return

Fileselect:
{   
    FileSelectFile, inpFile, 2
    Gui, Submit
    FileDelete, %debug%
    runwait, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js %inpFile% > processing\debug.txt
    gui, Destroy
    FileRead, Ledebug, %debug%
    gui, new, -0xC00000
    gui, add, button, gClose x70 y5 w140 h25, Close window
    gui, add, edit, vcontents ReadOnly x0 y35 w280 h500, %Ledebug%
    gui, show, w280 h535
    return
}

Close:
{
    exitapp
}