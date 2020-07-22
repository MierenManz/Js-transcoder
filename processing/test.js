const ffmpeg = require('fluent-ffmpeg');
ffmpeg.ffprobe('./ree.mp4',function(err, metadata) {
    console.log(metadata);
  });