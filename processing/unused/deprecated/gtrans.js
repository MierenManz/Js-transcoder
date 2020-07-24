// deprecated gpu transcoder

const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
var inputfile = process.argv[2];
var output = "./output.mp4";
    try {
        var proc = ffmpeg();
        proc.setFfmpegPath(__dirname + "/ffmpeg/bin/ffmpeg.exe")
            .input(inputfile)
            .videoBitrate("1050")
            .inputOption([
                "-hwaccel cuvid",
                "-hwaccel_device 0",
                "-c:v h264_cuvid"
            ])
            .videoCodec("h264_nvenc")
            .on('progress', function(progress) {
                console.log(Math.round((progress.percent + Number.EPSILON) * 100) / 100)
            })
            .on('end', function() {
                console.log("Render finished")
            })
            .on('error', function(err) {
                console.log(err)
                fs.unlinkSync(output);
            }).save(output);
    } catch(e) { console.error(e)};