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

print(alua.id .. " got code!")
listNetwork()

