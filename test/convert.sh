ffmpeg -y -r 30 -i videoplayback.mp4 -r 6 output.mp4
ffmpeg -i output.mp4 -vn -acodec copy audio.aac
ffmpeg -i audio.aac input.wav
./convert_dfpwm.sh