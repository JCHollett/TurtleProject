Inventory = {}
Inventory.__index = Inventory


local depositables = {
	["minecraft:cobblestone"] = true,
	["minecraft:gravel"] = true,
	["minecraft:dirt"] = true,
	["minecraft:sand"] = true,
	["chisel:andesite"] = true,
	["chisel:diorite"] = true,
	["chisel:granite"] = true,
	["chisel:limestone"] = true,
	["minecraft:gold_ore"] = true,
	["minecraft:iron_ore"] = true,
	["minecraft:coal_ore"] = true,
	["minecraft:diamond_ore"] = true,
	["minecraft:redstone_ore"] = true,
	["minecraft:emerald_ore"] = true,
	["BigReactors:YelloriteOre"] = true,
	["ThermalFoundation:Ore"] = true,
	["ProjRed|Exploration:projectred.exploration.ore"] = true,
	["appliedenergistics2:tile.OreQuartz"] = true,
	["appliedenergistics2:tile.OreQuartzCharged"] = true,
	["appliedenergistics2:tileOreQuartz"] = true,
	["ImmersiveEngineering:ore"] = true,
	["minecraft:coal"] = true,
	["minecraft:coal_block"] = true,
	["minecraft:flint"] = true
}
local stockables = {

}
local deposit = 0xfff
local storage = 0x111
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
	local self = setmetatable( { depositable = depositables, stockable = stockables, obj = bot }, Inventory)
	return self
end
function Inventory:addFilter(item, state)
	self.droppable[item] = state
end

function Inventory:removeFilter(item)
	self.droppable[item] = false
end

function Inventory:isDepositable(item)
	return true
	--return item and self.depositable[item]
end
function Inventory:isStockable(item)
	return item and self.stockable[item]
end

function Inventory:setState(item, state)
	if item == "ALL" then
		for k,v in pairs(self.depositable) do
			self.depositable[k] = state
		end
	else
		self.depositable[item] = state
	end

end

function Inventory:deposit()
	if self.obj.selectItem("ender") then
		local slot = self.obj.getSlot()
		self.obj.place[1]()
		local chest = self.obj.wrap(Devices.ENDER_CHEST)
		chest:setChannel(deposit)
		local Item = false;
		for i=1,16 do 
			Item = self.obj.getInfo(i)
			if Item and self:isDepositable(Item.name) then
				chest:insert(i)
			end
		end
		self.obj.select(slot)
		self.obj.dig(1,0)
	end
end
function Inventory:put() 
	if self.obj.selectItem("ender") then
		self.slot = self.obj.getSlot()
		self.obj.place[1]()
		local chest = self.obj.wrap(Devices.ENDER_CHEST)
		chest:setChannel(storage)
		return chest
	else
		return false
	end
end
function Inventory:take()
	if self.slot then
		self.obj.select(self.slot)
		self.obj.dig(1,0)
		self.slot = nil
	else
		return false
	end
end

function Inventory:__tostring()
	local str = "{\n"
	local sep = nil
	for k, v in pairs(self.depositable) do
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


