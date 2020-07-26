const spawn = require('child_process').spawn
var data = process.argv[2]
ahk = spawn("C:/Program Files/AutoHotkey/AutoHotkey.exe", [`./processing/default.ahk`, data]);