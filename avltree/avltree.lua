local setmetatable = setmetatable
local table = table
local ipairs = ipairs
local string = string
local print = print
local tostring = tostring
local assert = assert

local function new_node(k,v)
	return {
		left = nil,
		right = nil,
		depth = 1,
		k = k,
		v = v,
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

local function add_node(parent,node,k,v)
	if node.k == k then
		return
	end
	
	local res = nil
	if node.k > k then
		if node.left then
			res = add_node(node,node.left,k,v)
		else
			node.left = new_node(k,v)
			res = true
		end
	else
		if node.right then
			res = add_node(node,node.right,k,v)
		else
			node.right = new_node(k,v)
			res = true
		end
	end

	update_depth(node)
	avl_node(parent,node)

	return res
end

local function find_node(node,k)
	if node.k == k then
		return node.v
	end

	if node.k > k then
		if node.left then
			return find_node(node.left,k)
		end
	else
		if node.right then
			return find_node(node.right,k)
		end
	end

	return nil
end

local function del_node(parent,node,k,v)
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
	if node.k == k then
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
	
	if node.k > k then
		if node.left then
			res = del_node(node,node.left,k,v)
		end
	else
		if node.right then
			res = del_node(node,node.right,k,v)
		end
	end

	if res then
		update_depth(node)
		avl_node(parent,node)
	end

	return res
end

local function find_by_range(node,b_key,e_key,res_list)
	if not node then return end

	if node.left and b_key < node.k then
		find_by_range(node.left,b_key,e_key,res_list)
	end

	if node.k >= b_key and node.k <= e_key then
		table.insert(res_list,node.k)
		table.insert(res_list,node.v)
	end 
	
	if node.right and e_key > node.k then
		find_by_range(node.right,b_key,e_key,res_list)
	end
end

local function print_tree_helper(node,level,branch)
	if node == nil then
        return nil
    end
	local str = ""
    local r_str = print_tree_helper(node.right, level + 1, "/")
	if r_str then
		str = r_str
	end
    local indent = string.rep(" ", 4 * level)
	str = str .. indent .. branch .. tostring(node.k) .. '\n'

    local l_str = print_tree_helper(node.left, level + 1, "\\")
	if l_str then
		str = str .. l_str
	end
	return str
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

function M:add_node(k,v)
	local res = true
	if not self.root then
		self.root = new_node(k,v)
	else
		res = add_node(self,self.root,k,v)
	end
	if res then
		self.len = self.len + 1
	end
	return res
end

function M:del_node(k)
	if not self.root then
		return false
	end
	local res = del_node(self,self.root,k)
	if res then
		self.len = self.len - 1
	end

	return res
end

function M:find_node(k)
	return find_node(self.root,k)
end

function M:length()
	return self.len
end

function M:find_by_range(bk,ek)
	assert(bk < ek)
	local ret_list = {}
	find_by_range(self.root,bk,ek,ret_list)
	return ret_list
end

function M:print_tree_helper()
	return print_tree_helper(self.root,0,"")
end

return M