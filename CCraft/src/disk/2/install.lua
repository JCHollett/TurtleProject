local install = function()
	io.write("Installing Data ") textutils.slowWrite(". . . . .\n",80)
	fs.delete("data/")
	fs.delete("startup")
	fs.copy("disk/lib", "data")
	fs.copy("disk/boot.lua", "startup")
	io.write("Installed ") textutils.slowWrite(". . . . .\n",80)

	if not os.getComputerLabel() then
		io.write("This machine has no label. \nPlease enter a label: ")
		local label = io.read()
		os.setComputerLabel(label)
		io.write("Label accepted: " .. os.getComputerLabel()) textutils.slowWrite(". . . . .\n",80)
	end

	io.write("Restarting for changes to take affect.\n") textutils.slowWrite(". . . . .\n",80)
	os.reboot()
end

if version then
	install()
else
	io.write("No updates to install") textutils.slowWrite(". . . . .\n",80)
end