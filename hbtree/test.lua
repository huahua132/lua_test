local hbtree = require "hbtree.hbtree"
math.randomseed(tonumber(tostring(math.floor(os.time() * 100)):reverse():sub(1, 10)))

local nums = {3,2,1,4,5,6,7,10,8,9,23,56,82,11,13,11,13,145,13,23,4,34,23,52,41,42,48,45,40}

local tree = hbtree:new()

for _,num in ipairs(nums) do
	tree:add_node(num,num * 100)
	tree:add_node(num,num * 100)
	--print(tree:print_tree_helper())
    local isok,err = pcall(tree.check, tree)
	if not isok then
		print(tree:print_tree_helper())
		error(err)
	end
end

local pre_time = os.time()
for i = 1,10000 do
	if i % 1000 == 0 then
		print(i)
	end
	local num = math.random(1,10000)
	tree:add_node(num,num)
	local isok,err = pcall(tree.check, tree)
	if not isok then
		print(tree:print_tree_helper())
		error(err)
	end
end
print(tree:print_tree_helper())