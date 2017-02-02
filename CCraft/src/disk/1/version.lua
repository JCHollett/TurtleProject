local localPath = "/data"
local diskPath = "/disk/lib"
local compare = nil

compare = function(path)
	for x, y in pairs(fs.list(diskPath .. path)) do
		if fs.isDir(diskPath .. path .. y) then
			if compare(path .. y .. "/") then
				return true
			end
		else
			if not fs.exists(localPath .. path .. y) then
				return true
			end
			if fs.getSize(localPath .. path .. y) ~= fs.getSize(diskPath .. path .. y) then
				return true
			end
		end
	end
	return false
end


version = compare("/")
