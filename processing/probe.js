const ffmpeg = require('fluent-ffmpeg');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/ffprobe.exe");
inputfile = process.argv[2];
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    var width1 = metadata.streams[0].width;
    var height1 = metadata.streams[0].height;
    console.log("aspw" + width1);
    console.log("asph" + height1);
});