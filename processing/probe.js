const ffmpeg = require('fluent-ffmpeg');
ffmpeg.setFfprobePath(__dirname + "/ffmpeg/ffprobe.exe");
inputfile = process.argv[2];
ffmpeg.ffprobe(inputfile, (err, metadata) => {
    var aspect = metadata.streams[0].display_aspect_ratio;
    var vheight = metadata.streams[0].height;
    var vwidth = metadata.streams[0].width;
    var aspwidthheight = aspect.split(":");
    console.log("aspw" + aspwidthheight[0]);
    console.log("asph" + aspwidthheight[1]);
});