#NoEnv
#Persistent
#SingleInstance, force
SetWorkingDir %A_ScriptDir%
FileRemoveDir, %A_ScriptDir%\..\processing, 1
mainver = v%1%
MsgBox, %mainver%
UrlDownloadToFile, https://github.com/MierenManz/transcoder/releases/download/%mainver%/installer.exe, %A_ScriptDir%\..\installer.exe
run, %A_ScriptDir%\..\installer.exe
exitapp