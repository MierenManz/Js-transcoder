// transcoder!
var start = Math.floor(new Date().getTime() / 1000);
const ffmpeg = require('fluent-ffmpeg');
const ini = require('ini');
const fs = require('fs');
const sendkeys = require('sendkeys-js');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/bin/ffprobe.exe");

var inputfile = process.argv[2];
var config = ini.parse(fs.readFileSync(__dirname + '/config.ini', 'utf-8'));
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    if (err) throw err;
    var etrloc = "./processing/etr.txt";
    var stdintxt = "./processing/log.txt";
    var decode = metadata.streams[0].codec_name;
    var CBR = false;
    var etrcalc = 0
    var gpuInputs = [];
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
    var H265gpu = config.main.USE_h265 + config.main.USE_GPU;
    switch (H265gpu) {
        case "00":
            var codex = "libx264";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "01":
            var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
            var codex = "h264_nvenc";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
        case "10":
            var codex = "libx265";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + "\nUsing cpu rendering!";
            break;
        case "11":
            var gpuInputs = ["-vsync 0", "-hwaccel cuvid", "-hwaccel_device 0", `-c:v ${decode}_cuvid`];
            var codex = "hevc_nvenc";
            var ifstates = ifstates + '\nUsing "' + codex + '" as codec' + '\nUsing Hardware Accelerated rendering! With these options:\n"' + gpuInputs + '"';
            break;
    };
    console.log(ifstates);
    fs.appendFileSync(stdintxt, ifstates);
    sendkeys.send('{f15}');
    fs.writeFileSync(stdintxt, "");
    var proc = ffmpeg();
    proc.setFfmpegPath(__dirname + "/ffmpeg/bin/ffmpeg.exe")
        .input(inputfile)
        .videoBitrate(vidbitr8, CBR)
        .inputOption(gpuInputs)
        .videoCodec(codex)
        .on('progress', function(progress) {
            var percentage = Math.round((progress.percent + Number.EPSILON) * 100) / 100;
            if (percentage > 100) percentage = 100;
            if (etacalc = 5) {
                var etacalc = 0;
                var current = Math.floor(new Date().getTime() / 1000);
                var timeleft = Math.round(((current - start) / percentage) * (100 - percentage));
                fs.appendFile(etrloc, timeleft, (err) => {
                    if (err) throw err;
                    sendkeys.send('{f13}');
                    return fs.writeFileSync(etrloc, "");
                });
            } else {
                var etacalc = etacalc + 1
            }
            var stuffs = "" + percentage + "% finished";
            fs.appendFile(stdintxt, stuffs, (err) => {
                if (err) throw err;
                sendkeys.send('{f16}');
                return fs.writeFileSync(stdintxt, "");
            })
        })
        .on('end', function() {
            fs.writeFileSync(stdintxt, "Render finished");
            sendkeys.send('{f16}');
            console.log("Render finished");
            sendkeys.send('{f14}');
            fs.unlinkSync(stdintxt);
            fs.unlinkSync(etrloc)
        })
        .on('error', function(err) {
            fs.appendFileSync(stdintxt, "\n" + err);
            sendkeys.send('{f15}');
            sendkeys.send('{f14}')
            console.log(err.message);
            fs.unlinkSync(stdintxt);
            fs.unlinkSync(output);
    }).save(output);
});