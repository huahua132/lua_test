local avltree = require "avltree.avltree"
math.randomseed(tonumber(tostring(math.floor(os.time() * 100)):reverse():sub(1, 10)))
local tree = avltree:new()

local nums = {3,2,1,4,5,6,7,10,8,9,23,56,82,11,13,11,13,145,13,23,4,34,23,52,41,42,48,45,40}

print(collectgarbage("count"))
collectgarbage("collect")
print(collectgarbage("count"))
for _,num in ipairs(nums) do
	tree:add_node(num,num * 100)
	tree:add_node(num,num * 100)
	--print(tree:printf_tree(),#nums)
end
local t = tree:find_by_range(8,50)
for i,v in ipairs(t) do
	print(i,v)
end
print(tree:print_tree_helper())
print("len :", tree:length())
for _,num in ipairs(nums) do
	tree:del_node(num)
	tree:del_node(num)
end
print(tree:print_tree_helper())
print("len2 :",tree:length())
print(collectgarbage("count"))
collectgarbage("collect")
print(collectgarbage("count"))

local pre_time = os.time()
for i = 1,1000000 do
	local num = math.random(1,100000)
	tree:add_node(num,num)
end

print(collectgarbage("count"))

for i = 1,1000000 do
	local num = math.random(1,100000)
	tree:add_node(num,num)
	num = math.random(1,100000)
	tree:del_node(num)
end

for i = 1,1000000 do
	local num = math.random(1,100000)
	tree:del_node(num)
end

print("use time = ",os.time() - pre_time)
print(tree:print_tree_helper())

print(collectgarbage("count"))
collectgarbage("collect")
print(collectgarbage("count"))
collectgarbage("collect")
print(collectgarbage("count"))
