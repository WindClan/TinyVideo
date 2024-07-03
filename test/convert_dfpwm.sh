rm left.dfpwm
rm right.dfpwm
ffmpeg -i input.wav -filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]" -map "[left]" left.wav -map "[right]" right.wav
ffmpeg -i left.wav -ar 48k -ac 1 -c:a dfpwm left.dfpwm
ffmpeg -i right.wav -ar 48k -ac 1 -c:a dfpwm right.dfpwm
rm left.wav
rm right.wav

#rm input.wav
rm audio.aac