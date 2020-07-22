const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
var inputfile = process.argv[2];
var output = "./output.mp4";

if (process.argv[3]) var output = process.argv[3];

if (process.argv[4]) var vidbitr8 = process.argv[4];

    try {
        var proc = ffmpeg();
        proc.setFfmpegPath("./ffmpeg/bin/ffmpeg.exe")
            .input(inputfile)
            .videoBitrate(vidbitr8)
            .inputOption([
                "-hwaccel cuvid",
                "-hwaccel_device 0",
                "-c:v h264_cuvid"
            ])
            .videoCodec("h264_nvenc")
            .on('end', function() {
            })
            .on('error', function(err) {
                console.log(err)
                fs.unlinkSync(output);
            }).save(output);
    } catch(e) { console.error(e)};