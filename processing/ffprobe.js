const ffmpeg = require('fluent-ffmpeg');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/bin/ffprobe.exe");
ffmpeg.ffprobe("./output.mp4", (err, metadata) => {
    console.log(metadata.streams[0].codec_name)
})