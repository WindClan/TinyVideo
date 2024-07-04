local dfpwm = require("cc.audio.dfpwm")
periphemu.create("front","speaker")
local speaker = peripheral.wrap("front")
local tinyvideo = require("tinyvideo")
local data = tinyvideo:decode("video.tinyvideo")
local decoder = dfpwm.make_decoder()
for _,frame in ipairs(data) do
	for i,line in ipairs(frame) do
		term.setCursorPos(1,i)
		term.blit(line[1],line[2],line[3])
	end
	speaker.playAudio(decoder(frame.audio.left))
	sleep(1/data.frameRate)
end