#SingleInstance Force
#NoEnv

#Persistent

;Gui Add, Text, , Receiver
Gui Show, ,getstuff

OnMessage(5000, "etr")
OnMessage(5001, "logging")
OnMessage(5002, "defaults")
OnMessage(5003, "stop")
Return

etr()
{
    msgbox etr
	FileRead, etr, %A_ScriptDir%\processing\etr.txt
    GuiControl, outputlog:, ETR, %etr%
    return
}
logging()
{
    msgbox logging
    FileRead, fc, %A_ScriptDir%\processing\log.txt
    GuiControl, outputlog:, LOG, %fc%
    return
}
defaults()
{
    msgbox defaults
    FileRead, fc, %A_ScriptDir%\processing\log.txt
    GuiControl, outputlog:, Defaults, %fc%
    return
}
stop()
{
    msgbox stop
    stop := 1
    return
}