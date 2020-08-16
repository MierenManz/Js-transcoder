#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, force
Menu, Tray, Icon , %A_ScriptDir%\processing\icon.ico, 1, 1
localver = v1.7.0
localver := trim(localver)
stop := 0
aspw := 16
asph := 9
reswidth := 1920
resheight := 1080
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/MierenManz/versiontest/master/README.md", true)
whr.Send()
whr.WaitForResponse()
onlinecheck := whr.ResponseText
onlinecheck := StrReplace(StrReplace(onlinecheck, "`n"), "`r")
  if (localver !== onlinecheck)
  {
    msgbox, 4,, there is an update! Do you want to update?
    IfMsgBox, Yes
    {
    run, %A_ScriptDir%\updates\updater.exe %onlinecheck%
    exitapp
  }
}
config := A_ScriptDir . "\processing\config.txt"
if !FileExist(config)
{
  runwait, %ComSpec% /c cd processing && npm install,, hide
} else {
    FileDelete, %config%
}

gui, main:New
gui, main:Add, Button, gFileselect vFilesel x2 y2 w80 h25, Select File
gui, main:Add, CheckBox, x2 y32 vCvbr,Use Constant Bitrate
gui, main:Add, CheckBox, x2 y47 vH265,Use HEVC encoder
gui, main:Add, CheckBox, x2 y62 vGpu,Use GPU transcoding
Gui, main:Add, Text, +center x140 y3, bitrate(kbps)
Gui, main:Add, Edit, +center x200 y2 w80 h20 Number
Gui, main:Add, UpDown, vKBPS 0x80 Range0-2147483647
Gui, main:Add, Text, +center x170 y34, Width
Gui, main:Add, Edit, +center ReadOnly x200 y30 w80 h20 Number
Gui, main:Add, UpDown, gsizecontrol1 vvWidth 0x80 Range0-2147483647
Gui, main:Add, Text, +center x167 y53, Height
Gui, main:Add, Edit, +center gsizecontrol x200 y50 w80 h20 Number
Gui, main:Add, UpDown, gsizecontrol vvHeight 0x80 Range0-2147483647
Gui, main:Add, Button, gSubmit x195 y80 w80 h30, Start Conversion
Gui, main:Add, Button, gUsePreset x15 y80 w80 h30, Use Preset
Gui, main:Add, Button, gSavePreset x105 y80 w80 h30, Save Preset
gui, main:Show,, Transcoder
return

UsePreset:
{
  FileSelectFile, presetFile,, %A_ScriptDir%\presets,, *.preset
    if !presetFile {
      msgbox, 4,, You forgot to select a file `n Want to Select a new one?
      IfMsgBox, Yes
        {
          goto, UsePreset
          return
        } else {
          return
        }
    } else {
    IniRead, height, %presetfile%, preset, videoheight
    IniRead, width, %presetfile%, preset, videowidth
    IniRead, kbrate, %presetfile%, preset, bitrate
    IniRead, convar, %presetfile%, preset, constorvar
    IniRead, gpurender, %presetfile%, preset, use_gpu
    IniRead, H265codec, %presetfile%, preset, use_h265
    GuiControl, main:, vHeight, %height%
    GuiControl, main:, vWidth, %width%
    GuiControl, main:, KBPS, %kbrate%
    GuiControl, main:, Cvbr, %convar%
    GuiControl, main:, Gpu, %gpurender%
    GuiControl, main:, H265, %H265codec%
    return
  }
}
SavePreset:
{
  gui, main:Submit, nohide
  InputBox, userinput, Create preset, What do you want to name the preset?
  if ErrorLevel
    {
      return
    }
  if Instr(FileExist(A_ScriptDir "\presets\" userinput ".preset"), "A") {
    MsgBox, 4,, This file already exists. Do you want to overwrite it?
    IfMsgBox, yes
      {
      goto, WritePreset
      msgbox, %useinput%.preset has been overwritten! Click ok to return to the main menu
      return
    } else {
      msgbox, No files were overwritten! Click ok to return to the main menu
      return
    }
  } else {
    goto, WritePreset
    return
  }
}
WritePreset:
{
  FileAppend,, %A_ScriptDir%\presets\%userinput%.preset
  IniWrite, %vHeight%, %A_ScriptDir%\presets\%userinput%.preset, preset, videoheight
  IniWrite, %vWidth%, %A_ScriptDir%\presets\%userinput%.preset, preset, videowidth
  IniWrite, %KBPS%, %A_ScriptDir%\presets\%userinput%.preset, preset, bitrate
  IniWrite, %Cvbr%, %A_ScriptDir%\presets\%userinput%.preset, preset, constorvar
  IniWrite, %Gpu%, %A_ScriptDir%\presets\%userinput%.preset, preset, use_gpu
  IniWrite, %H265%, %A_ScriptDir%\presets\%userinput%.preset, preset, use_h265
  return
}
Fileselect:
{   
  FileSelectFile, inpFile, 2
    if !inpFile {
    msgbox, hey, you forgot to give me something to transcode
    return
  } else {
    GuiControl, main:, Filesel, File Selected!
    Inptfile = "%inpFile%"
    StdOutStream( "node.exe " A_ScriptDir "\processing\probe.js " Inptfile, "probe_Callback")
    return
  }
}


sizecontrol1:
{
  gui, main:Submit, nohide
  aspw := Trim(aspw)
  asph := Trim(asph)
  height := vWidth / aspw * asph
  GuiControl, main:, vHeight, %height%
  return
}

sizecontrol:
{
  gui, main:Submit, nohide
  width := vHeight / asph * aspw
  GuiControl, main:, vWidth, %width%
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
  Gui, main:Submit
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
  if (vWidth = 0) {
    FileAppend, %reswidth%`n, %config%
  } else {
    FileAppend, %vWidth%`n, %config%
  }
  if (vHeight = 0) {
    FileAppend, %resheight%`n, %config%
  } else {
    FileAppend, %vHeight%`n, %config%
  }
  gui, main:Destroy
  gui, outputlog:New,
  gui, outputlog:Add, Button, gClose x87 y5 w175 h25, Close window
  gui, outputlog:Add, Edit, r7 vDefaults +center ReadOnly x0 y35 w350
  gui, outputlog:Add, Edit, r1 vLOG +center ReadOnly x75 y135 w100
  gui, outputlog:Add, Edit, r1 vETR +center ReadOnly x176 y135 w100
  gui, outputlog:Show, w350 h235, Transcoder
  start := A_TickCount
  StdOutStream( "node.exe " A_ScriptDir "\processing\transcoder.js " Inptfile, "main_Callback")
  return
}
removetooltip:
{
  tooltip,
  return
}

mainguiClose:
Close:
{
  exitapp
}

StdOutStream( sCmd, Callback = "" ) {
  Static StrGet := "StrGet"
                                    
  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

  if(a_ptrSize=8){
    VarSetCapacity( STARTUPINFO, 104, 0  )
    NumPut( 68,         STARTUPINFO,  0 )
    NumPut( 0x100,      STARTUPINFO, 60 )
    NumPut( hPipeWrite, STARTUPINFO, 88 )
    NumPut( hPipeWrite, STARTUPINFO, 96 )
    VarSetCapacity( PROCESS_INFORMATION, 32 )
  }else{
    VarSetCapacity( STARTUPINFO, 68, 0  )
    NumPut( 68,         STARTUPINFO,  0 )
    NumPut( 0x100,      STARTUPINFO, 44 )
    NumPut( hPipeWrite, STARTUPINFO, 60 )
    NumPut( hPipeWrite, STARTUPINFO, 64 )
    VarSetCapacity( PROCESS_INFORMATION, 16 )
  }
  If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0
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

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )
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

main_Callback( data, n ) {
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
      tooltip, Render Finished
      SetTimer, removetooltip, 5000
      global stop = 1
      return
}

  if ! ( n ) {
    Return
  }
}

probe_Callback( data, n ) {
  Static vHeight
  Static vWidth
  Caser := SubStr(data, 1, 4)
  Switch Caser {
    case "aspw":
      ree1 := SubStr(data, 5)
      ree1 := StrReplace(ree1, "`n")
      ree1 := StrReplace(ree1, A_Space)
      global aspw := ree1
      return
    case "asph":
      ree2 := SubStr(data, 5)
      ree2 := StrReplace(ree2, "`n")
      ree2 := StrReplace(ree2, A_Space)
      global asph := ree2
      return
  }
  if ! ( n ) {
    Return
  }
}