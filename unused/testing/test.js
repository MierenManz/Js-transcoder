const spawn = require('child_process').spawn;
var spawnarg = process.argv[2];
ahk = spawn("C:/Program Files/AutoHotkey/AutoHotkey.exe", [`./processing/ahk/test.ahk`, spawnarg]);
ahk.stdout.on('data', function(data){
    var dataString = data.toString()
    console.log(dataString)
    ahk.kill()
});
return