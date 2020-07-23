const ffmpeg = require('fluent-ffmpeg');
const ini = require('ini');
const fs = require('fs');

ffmpeg.setFfmpegPath("./ffmpeg/bin/ffmpeg.exe");
ffmpeg.setFfprobePath("./ffmpeg/bin/ffprobe.exe");

var inputfile = process.argv[2];
var config = ini.parse(fs.readFileSync('./config.ini', 'utf-8'))
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    console.log(config);
    var CBR = false;
    var output = "../output.mp4";
    var vidbitr8 = Math.round((metadata.streams[0].bit_rate / 1000)) + "k";
    if (config.main.CBR == true) {
        var CBR = config.main.CBR;
        console.log("Constant BitRate (CBR) is enabled!");
    } else console.log("Variable BitRate (VBR) is enabled!");

    if (config.main.BITRATE !== "empty") {
        var vidbitr8 = config.main.BITRATE;
        console.log("Custom bitrate is specified! Using " + vidbitr8 + "bps");
    } else console.log("No bitrate was specified! Using bitrate of original file which is " + vidbitr8 + "bps");

    if (config.main.OUTPUT !== "empty") {
        var output = config.main.OUTPUT;
        console.log('Custom output path is specified! Using "' + output + '" as output path');
    } else console.log("no output path was specified! Using default path");
    if (config.main.USE_h265 == true) {
        var codec = "hevc_nvenc"
        console.log('HEVC(h265) is specified! Using "' + codec + '" as encoding codec')
    } else console.log('AVC(h264) is specified! Using"' + codec + '" as encoding codec')
});