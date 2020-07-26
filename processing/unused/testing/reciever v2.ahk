new talk("")
    stop := 0
    etr := ""
    logs := ""
    def := ""
    gui, outputlog:new, -0xC00000
    gui, outputlog:add, button, gClose x87 y5 w175 h25, Close window
    gui, outputlog:add, edit, r8 vDefaults ReadOnly x0 y35 w350
    gui, outputlog:add, edit, r1 vLOG ReadOnly x0 y146 w100
    gui, outputlog:add, edit, r10 vETR ReadOnly x100 y146 w100
    gui, outputlog:add, edit, r1 vETA ReadOnly x200 y146 w100
    gui, outputlog:show, w350 h535,getstuff
   ; run, %ComSpec% /c node %A_ScriptDir%\processing\transcoder.js %inpFile%,,Hide
    #include %A_ScriptDir%\processing\lib\talk.ahk
    return

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

etr:
{   
    GuiControl, outputlog:, ETR, %etr%
    return
}

logging:
{
    GuiControl, outputlog:, LOG, %logs%
    return
}

def:
{
    GuiControl, outputlog:, Defaults, %def%
    return
}

stop:
{
    stop := 1
    return
}
