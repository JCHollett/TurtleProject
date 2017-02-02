shell.run('/data/reactors.lua')
shell.run('/data/wrapping.lua')

local Computer = {}
Computer.__index = Computer

function Computer.new()
	local self = setmetatable({}, Computer)
	return self
end

local this = Computer.new()
Wrap.new(this)

Cmp = this