// transcoder!
var start = Math.floor(new Date().getTime() / 1000);
const ffmpeg = require('fluent-ffmpeg');
const ini = require('ini');
const fs = require('fs');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/bin/ffprobe.exe");

var inputfile = process.argv[2];
var config = fs.readFileSync(__dirname + '/config.txt', 'utf-8')
var config = config.toString().split("\r\n")
var NVIDIA = config[0]
var BITRATE = config[1]
var CBVR = config[2]
var USE_GPU = config[3]
var USE_H265 = config[4]
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    var decode = metadata.streams[0].codec_name;
    var CBR = false;
    var gpuInputs = [];
    var H265gpu = USE_H265 + USE_GPU;
    var vidbitr8 = Math.round((metadata.streams[0].bit_rate / 1000)) + "k";
    if (CBVR == "true") {
        var CBR = CBVR;
        var ifstates = "Constant BitRate (CBR) is enabled!";
    } else var ifstates = "Variable BitRate (VBR) is enabled!";
    if (BITRATE !== "empty") {
        var vidbitr8 = BITRATE + "k";
        var ifstates = ifstates + "\nCustom bitrate is specified!\nUsing " + vidbitr8 + "bps";
    } else var ifstates = ifstates + "\nNo bitrate was specified!\nUsing bitrate of original file which is " + vidbitr8 + "bps";
    switch (H265gpu) {
        case "00":
            var codex = "libx264";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "01":
            if (NVIDIA == "true") {
                var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
                var codex = "h264_nvenc";
            } else {
                var gpuInputs = ["-vsync 0", "-hwaccel dxva2", "-hwaccel_device 0"];
                var codex = "h264_amf";
            }
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
        case "10":
            var codex = "libx265";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "11":
            if (NVIDIA == "true") {
                var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
                var codex = "hevc_nvenc";
            } else {
                var gpuInputs = ["-vsync 0", "-hwaccel dxva2", "-hwaccel_device 0"];
                var codex = "hevc_amf"
            }
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
    };
    console.log("defs" + ifstates);
    var proc = ffmpeg();
    proc.setFfmpegPath(__dirname + "/ffmpeg/bin/ffmpeg.exe")
        .input(inputfile)
        .videoBitrate(vidbitr8, CBR)
        .inputOption(gpuInputs)
        .videoCodec(codex)
        .on('progress', function(progress) {
            var percentage = Math.round((progress.percent + Number.EPSILON) * 100) / 100;
            if (percentage > 100) percentage = 100;
            if (etrcalc = 5) {
                var etrcalc = 0;
                var current = Math.floor(new Date().getTime() / 1000);
                var timelefttotalS = Math.round(((current - start) / percentage) * (100 - percentage));
                var timeleftM = Math.floor(timelefttotalS / 60);
                var timeleftSadjusted = timelefttotalS - (60 * timeleftM);
                var timelength = timeleftSadjusted.toString().length;
                if (timelength !== 2) var timeleftSadjusted = "0" + timeleftSadjusted;
                var timeleftformatted = `${timeleftM}:${timeleftSadjusted}`;
                console.log("estr" + timeleftformatted)
            } else {
                var etrcalc = etrcalc + 1;
            }
            console.log(`perc${percentage}% Finished`)
        })
        .on('end', function() {
            console.log("stop");
            console.log("defsRender Finished")
            process.exit(0)
        })
        .on('error', function(err) {
            console.log("defs" + err.message);
            console.log("stop")
            fs.unlinkSync('./output.mp4');
            process.exit(0);
    }).save('./output.mp4');
});