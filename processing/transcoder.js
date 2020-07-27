// transcoder!
var start = Math.floor(new Date().getTime() / 1000);
const ffmpeg = require('fluent-ffmpeg');
const ini = require('ini');
const fs = require('fs');
const spawn = require('child_process').spawn
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/bin/ffprobe.exe");

var inputfile = process.argv[2];
var config = ini.parse(fs.readFileSync(__dirname + '/config.ini', 'utf-8'));
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    var decode = metadata.streams[0].codec_name;
    var CBR = false;
    var gpuInputs = [];
    var H265gpu = config.main.USE_h265 + config.main.USE_GPU;
    var output = "./output.mp4";
    var vidbitr8 = Math.round((metadata.streams[0].bit_rate / 1000)) + "k";
    if (config.main.CBR == true) {
        var CBR = config.main.CBR;
        var ifstates = "Constant BitRate (CBR) is enabled!";
    } else var ifstates = "Variable BitRate (VBR) is enabled!";
    if (config.main.BITRATE !== "empty") {
        var vidbitr8 = config.main.BITRATE + "k";
        var ifstates = ifstates + "\nCustom bitrate is specified!\nUsing " + vidbitr8 + "bps";
    } else var ifstates = ifstates + "\nNo bitrate was specified!\nUsing bitrate of original file which is " + vidbitr8 + "bps";
    if (config.main.OUTPUT !== "empty") {
        var output = config.main.OUTPUT;
        var ifstates = ifstates + '\nCustom output path is specified!\nUsing "' + output + '" as output path';
    } else var ifstates = ifstates + "\nNo output path was specified!\nUsing default path";
    switch (H265gpu) {
        case "00":
            var codex = "libx264";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "01":
            if (config.main.NVIDIA == true) {
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
            if (config.main.NVIDIA == true) {
                var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
                var codex = "hevc_nvenc";
            } else {
                var gpuInputs = ["-vsync 0", "-hwaccel dxva2", "-hwaccel_device 0"];
                var codex = "hevc_amf"
            }
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
    };
    console.log(ifstates);
    AHKcomms("default", ifstates);
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
                AHKcomms("etr", timeleftformatted);
            } else {
                var etrcalc = etrcalc + 1;
            }
            AHKcomms("logging", percentage + "% Finished");
        })
        .on('end', function() {
            AHKcomms("logging", "Render Finished");
            console.log("Render finished");
            process.exit(0)
        })
        .on('error', function(err) {
            AHKcomms("defaults", err.message);
            console.log(err.message);
            fs.unlinkSync(output);
            process.exit(0);
    }).save(output);
});

function AHKcomms(type, data) {
    ahk = spawn("C:/Program Files/AutoHotkey/AutoHotkey.exe", [`./processing/ahk/${type}.ahk`, data]);
    ahk.stdout.on('end', function () {
        ahk.stdin.kill();
    });
    return
};