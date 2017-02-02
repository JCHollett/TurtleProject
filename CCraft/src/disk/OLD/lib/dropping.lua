Drop = {}
Drop.__index = Drop

local default = {
    ["cobble"] = false,
    ["gravel"] = false,
    ["dirt"] = false,
    ["sand"] = false,
    ["andesite"] = false,
    ["diorite"] = false,
    ["granite"] = false,
    ["limestone"] = false
}

function Drop.new(init)
	function Drop:__call(item, state)
		if not state then
			if self:getState(item) then
				self.action.up();
			end
		else
			if state == nil then
				self:remove(item)
			elseif item == 'ALL' then
				self:setState(item,state)
			else
				self:add(item,state)
			end
		end
	end
	local self = setmetatable( { droppable = default , action = init }, Drop)
	return self
end
function Drop:add(item, state)
	self[item] = state
end

function Drop:remove(item)
	self[item] = nil
end

function Drop:getState(item)
	return self.droppable[item]
end

function Drop:setState(item, state)
	if item == "ALL" then
		for k,v in pairs(self.droppable) do
			self[k] = state
		end
	else
		self[k] = state
	end

end

function Drop:__newindex(k, state)
	rawset(self.droppable, k, state)
end

function Drop:__tostring()
	local str = "{\n"
	local sep = nil
	for k, v in pairs(self.droppable) do
		if v then
			if sep then
				str = str .. sep .. "\n   " .. tostring(k) .. " = " .. tostring(v)
			else
				str = str .. "   " .. tostring(k) .. " = " .. tostring(v)
				sep = ", "
			end
		end
	end
	str = str .. "\n}"
	return str
end

