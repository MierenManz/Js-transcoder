var start = Math.floor(new Date().getTime() / 1000);
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/ffprobe.exe");
var inputfile = process.argv[2];
var config = fs.readFileSync(__dirname + '/config.txt', 'utf-8');
var config = config.toString().split("\r\n");
var NVIDIA = config[0];
var BITRATE = config[1];
var CBVR = config[2];
var USE_GPU = config[3];
var USE_H265 = config[4];
var vvwidth = config[5];
var vvheight = config[6];
var cpuresize = [];
var gpuInputs = [];
var H265gpu = USE_H265 + USE_GPU;
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    var decode = metadata.streams[0].codec_name;
    var vidbitr8 = Math.round((metadata.streams[0].bit_rate / 1000)) + "k";
    if (CBVR == "true") {
        var ifstates = "Constant BitRate (CBR) is enabled!";
    } else var ifstates = "Variable BitRate (VBR) is enabled!";
    if (BITRATE !== "empty") {
        var vidbitr8 = BITRATE + "k";
        var ifstates = ifstates + "\nCustom bitrate is specified!\nUsing " + vidbitr8 + "bps";
    } else var ifstates = ifstates + "\nNo bitrate was specified!\nUsing original bitrate of " + vidbitr8 + "bps";
    var res = vvwidth + vvheight;
    switch (H265gpu) {
        case "00":
            var codex = "libx264";
            if (res !== "00") cpuresize.push(`-vf scale=${vvwidth}:${vvheight}`);
            var ifstates = ifstates + `\nUsing resolution of ${vvwidth}x${vvheight}`;
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "01":
            if (res !== "00") gpuInputs.push(`-resize ${vvwidth}x${vvheight}`);
            if (NVIDIA == "true") {
                gpuInputs.push("-vsync 0", "-hwaccel cuda", "-hwaccel_device 0", `-c:v ${decode}_cuvid`, "-hwaccel_output_format cuda");
                var codex = "h264_nvenc";
            } else {
                gpuInputs.push("-vsync 0", "-hwaccel dxva2", "-hwaccel_device 0");
                var codex = "h264_amf";
            }
            var ifstates = ifstates + `\nUsing resolution of ${vvwidth}x${vvheight}`;
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
        case "10":
            var codex = "libx265";
            if (res !== "00") cpuresize.push(`-vf scale=${vvwidth}:${vvheight}`);
            var ifstates = ifstates + `\nUsing resolution of ${vvwidth}x${vvheight}`;
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "11":
            if (res !== "00") gpuInputs.push(`-resize ${vvwidth}x${vvheight}`);
            if (NVIDIA == "true") {
                gpuInputs.push("-vsync 0", "-hwaccel_device 0", "-hwaccel cuda", `-c:v ${decode}_cuvid`, "-hwaccel_output_format cuda");
                var codex = "hevc_nvenc";
            } else {
                gpuInputs.push("-vsync 0", "-hwaccel dxva2", "-hwaccel_device 0");
                var codex = "hevc_amf";
            };
            var ifstates = ifstates + `\nUsing resolution of ${vvwidth}x${vvheight}`;
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
    };
    console.log("defs" + ifstates);
    var proc = ffmpeg();
    proc.setFfmpegPath(__dirname + "/ffmpeg/ffmpeg.exe")
        .input(inputfile)
        .videoBitrate(vidbitr8, CBVR)
        .inputOption(gpuInputs)
        .outputOption(cpuresize)
        .videoCodec(codex)
        .on('progress', function(progress) {
            var percentage = Math.round((progress.percent + Number.EPSILON) * 100 / 100);
            if (percentage > 100) percentage = 100;
            var etrcalc = 0;
            var current = Math.floor(new Date().getTime() / 1000);
            var timelefttotalS = Math.round(((current - start) / percentage) * (100 - percentage));
            var timeleftM = Math.floor(timelefttotalS / 60);
            var timeleftSadjusted = timelefttotalS - (60 * timeleftM);
            var timelength = timeleftSadjusted.toString().length;
            if (timelength !== 2) var timeleftSadjusted = "0" + timeleftSadjusted;
            var timeleftformatted = `${timeleftM}:${timeleftSadjusted}`;
            console.log("estr" + timeleftformatted + " left");
            var etrcalc = etrcalc + 1;
            console.log(`perc${percentage}% Finished`);
        })
        .on('end', function() {
            console.log("defsRender Finished");
            console.log("stop");
            process.exit(0);
        })
        .on('error', function(err, stdout, stderr) {
            console.log("defs" + stderr);
            console.log("stop");
            fs.unlinkSync('./output.mp4');
            process.exit(0);
    }).save('./output.mp4');
});