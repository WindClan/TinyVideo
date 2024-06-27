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
local header = "TinyBIMG"
local m = {}
function m:encode(video,palette,...)
	local str = ""
	for frameNum,frame in ipairs(video) do
		for lineNum,line in ipairs(frame) do
			str = str..line[1]..line[2]..line[3]
		end
	end
	charsPerLine = #video[1][1][1]
	linesPerFrame = #video[1]
	local header1 = header
	local meta = "\00"..#str.."\00"..charsPerLine.."\00"..linesPerFrame.."\00"..#video.."\00"
	if palette then
		ver = ver + 1
		error("Not implemented.",0)
		--palette hasn't been implemented yet so idk, maybe store the colors as hex values?
	end
	local optional = {...}
	for i,v in pairs(optional) do
		ver = ver + 1
		local meta = meta..v.."\00"
	end
	if ver ~= 0 then
		header1 = header1..ver
	end
	local encoded =header1.. meta..str
	return encoded
end
local function getHeaderValue(file)
	local endOfHeader = false
	local lastCharWasEnd = false
	local header = ""
	while not endOfHeader do
		local byte = file.read(1)
		if byte == "\00" then
			endOfHeader = true
		else
			header = header..byte
		end
	end
	return header
end
local function getVariant(file)
	local ver = getHeaderValue(file)
	if #ver < #header or ver:sub(1,#header) ~= header then
		return nil -- not a valid tinybimg file
	end
	if ver == header then
		return 0
	end
	return tonumber(ver:sub(#header+1,#ver))
end
function m:decode(fileName)
	local file
	if type(fileName) == "string" then
		file = fs.open(fileName,"r")
	else
		file = fileName
	end	
	
	local ver = getVariant(file)
	if not ver then
		error("File is not a valid TinyBIMG!",0)
	end
	local strLength = tonumber(getHeaderValue(file))
	local charsPerLine = tonumber(getHeaderValue(file))
	local linesPerFrame = tonumber(getHeaderValue(file))
	local numberOfFrames = tonumber(getHeaderValue(file))
	local extra = {}
	local palette
	if ver > 0 then
		palette = getHeaderValue(file)--todo: decode this
	end
	if ver > 1 then
		for i=1,ver do
			extra[i] = getHeaderValue(file)
		end
	end
	local bimg = {
		extra = extra,
		palette = palette
	}
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
			file.read(charsPerLine),
			file.read(charsPerLine),
			file.read(charsPerLine)
		}
		if bimg[currentFrame][currentLine] == {nil,nil,nil} then
			bimg[currentFrame][currentLine] = nil
		end
		currentLine = currentLine + 1
		currentCharacter = currentCharacter + charsPerLine*3
	end
	file.close()
	return bimg
end
return m