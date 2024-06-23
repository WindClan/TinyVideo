local header = "TinyBIMG"
local isComputerCraft = colors and true or false
local m = {}

function m:encode(video)
	local str = ""
	for frameNum,frame in ipairs(video) do
		for lineNum,line in ipairs(frame) do
			str = str..line[1]..line[2]..line[3]
		end
	end
	charsPerLine = #video[1][1][1]
	linesPerFrame = #video[1]
	local meta = header.."\00"..#str.."\00"..charsPerLine.."\00"..linesPerFrame.."\00"..#video.."\00"
	local encoded = meta..str
	--print(#str,encoderCharsPerLine,encoderLinesPerFrame,#video)
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
		error("File is not a valid TinyBIMG!",0)
	end
	local strLength = tonumber(getHeaderValue(file))
	local charsPerLine = tonumber(getHeaderValue(file))
	local linesPerFrame = tonumber(getHeaderValue(file))
	local numberOfFrames = tonumber(getHeaderValue(file))
	--print(strLength,charsPerLine,linesPerFrame,numberOfFrames)
	local bimg = {}
	local currentLine = 1
	local currentFrame = 1
	local currentCharacter = 0
	while (currentCharacter < strLength) do
		if currentLine > linesPerFrame then
			currentFrame = currentFrame + 1
			currentLine = 1
		end
		if not bimg[currentFrame] then
			bimg[currentFrame] = {}
		end
		bimg[currentFrame][currentLine] = {
			file:read(charsPerLine),
			file:read(charsPerLine),
			file:read(charsPerLine)
		}
		if bimg[currentFrame][currentLine] == {nil,nil,nil} then
			bimg[currentFrame][currentLine] = nil
		end
		currentLine = currentLine + 1
		currentCharacter = currentCharacter + charsPerLine*3
	end
	
	file:close()
	
	return bimg
end

return m