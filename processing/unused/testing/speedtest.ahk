#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
start1 := A_TickCount
runwait, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js "C:\Users\User\Desktop\coding\discordbot\commands\data\crab.mp4"
stop1 := A_TickCount
time1 := stop1 - start1
msgbox v2 took %time1% ms to render