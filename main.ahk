#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
; Set everything in the settings back to normal
stop := 0
transcoder := A_ScriptDir . "\processing\transcoder.exe"
config := A_ScriptDir . "\processing\config.txt"
if !FileExist(config)
{
  runwait, %ComSpec% /c cd processing && npm install,, hide
} else {
    FileDelete, %config%
}

; Start the gui making for a small control panel
gui, new
gui, add, Button, gFileselect vFilesel x2 y2 w80 h25, Select File
gui, Add, CheckBox, x2 y32 vCvbr,Use Constant Bitrate
gui, add, CheckBox, x2 y47 vH265,Use HEVC encoder
gui, Add, CheckBox, x2 y62 vGpu,Use GPU transcoding
Gui, add, Text, x145 y2, bitrate(kbps)
Gui, Add, Edit, x135 y17 w80 h20 Number
Gui, Add, UpDown, vKBPS 0x80 Range0-2147483647
Gui, add, Button, gSubmit x134 y47 w80 h30, Start conversion
gui, show,, AHK-Trans
return

Fileselect:
{   
    FileSelectFile, inpFile, 2
    GuiControl,, Filesel, File Selected!
    Inptfile = "%inpFile%"
    return
}

Submit:
{
    if !inpFile {
        msgbox, hey, you forgot to give me something to transcode :3
        return
    }
    runwait, %Comspec% /c wmic path win32_VideoController > .\processing\gpu.txt,, hide
    FileRead, gpu, %A_ScriptDir%\processing\gpu.txt
    FileDelete, %A_ScriptDir%\processing\gpu.txt
    If InStr(gpu, "GeForce") {
        FileAppend, true`n, %config%
    } else {
        FileAppend, false`n, %config%
    }
    Gui, Submit
    if (KBPS = "0") {
        FileAppend, empty`n, %config%
    } else {
        FileAppend, %KBPS%`n, %config%
    }
    if (Cvbr = 1) {
        FileAppend, true`n, %config%
    } else {
        FileAppend, false`n, %config%
    }
    FileAppend, %Gpu%`n, %config%
    FileAppend, %H265%`n, %config%
    gui, Destroy
    gui, outputlog:new, -0xC00000
    gui, outputlog:add, button, gClose x87 y5 w175 h25, Close window
    gui, outputlog:add, edit, r7 vDefaults +center ReadOnly x0 y35 w350
    gui, outputlog:add, edit, r1 vLOG +center ReadOnly x75 y135 w100
    gui, outputlog:add, edit, r1 vETR +center ReadOnly x176 y135 w100
    gui, outputlog:show, w350 h235,getstuff
    start := A_TickCount
    StdOutStream( "node.exe " A_ScriptDir "\processing\transcoder.js " Inptfile, "StdOutStream_Callback")
    return
}
guiClose:
{
    exitapp
}
Close:
{
    if (stop = "0") {
        run, %A_ScriptDir%\processing\tooltip.exe
        return
    } else {
        exitapp   
    }
}

StdOutStream( sCmd, Callback = "" ) { ; Modified  :  SKAN 31-Aug-2013 http://goo.gl/j8XJXY                             
  Static StrGet := "StrGet"           ; Thanks to :  HotKeyIt         http://goo.gl/IsH1zs                                   
                                      ; Original  :  Sean 20-Feb-2007 http://goo.gl/mxCdn
                                    
  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

  if(a_ptrSize=8){
    VarSetCapacity( STARTUPINFO, 104, 0  )      ; STARTUPINFO          ;  http://goo.gl/fZf24
    NumPut( 68,         STARTUPINFO,  0 )      ; cbSize
    NumPut( 0x100,      STARTUPINFO, 60 )      ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100 
    NumPut( hPipeWrite, STARTUPINFO, 88 )      ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 96 )      ; hStdError
    VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI      
  }else{
    VarSetCapacity( STARTUPINFO, 68, 0  )      ; STARTUPINFO          ;  http://goo.gl/fZf24
    NumPut( 68,         STARTUPINFO,  0 )      ; cbSize
    NumPut( 0x100,      STARTUPINFO, 44 )      ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100 
    NumPut( hPipeWrite, STARTUPINFO, 60 )      ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 64 )      ; hStdError
    VarSetCapacity( PROCESS_INFORMATION, 16 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI     
  }
  If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0 ;  http://goo.gl/USC5a
              , UInt,1, UInt,0x08000000, UInt,0, UInt,0
              , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION ) 
   Return "" 
   , DllCall( "CloseHandle", UInt,hPipeWrite ) 
   , DllCall( "CloseHandle", UInt,hPipeRead )
   , DllCall( "SetLastError", Int,-1 )     

  hProcess := NumGet( PROCESS_INFORMATION, 0 )                 
  if(a_is64bitOS)
    hThread  := NumGet( PROCESS_INFORMATION, 8 )                      
  else
    hThread  := NumGet( PROCESS_INFORMATION, 4 )                      
  DllCall( "CloseHandle", UInt,hPipeWrite )

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )                   ;  A_IsClassic 
  VarSetCapacity( Buffer, 4096, 0 ), nSz := 0 
  
  While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {

   tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) ) 
              ? Buffer : %StrGet%( &Buffer, nSz, "CP850" )

   Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput

  }                   
 
  DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
  DllCall( "CloseHandle",  UInt,hProcess  )
  DllCall( "CloseHandle",  UInt,hThread   )
  DllCall( "CloseHandle",  UInt,hPipeRead )
  DllCall( "SetLastError", UInt,ExitCode  )

Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput      
}

StdOutStream_Callback( data, n ) {
    Static D
    Static Defaults
    Static LOG
    Static ETS
    casing := SubStr(data, 1, 4)
    Switch casing
    {
        case "perc":
            stuffs := SubStr(data, 5, 16)
            GuiControl, outputlog:, LOG, %stuffs%
            return
        case "estr":
            stuffs := SubStr(data, 5, 5)
            GuiControl, outputlog:, ETR, %stuffs%
            return
        case "defs":
            stuffs := SubStr(data, 5)
            GuiControl, outputlog:, Defaults, %stuffs%
            return
        case "stop":
            global stop = 1
            return
  }
  ;ToolTip % D .= data

  if ! ( n ) {
    Return
  }
}