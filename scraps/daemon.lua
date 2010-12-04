require("alua")

if not #arg == 2 then
	error("Bad number of arguments. Syntax: lua daemon.lua <local-bind-address> <local-bind-port>")
end

localAddress = arg[1]
localPort = arg[2]

alua.create(localAddress, localPort)
print("daemon created " .. alua.id)
alua.loop()
alua.quit()

