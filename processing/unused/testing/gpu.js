const exec = require('child_process').exec;
exec('wmic path win32_VideoController', (error, stdout, stderr) => {
    if (error) {
        
    }
    stdout.indexOf("GeForce")
})