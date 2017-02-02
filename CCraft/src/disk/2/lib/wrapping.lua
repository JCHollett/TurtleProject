Devices = {
	['SENSOR'] = 'turtlesensorenvironment',
	['REACTOR'] = 'BigReactors-Reactor',
	['CHEST'] = 'chest',
	['ENDER_CHEST'] = 'ender_chest'
}
local Supported = {
	['turtlesensorenvironment'] = true,
	['BigReactors-Reactor'] = true,
	['chest'] = true,
	['ender_chest'] = true
}
local Static = {
	['turtlesensorenvironment'] = true
}
local Initialize = {
	['turtlesensorenvironment'] = function(src, peripheral, side)
		src.scan = Scanner.new(src, peripheral, side)
		return src.scan
	end,
	['BigReactors-Reactor'] = function(src, peripheral, side)
		src.reactor = Reactor.new(src, peripheral, side)
		return src.reactor
	end,
	['chest'] = function(src, peripheral, side)
		return Chest.new(src, peripheral, side)
	end,
	['ender_chest'] = function(src, peripheral, side)
		return EnderChest.new(src, peripheral, side)
	end
}
local DeInitialize = {
	['BigReactors-Reactor'] = function(src)
		if src.reactor then
			src.reactor:Stop()
			src.reactor = nil
			return true
		else
			return false
		end
	end,
	['chest'] = function(src)
		return true
	end,
	['ender_chest'] = function(src)
		return true
	end
}




Wrap = { }
Wrap.__index = Wrap
function Wrap.new(this)
	local Source = this
	local self = setmetatable({ wrapped = {}, static = {}, type = {}, last = nil, lastDir = nil, blocked = {}}, Wrap)
	function self:open(param)
		if Supported[param] then
			--[[THIS IS A DEVICE]]--
			if Static[param] then
				if self.type[param] then
					return self.static[self.type[param]]
				else 
					for k,v in pairs(peripheral.getNames()) do
						if peripheral.getType(v) == param then
							self.static[v] = Initialize[param](Source, peripheral.wrap(v), v)
							self.blocked[v] = true
							self.type[param] = v
							self.last = self.static[v]
							self.lastDir = v
							return self.last
						end
					end
				end
			else
				--[[NOT STATIC]]--
				if self.type[param] then
					if self.blocked[self.type[param]] then
						--[[BLOCKED, FIND ANOTHER CHEST?]]
						for k,v in pairs(peripheral.getNames()) do
							if peripheral.getType(v) == param then
								if self.wrapped[v] then
									--[[ALREADY WRAPPED]]--
									self.type[param] = v
									return self.wrapped[v]
								else
									--[[NOT WRAPPED]]--
									self.wrapped[v] = Initialize[param](Source, peripheral.wrap(v), v)
									self.type[param] = v
									self.last = self.wrapped[v]
									self.lastDir = v
									return self.last
								end							
							end
						end
						print("Blocked ", self.type[param])
						return
					else
						--[[NOT BLOCKED]]--
						return self.wrapped[self.type[param]]
					end
				else
					--[[NOT WRAPPED]]--
					for k,v in pairs(peripheral.getNames()) do 
						if not self.blocked[v] and peripheral.getType(v) == param then
							self.wrapped[v] = Initialize[param](Source, peripheral.wrap(v), v)
							self.type[param] = v
							self.last = self.wrapped[v]
							self.lastDir = v
							return self.last
						end
					end
				end
			end
		end
		param = param:lower()
		if peripheral.isPresent(param) then
			--[[THIS IS A SURFACE]]--
			local Type = peripheral.getType(param)
			if not Supported[Type] then
				print("Unsupported: ", Type)
				return
			end
			if Static[Type] then
				if self.static[param] then
					return self.static[param]
				else
					--[[NOT WRAPPED]]--
					self.blocked[param] = true
					self.static[param] = Initialize[Type](Source, peripheral.wrap(param), param)
					self.type[Type] = param
					self.last = self.static[param]
					self.lastDir = param
					return self.last
				end
			else
				--[[NOT STATIC DEVICE]]--
				if self.blocked[param] then
					print("Blocked: ", param)
				else
					--[[NOT BLOCKED]]--
					if self.wrapped[param] then
						return self.wrapped[param]
					else
						--[[NOT WRAPPED]]--
						self.wrapped[param] = Initialize[Type](Source, peripheral.wrap(param), param)
						self.type[Type] = param
						self.last = self.wrapped[param]
						self.lastDir = param
						return self.last					
					end
				end
			end
		end
	end
	
	function self:close(side)
		if self.wrapped[side] then
			self.type[self.wrapped[side].type] = nil
			self.wrapped[side] = nil
			return true
		else
			return false
		end
	end
	
	function self:update()
		local Close = {}
		for k, v in pairs(self.wrapped) do
			local lambda = DeInitialize[peripheral.getType(k)]
			if lambda then
				Close[k] = lambda(Source)
			end
		end
		for k, v in pairs(Close) do	
			self:close(k)
		end
	end
	function self:turning(t)
		local wrapped = {}
		for k,v in pairs(self.wrapped) do
			v.side = t[k]
			wrapped[v.side] = v
			v:rewrap()
		end
		self.wrapped = wrapped
		for k,v in pairs(self.type) do
			if not Static[k] then
				self.type[k] = t[v]
			end
		end
		self.lastDir = self.last.side
	end
	for k,v in pairs(peripheral.getNames()) do
		local Type = peripheral.getType(v)
		if Supported[Type] and not self.wrapped[v] then
			self:open(v)
		end
	end
	return self
end


function Wrap:__call(param)
	if Geometrics.Surface[param] then
		return self:open(param)
	elseif Devices[param] or Supported[param] then
		return self.wrapped[self.type[Devices[param] or param]] or self:open(Devices[param] or param)
	else
		if not self.blocked[self.lastDir] then
			return self.last
		else
			print("Blocked: ", self.lastDir)
		end
	end
end
