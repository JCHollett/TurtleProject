local install = function()
	io.write("Installing Data ") io.write(". . . . .\n")
	os.sleep(0.25)
	fs.delete("data/")
	fs.delete("startup")
	fs.copy("disk/lib", "data")
	fs.copy("disk/boot.lua", "startup")
	io.write("Installed ") io.write(". . . . .\n")
	os.sleep(0.25)
	if not os.getComputerLabel() then
		io.write("This machine has no label. \nPlease enter a label: ")
		local label = io.read()
		os.setComputerLabel(label)
		io.write("Label accepted: " .. os.getComputerLabel()) io.write(". . . . .\n")
		os.sleep(0.25)
	end

	io.write("Restarting for changes to take affect.\n") io.write(". . . . .\n")
	os.sleep(0.25)
	os.reboot()
end

if version then
	install()
else
	io.write("No updates to install") io.write(". . . . .\n")
	os.sleep(0.25)
end