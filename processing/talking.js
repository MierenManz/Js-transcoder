const spawn = require('child_process').spawn,
    ahk = spawn("C:/Program Files/AutoHotkey/AutoHotkey.exe", ['./processing/comms.ahk']);
    ahk.stdin.write(process.argv[2]+'\r\n');