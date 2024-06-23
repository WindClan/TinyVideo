local header = "TinyVideo"
local isComputerCraft = colors and true or false
local secondOfDfpwm = 6000
local m = {}

function m:encode(video,leftDfpwmHandle,rightDfpwmHandle,fps)
	print("encode start")
	local str = ""
	local lastIndex = 0
	local lastIndex1 = 0
	local bytesOfDfpwm = math.floor((secondOfDfpwm/fps)+0.5)
	charsPerLine = #video[1][1][1]
	linesPerFrame = #video[1]
	for i=1,#video do
		local read1 = leftDfpwmHandle:read(bytesOfDfpwm)
		local read2 = rightDfpwmHandle:read(bytesOfDfpwm)
		if read1 == nil or read2 == nil then
			break
		end
		for y=1,linesPerFrame do
			local line = video[i][y]
			local addition = line[1]..line[2]..line[3]
			if #addition ~= charsPerLine*3 then
				error("How did this happen?",0)
			end
			str = str..addition
			print("line "..y.." of frame "..i.." done")
		end	
		print("audio bytes ".. lastIndex+1 .." to "..lastIndex+bytesOfDfpwm.." added to frame "..i)
		str = str..read1
		str = str..read2
		lastIndex = lastIndex + bytesOfDfpwm
		lastIndex1 = lastIndex1 + bytesOfDfpwm
		if i % 100 == 0 then
			sleep()
		end
	end
	local meta = header.."\00"..#str.."\00"..charsPerLine.."\00"..linesPerFrame.."\00"..#video.."\00"..fps.."\00"..bytesOfDfpwm.."\00"
	--local meta = header.."\00"..string.pack(">LI2I2I2",#str,charsPerLine,linesPerFrame,#video)
	local encoded = meta..str
	print(#str,encoderCharsPerLine,encoderLinesPerFrame,#video,fps,bytesOfDfpwm)
	leftDfpwmHandle:close()
	rightDfpwmHandle:close()
	print("encode stop")
	return encoded
end
local function getHeaderValue(file)
	local endOfHeader = false
	local lastCharWasEnd = false
	local header = ""
	while not endOfHeader do
		local byte = file:read(1)
		if byte == "\00" then
			endOfHeader = true
		else
			header = header..byte
		end
	end
	
	return header
end
function m:decode(fileName)
	local file = io.open(fileName,"r")
	local ver = getHeaderValue(file)
	if ver ~= header then
		error("File is not a valid TinyVideo!",0)
	end
	local strLength = tonumber(getHeaderValue(file))
	local charsPerLine = tonumber(getHeaderValue(file))
	local linesPerFrame = tonumber(getHeaderValue(file))
	local numberOfFrames = tonumber(getHeaderValue(file))
	local frameRate = tonumber(getHeaderValue(file))
	local bytesOfDfpwm = tonumber(getHeaderValue(file))
	local data = {
		frameRate = frameRate
	}
	local currentLine = 1
	local currentFrame = 1
	local currentCharacter = 0
	for i=1,numberOfFrames do
		data[i] = {}
		for y=1,linesPerFrame do
			data[i][y] = {
				file:read(charsPerLine),
				file:read(charsPerLine),
				file:read(charsPerLine)
			}
		end
		data[i].audio = {
			left = file:read(bytesOfDfpwm),
			right = file:read(bytesOfDfpwm)
		}
	end
	file:close()
	
	return data
end

return m