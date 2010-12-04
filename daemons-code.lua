function listNetwork()
	for i, daemon in pairs(alua.getdaemons()) do
		print(i, daemon)
	end
end

function shareCode(code)
	for i, daemon in pairs(alua.getdaemons()) do
		if not (daemon == alua.id) then
			alua.send(daemon, code)
		end
	end
end

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
	print("tree: " .. low .. " - " .. high .. "; root: " .. root[low][high + 1] .. "\n")
	if low < root[low][high + 1] - 1 then
		treeOutput(root, low, root[low][high + 1] - 1)
	end
	if root[low][high + 1] < high - 1 then
		treeOutput(root, root[low][high + 1] + 1, high)
	end
end

function searchTree(msg)
	local n = msg.data.n
	local p = msg.data.p
	
	local cost = {}
	local root = {}

	for i = 1, n + 1 do
		cost[i] = {}
		root[i] = {}
		for j = 1, n + 1 do
			cost[i][j] = 0
			root[i][j] = 0
		end
	end

	for low = n + 1, 1, -1 do
		cost[low][low] = 0
		root[low][low] = low
	
		for high = low + 1, n + 1 do
			bestcost = 10000000000
			tempCost = 0
		
			for j = low, high - 1 do
				tempCost = tempCost + p[j]
			end
		
			for r = low, high - 1 do
				rcost = tempCost + cost[low][r] + cost[r + 1][high]
			
				if rcost < bestcost then
					bestcost = rcost
					bestroot = r
				end
			end
		
			cost[low][high] = bestcost
			root[low][high] = bestroot
		end
	end

	--printMatrix(n + 1, n + 1, cost, "cost")
	--print()
	--printMatrix(n + 1, n + 1, root, "root")

	treeOutput(root, 1, n)
end

function searchTreePart(msg)
	
end

print(alua.id .. " got code!")
listNetwork()

alua.reg_event("searchTree", searchTree)
alua.reg_event("searchTreePart", searchTreePart)

