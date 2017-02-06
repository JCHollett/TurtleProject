Chest = {type = 'chest'}
Chest.__index = Chest

local CASES = {}
CASES.insert = {
	[0] = function(this)
		return this.chestObj.pullItem(this.obj.geo:Out(this.side),this.obj.getSlot())
		--[[Inserts whatever is selected currently]]--
	end,
	[1] = function(this,args)
		return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1])
		--[[Inserts from a slot into the chest]]--
	end,
	[2] = function(this,args)
		return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1], args[2])
		--[[Inserts from a slot into the chest by a certain amount]]--
	end,
	[3] = function(this,args)
		return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1], args[2], args[3])
		--[[Inserts from a slot to a slot in the chest by some amount]]--
	end
}
CASES.remove = {
	[0] = function(this)
		local ItemStack = this.chestObj.getAllStacks()
		local amnt = 0;
		for i=1,this.chestObj.getInventorySize() do
			
			if this.obj.getCapacity() == 0 then
				return amnt
			end
			if ItemStack[i] then
				amnt = amnt + this.chestObj.pushItem(this.obj.geo:Out(this.side), i, 64, this.obj.getSlot())
			end
		end
		return amnt
		--[[Removes the first item it can from the slot of the chest in order]]--
	end,
	[1] = function(this,args)
		return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], 64, this.obj.getSlot())
		--[[Removes all of item from the slot of a chest]]--
	end,
	[2] = function(this,args)
		return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], args[2], this.obj.getSlot())
		--[[Removes a certain amount of an item from the slot of the chest]]--
	end,
	[3] = function(this,args)
		return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], args[2], args[3])
		--[[Removes a certain amount of an item from the slot of the chest into a slot of the turtle]]--
	end
}
CASES.get = {
	[0] = function(this)
		--[[Get nothing lul]]--
		error("no args")
		return nil
	end,
	[1] = function(this,args)
		--[[Get all of an item z]]--
		for k,v in pairs(CASES.find[1](this,args)) do 
			if CASES.remove[1](this, {k}) > 0 then
				return true
			end
		end
		return false
	end,
	[2] = function(this,args)
		--[[Get x amount of an item z]]--
		for k,v in pairs(CASES.find[1](this, {args[1]})) do 
			if CASES.remove[2](this, {k, args[2]}) > 0 then
				return true
			end
		end
		return false		
	end,
	[3] = function(this,args)
		--[[Get x amount of an item z and insert it into a slot y]]--
		for k,v in pairs(CASES.find[1](this,{args[1]})) do
		 
			if CASES.remove[3](this, {k, args[2], args[3]}) > 0 then
				return true
			end
		end
		return false
	end
}
CASES.find = {
	[0] = function(this)
		--[[Error: No args]]
		error("no args")
		return nil
	end,
	[1] = function(this,args)
		--[[Find an item z]]--
		args[2] = 1
		return CASES.find[2](this,args)
	end,
	[2] = function(this,args)
		--[[Find an item z starting from slot x]]--
		args[3] = this.chestObj.getInventorySize()
		return CASES.find[3](this,args)
	end,
	[3] = function(this,args)
		--[[Find an item z starting from slot x and ending at slot y]]--
		local Item = false
		local Found = {}
		local Count = 0
		if type(args[1]) == 'table' then
			local Items = this.chestObj.getAllStacks()
			for k,v in pairs(Items) do
				if k >= args[2] and k <= args[3] then
					Item = v.all()
					Count = Count + 1
					for a,b in pairs(args[1]) do
						if Item[a] == b then
							Found[k] = Item
						else
							Found[k] = nil
							Count = Count - 1
							break
						end
					end
				end
			end
			return (Count > 0 and Found) or nil
		else
			args[1] = args[1]:lower()
			local Items = this.chestObj.getAllStacks()
			for k,v in pairs(Items) do
				if k >= args[2] and k <= args[3] then
					Item = v.all()
					if Item.display_name:lower():find(args[1]) then	
						Found[k] = Item
						Count = Count + 1
					end
				end
			end
			return (Count > 0 and Found) or nil
		end
	end
}
CASES.hasItems = {
	[0] = function(this)
		return (next(this.chestObj.getAllStacks()) and true) or false
	end
}

function Chest.new(bot, wrapped, face)
	local Source = {chestObj = wrapped, obj = bot, side = face }
	local self = {side = face}
	function self:insert(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.insert[#pArgs](Source, pArgs)
		end			
	end
	
	function self:remove(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.remove[#pArgs](Source, pArgs)
		end
	end
	
	function self:get(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.get[#pArgs](Source, pArgs)
		end
	end
	
	function self:find(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.find[#pArgs](Source, pArgs)
		end
	end
	function self:hasItems(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.hasItems[#pArgs](Source, pArgs)
		end
	end
	function self:rewrap()
		if peripheral.getType(self.side) == self.type then
			Source.side = self.side
			Source.chestObj = peripheral.wrap(self.side)
		else
			Source.chestObj = nil
		end
	end
	return setmetatable(self, Chest)
end