--[[
	Copyright 2024 WindClan

	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the “Software”), to deal in
	the Software without restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
	Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
]]
local header = "TinyVideo"
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