local setmetatable = setmetatable
local table = table
local ipairs = ipairs

local function new_node(val)
	return {
		left = nil,
		right = nil,
		depth = 1,
		value = val,
	}
end

local function get_depth(node)
	if not node then
		return 0
	end
	return node.depth
end

local function update_depth(node)
	local l_depth = get_depth(node.left)
	local r_depth = get_depth(node.right)
	node.depth = l_depth > r_depth and l_depth + 1 or r_depth + 1
end

local function get_node_balance(node)
	local l_depth = get_depth(node.left)
	local r_depth = get_depth(node.right)
	return l_depth - r_depth
end

local function rr_rotate(parent,node)
	local son = node.left
	if parent.root then
		parent.root = son
	elseif parent.left == node then
		parent.left = son
	else
		parent.right = son
	end
	local son_r = son.right
	node.left.right = node
	node.left = son_r
	update_depth(node)
	update_depth(son)
end

local function ll_rotate(parent,node)
	local son = node.right
	if parent.root then
		parent.root = son
	elseif parent.left == node then
		parent.left = son
	else
		parent.right = son
	end
	local son_l = son.left
	node.right.left = node
	node.right = son_l
	update_depth(node)
	update_depth(son)
end

local function lr_rotate(parent,node)
	ll_rotate(node,node.left)
	rr_rotate(parent,node)
end

local function rl_rotate(parent,node)
	rr_rotate(node,node.right)
	ll_rotate(parent,node)
end

local function balance_left(parent,node)
	local l_balance = get_node_balance(node.left)
	if l_balance > 0 then
		rr_rotate(parent,node)
	else
		lr_rotate(parent,node)
	end
end

local function balance_right(parent,node)
	local r_balance = get_node_balance(node.right)
	if r_balance > 0 then
		rl_rotate(parent,node)
	else
		ll_rotate(parent,node)
	end
end

local function avl_node(parent,node)
	local balance = get_node_balance(node)
	if balance > 1 then
		balance_left(parent,node)
	elseif balance < -1 then
		balance_right(parent,node)
	end
end

local function add_node(parent,node,val)
	local res = false
	if node.value == val then
		return res
	end
	
	if node.value > val then
		if node.left then
			res = add_node(node,node.left,val)
		else
			node.left = new_node(val)
			res = true
		end
	else
		if node.right then
			res = add_node(node,node.right,val)
		else
			node.right = new_node(val)
			res = true
		end
	end

	if res then
		update_depth(node)
		avl_node(parent,node)
	end
	return res
end

local function find_node(node,val)
	if node.value == val then
		return node.value
	end

	if node.value > val then
		if node.left then
			return find_node(node.left,val)
		end
	else
		if node.right then
			return find_node(node.right,val)
		end
	end

	return nil
end

local function del_node(parent,node,val)
	local function del(p,n,next)
		if p.root then
			if next then
				p.root = next
			else
				p.root = nil
			end	
		elseif p.left == n then
			if next then
				p.left = next
			else
				p.left = nil
			end
		else
			if next then
				p.right = next
			else
				p.right = nil
			end
		end
	end
	local res = false
	if node.value == val then
		if not node.left and not node.right then
			del(parent,node)
		elseif not node.left then
			del(parent,node,node.right)
			node.right = nil
		elseif not node.right then
			del(parent,node,node.left)
			node.left = nil
		else
			--找node在中序遍历的前继节点或者后继节点
			--我这里找前继,前继结点是左节点或者左节点的最右节点
			local pp_node = nil
			local pre_node = node.left
			while pre_node.right do
				pp_node = pre_node
				pre_node = pre_node.right
			end
			del(parent,node,pre_node)
			pre_node.right = node.right
			node.right = nil
			if pp_node then
				pp_node.right = pre_node.left
				pre_node.left = node.left
			end
			
			node.left = nil

			local uplist = {pre_node}
			local unode = pre_node.left
			while unode do
				table.insert(uplist,unode)
				unode = unode.right
			end
			for i = #uplist,1,-1 do
				update_depth(uplist[i])
			end
		end
		return true
	end
	
	if node.value > val then
		if node.left then
			res = del_node(node,node.left,val)
		end
	else
		if node.right then
			res = del_node(node,node.right,val)
		end
	end

	if res then
		update_depth(node)
		avl_node(parent,node)
	end

	return res
end

local function tree_to_lists(node,nodes_list,level)
	if not node then
		return
	end

	if not nodes_list[level] then
		nodes_list[level] = {}
	end
	table.insert(nodes_list[level],node.value)
	if node.left then
		tree_to_lists(node.left,nodes_list,level + 1)
	end

	if node.right then
		tree_to_lists(node.right,nodes_list,level + 1)
	end
end

local M = {}

function M:new()
	local t = {
		root = nil,
		len = 0
	}
	setmetatable(t,{__index = self})
	return t
end

function M:add_node(val)
	local res = true
	if not self.root then
		self.root = new_node(val)
	else
		res = add_node(self,self.root,val)
	end
	if res then
		self.len = self.len + 1
	end
	return res
end

function M:del_node(val)
	if not self.root then
		return false
	end
	local res = del_node(self,self.root,val)
	if res then
		self.len = self.len - 1
	end

	return res
end

function M:find_node(val)
	return find_node(self.root,val)
end

function M:printf_tree()
	local nodes_list = {}
	tree_to_lists(self.root,nodes_list,1)
	local str = ""

	local len = #nodes_list
	for i,list in ipairs(nodes_list) do
		local n = len - i + 1
		for j = 1,n do
			str = str .. "    "
		end

		for _,num in ipairs(list) do
			str = str .. num .. "   "
		end

		str = str .. '\n'
	end
	str = str .. 'len = ' .. self.len
	return str
end

return M