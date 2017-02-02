Inventory = {}
Inventory.__index = Inventory


local default = {
	["cobble"] = true,
	["gravel"] = true,
	["dirt"] = true,
	["sand"] = true,
	["andesite"] = true,
	["diorite"] = true,
	["granite"] = true,
	["limestone"] = true
}

function Inventory.new(bot)
	function Inventory:__call(item, state)
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
	local self = setmetatable( { droppable = default, obj = bot }, Inventory)
	return self
end
function Inventory:add(item, state)
	self.droppable[item] = state
end

function Inventory:remove(item)
	self.droppable[item] = false
end

function Inventory:getState(item)
	return self.droppable[item]
end

function Inventory:setState(item, state)
	if item == "ALL" then
		for k,v in pairs(self.droppable) do
			self.droppable[k] = state
		end
	else
		self.droppable[k] = state
	end

end

function Inventory:deposit()
	if self.obj.selectItem("ender") then
		self.obj.place[1]()
		local chest = EnderChest.new(self.obj.wrap('top'), self.obj)
		self.obj.dig(1,0)
	end
end

function Inventory:__tostring()
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


