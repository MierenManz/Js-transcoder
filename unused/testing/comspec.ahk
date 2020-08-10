#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
runwait, %ComSpec% /c cd processing && npm install,, hide