// transcoder!
const ffmpeg = require('fluent-ffmpeg');
const ini = require('ini');
const fs = require('fs');

ffmpeg.setFfprobePath(__dirname + "/ffmpeg/bin/ffprobe.exe");

var inputfile = process.argv[2];
var config = ini.parse(fs.readFileSync(__dirname + '/config.ini', 'utf-8'))
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    var decode = metadata.streams[0].codec_name
    var CBR = false;
    var gpuInputs = [];
    var output = "./output.mp4"
    var vidbitr8 = Math.round((metadata.streams[0].bit_rate / 1000)) + "k";
    if (config.main.CBR == true) {
        var CBR = config.main.CBR;
        console.log("Constant BitRate (CBR) is enabled!");
    } else console.log("Variable BitRate (VBR) is enabled!");

    if (config.main.BITRATE !== "empty") {
        var vidbitr8 = config.main.BITRATE + "k";
        console.log("Custom bitrate is specified! Using " + vidbitr8 + "bps");
    } else console.log("No bitrate was specified! Using bitrate of original file which is " + vidbitr8 + "bps");

    if (config.main.OUTPUT !== "empty") {
        var output = config.main.OUTPUT;
        console.log('Custom output path is specified! Using "' + output + '" as output path');
    } else console.log("no output path was specified! Using default path");

    var H265gpu = config.main.USE_h265 + config.main.USE_GPU
    switch (H265gpu) {
        case "00":
            var codex = "libx264";
            console.log('Using "' + codex + '" as codec');
            console.log("Using cpu rendering! with " + gpuInputs + " threads");
            break;
        case "01":
            var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
            var codex = "h264_nvenc";
            console.log('Using "' + codex + '" as codec');
            console.log('Using Hardware Accelerated rendering! With these options: "' + gpuInputs + '"');
            break;
        case "10":
            var codex = "libx265";
            console.log('Using "' + codex + '" as codec');
            console.log("Using cpu rendering! with " + gpuInputs + " threads");
            break;
        case "11":
            var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
            var codex = "hevc_nvenc";
            console.log('Using "' + codex + '" as codec');
            console.log('Using Hardware Accelerated rendering! With these options: "' + gpuInputs + '"');
            break;
    };
    var proc = ffmpeg();
    proc.setFfmpegPath(__dirname + "/ffmpeg/bin/ffmpeg.exe")
        .input(inputfile)
        .videoBitrate(vidbitr8, CBR)
        .inputOption(gpuInputs)
        .videoCodec(codex)
        .on('progress', function(progress) {
            console.log(Math.round((progress.percent + Number.EPSILON) * 100) / 100)
        })
        .on('end', function() {
            console.log("Render finished")
        })
        .on('error', function(err) {
            console.log(err.message)
            fs.unlinkSync(output);
    }).save(output)
});