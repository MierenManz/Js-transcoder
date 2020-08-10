const fs = require('fs')

var amd = fs.readFileSync("./amd.txt")
console.log(amd.indexOf("GeForce"))
var nvid = fs.readFileSync("./nvid.txt")
console.log(nvid.indexOf("GeForce"))