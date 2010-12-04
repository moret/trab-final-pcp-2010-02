require("alua")

function connectCB(reply)
	print("connected to " .. reply.id)
	alua.link(ids)
	alua.send(alua.daemonid, daemonsCode)
	alua.send(alua.daemonid, "shareCode(\[\[" .. daemonsCode .. "\]\])")
	alua.quit()
end

if not (#arg == 2) then
	error("Bad number of arguments. Syntax: lua link.lua <daemons-list-file> <daemons-code-file>")
end

ids = dofile(arg[1])
daemonsCode = io.open(arg[2], 'r'):read("*all")

-- Connect to first daemon on the list
local ip, port = string.match(ids[1], "^(.*):(%d*)/0$")
alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

