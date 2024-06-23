package.path = '../?.lua;./?.lua' .. package.path

local function open(fileName,type)
	local handle
	if isComputerCraft then
		handle = fs.open(fileName,type)
	else
		handle = io.open(fileName,type)
	end
	return handle
end
local function write(handle,value)
	if isComputerCraft then
		return handle.write(value)
	else
		return handle:write(value)
	end
end
local function close(handle)
	if isComputerCraft then
		return handle.close()
	else
		return handle:close()
	end
end

local video = require("video")
local tinybimg = require("../tinybimg")
local file = open("video.tinybimg","w")
write(file,tinybimg:encode(video))
close(file)

tinybimg:decode("video.tinybimg")
