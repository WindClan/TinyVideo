ffmpeg -y -i  videoplayback.mp4 -vf "scale=114:114,setsar=1" -ar 48k -r 20 output.mp4
rm audio.aac
ffmpeg -i output.mp4 -vn -acodec copy audio.aac
rm input.wav
ffmpeg -i audio.aac -acodec pcm_u8 -ac 1 input.wav
./convert_dfpwm.sh