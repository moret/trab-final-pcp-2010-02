require("alua")

function printMatrix(n, m, matrix, matrixName)
	io.write(matrixName)
	for j = 1, n do
		io.write(string.format("%5d  ", j))
	end
	print()
	for i = 1, n do
		io.write(i .. ":  ")
		for j = 1, m do
			io.write(string.format("%5d, ", matrix[i][j]))
		end
		print()
	end
end

function treeOutput(root, low, high)
	print("tree: " .. low .. " - " .. high .. "; root: " .. root[low][high + 1])
	if low < root[low][high + 1] - 1 then
		treeOutput(root, low, root[low][high + 1] - 1)
	end
	if root[low][high + 1] < high - 1 then
		treeOutput(root, root[low][high + 1] + 1, high)
	end
end

function printResult(msg)
	--printMatrix(n + 1, n + 1, msg.data.cost, "cost")
	--print()
	--printMatrix(n + 1, n + 1, msg.data.root, "root")
	treeOutput(msg.data.root, 1, n)
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

