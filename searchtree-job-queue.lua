require("alua")

function printResult(msg)
	print(msg.data)
	alua.quit()
end

function connectCB(reply)
	print("connected to " .. reply.id)
	alua.reg_event("printResult", printResult)
	alua.send_event(alua.daemonid, "searchTree", {n = n, p = p})
end

if not (#arg == 3) then
	error("Bad number of arguments. Syntax: lua searchtree-job-queue.lua <daemons-ip> <daemons-port> <table>")
end

jobData = {}

-- Connect to the informed daemon
local ip = arg[1]
local port = arg[2]
pFile = io.open(arg[3], 'r')

p = {}
n = pFile:read("*number")

for i = 1, n do
	p[i] = pFile:read("*number")
end

alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

