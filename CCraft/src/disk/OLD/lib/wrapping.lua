Devices = {
	['SENSOR'] = 'turtlesensorenvironment',
	['REACTOR'] = 'BigReactors-Reactor'
}
local Supported = {
	['turtlesensorenvironment'] = true,
	['BigReactors-Reactor'] = true
}
local Initialize = {
	['turtlesensorenvironment'] = function(Computer)
		Computer.scan = Scanner.new(Computer)
	end,
	['BigReactors-Reactor'] = function(Computer)
		Computer.reactor = Reactor.new(Computer)

	end
}
local outDir = {
	[2] = 1,
	[1] = 2,
	[4] = 3,
	[3] = 4,
	[6] = 5,
	[5] = 6
}
local inDir = {
	["DOWN"] = 1,
	["UP"] = 2,
	["NORTH"] = 3,
	["SOUTH"] = 4,
	["WEST"] = 5,
	["EAST"] = 6
}
local Surface = {
    ["back"] = 2,
    ["left"] = -1,
    ["front"] = 0,
    ["right"] = 1,
    ["top"] = "UP",
    ["bottom"] = "DOWN"
}


_In = function(x)
    if type(x) == "string" and not tonumber(Surface[x]) then
        return inDir[Surface[x]]
    else
        return inDir[cardinality[ (Surface[x] + this._CARDINAL) % 4 ]]
    end
end

_Out = function(x)
    if type(x) == "string" and not tonumber(Surface[x]) then
        return outDir[_In(x)]
    else
        return outDir[_In(x)]
    end
end

Wrap = { }
Wrap.__index = Wrap

--[[ Try this later
setmetatable(Wrap, {
	__call = function(cls, ...)
		return cls:open(...)
	end,
})
]]--

function Wrap.new(init)
	local self = setmetatable({ wrapped = {}, type = {}, last = nil}, Wrap)
	init.wrap = self
	for k,v in pairs(peripheral.getNames()) do
		local Type = peripheral.getType(v)
		if Supported[Type] and not self.wrapped[v] then
			self:open(v)
			Initialize[Type](init)
		end
	end
	return self
end

function Wrap:__call(param)
	if Surface[param] then
		return self:open(param)
	elseif Devices[param] then
		return self.wrapped[self.type[Devices[param]]] or self:open(Devices[param])
	else
		return self.wrapped[self.last]
	end
end

function Wrap:open(param)
	if Supported[param] then
		for k,v in pairs(peripheral.getNames()) do
			if Supported[peripheral.getType(v)] then
				self.wrapped[v] = peripheral.wrap(v)
				self.type[param] = v
				self.last = self.wrapped[v]
				break
			end
		end
	end
	param = param:lower()
    if peripheral.isPresent(param) then
		if not self.wrapped[param] then
			local device = peripheral.wrap(param)
			self.wrapped[param] = device
			self.type[peripheral.getType(param)] = param
			self.last = param
			return device
    	else
			return self.wrapped[param]
		end
	end
	return self.wrapped[self.last]
end

function Wrap:close(side)
	if self.wrapped[side] then
		self.type[peripheral.getType(side)] = nil
		self.wrapped[side] = nil
		return true
	else
		return false
	end
end

function Wrap:update()
	local Close = {}
	for k, v in pairs(self.wrapped) do
		if peripheral.getType(k) ~= Devices.SENSOR then
			Close[k] = true
		end
	end
	for k,v in pairs(Close) do
		self:close(k)
	end
end

