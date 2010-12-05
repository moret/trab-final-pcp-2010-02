require("alua")
require("posix")

function connectCB(reply)
	print("connected to " .. reply.id)
	if __debug then alua.send(alua.daemonid, "__debug = true") end
	alua.send(alua.daemonid, code)
	alua.quit()
end

if not #arg == 3 then
	error("Bad number of arguments. Syntax: lua daemon-run-job-queue.lua <local-bind-address> <local-bind-port> <daemon-lua-code>")
end

ip = arg[1]
port = arg[2]
code = io.open(arg[3], 'r'):read("*all")

local pid = posix.fork()

if pid == 0 then -- Child process
	alua.connect(ip, port, connectCB)
	alua.loop()
	alua.quit()
else -- Father process
	alua.create(ip, port)
	print("daemon created " .. alua.id)
	alua.loop()
	alua.quit()
end

