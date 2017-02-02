Reactor = { }
Reactor.__index = Reactor

function Reactor.new(peripheral)
	local self = setmetatable({ Port = peripheral, Running = false , MaxEnergy = 10000000 }, Reactor)
	return self
end


function Reactor:Run()
	self.Running = true
	local process = function()
		x,y = term.getCursorPos()
		for i = 0,2 do
			term.setCursorPos(1,y-i)
			term.clearLine()
		end
		io.write('lua> ')
		while self.Running do
			if not self.Port.getActive() then
				self.Port.setActive(true)
			end
			self.Port.setAllControlRodLevels(self.Port.getEnergyStored() / self.MaxEnergy * 100)
			os.sleep(1)
		end
		self.Port.setActive(false)
	end
	local shell = function()
		shell.run('lua')
	end
	parallel.waitForAny(shell, process)
	term.setCursorPos(1 , ({term.getCursorPos()})[2])
end
function Reactor:Stop()
	self.Running = false
end
