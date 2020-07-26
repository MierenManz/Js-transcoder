runwait, %ComSpec% /c node %A_ScriptDir%\gpu.js > output.txt
FileRead, beep, %A_ScriptDir%\output.txt