n = 3
for i = 1, n do
	local left = (i + n - 2) % n + 1
	local right = i % n + 1
	print(string.format("i: %d, l: %d, r: %d", i, left, right))
end


