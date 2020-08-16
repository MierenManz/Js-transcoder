#NoEnv
#Persistent
#SingleInstance, force
SetWorkingDir %A_ScriptDir%
FileRemoveDir, %A_ScriptDir%\..\processing, 1
mainver = %1%
updatever = %2%
patchver = %3%
version := "v" . mainver . "." . updatever . "." . patchver
MsgBox, %version%
UrlDownloadToFile, https://github.com/MierenManz/transcoder/releases/download/%version%/installer.exe, %A_ScriptDir%\..\installer.exe
run, %A_ScriptDir%\..\installer.exe
exitapp