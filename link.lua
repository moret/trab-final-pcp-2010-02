require("alua")

function connectCB(reply)
	print("connected to " .. reply.id)
	alua.link(ids)
	alua.send(alua.daemonid, code)
	alua.send(alua.daemonid, "shareCode(\[\[" .. code .. "\]\])") -- couldn't make an event with a multiline string as an argument
	alua.send_event(alua.daemonid, "searchTree", startData) -- same here, couldn't just send the file, had to open it and send the data as an integer table
	alua.quit()
end

if not (#arg == 3) then
	error("Bad number of arguments. Syntax: lua link.lua <daemons-list-file> <daemons-code-file> <table>")
end

ids = dofile(arg[1])
code = io.open(arg[2], 'r'):read("*all")
inputFile = io.open(arg[3], 'r')

startData = {}
startData.p = {}

startData.n = inputFile:read("*number")
for i = 1, startData.n do
	startData.p[i] = inputFile:read("*number")
end

-- Connect to first daemon on the list
local ip, port = string.match(ids[1], "^(.*):(%d*)/0$")
alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

