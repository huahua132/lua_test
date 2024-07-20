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
		k = k,
		v = v,
        is_red = true,
	}
end

--获取叔结点
local function get_unode(g,parent)
    local u = nil  --叔
    local is_right = false
    if g.left == parent then
        u = g.right
        is_right = true
    else
        u = g.left
    end
    return u, is_right
end

local function swap_node(root, n1, n2)
    if root.left == n1 then
        root.left = n2
    elseif root.right == n1 then
        root.right = n2
    elseif root.root == n1 then
        root.root = n2
    else
        assert(1 == 2)
    end
end

local avl_node

local function ll_rotate(gg,g,parent)
    swap_node(gg,g,parent)
    local pleft = parent.left
    parent.left = g
    g.right = pleft
    parent.is_red = false
    g.is_red = true
end

local function rr_rotate(gg,g,parent)
    swap_node(gg,g,parent)
    local pright = parent.right
    parent.right = g
    g.left = pright
    parent.is_red = false
    g.is_red = true

end

local function rl_rotate(gg,g,parent)
    rr_rotate(g,parent,parent.left)
    return ll_rotate(gg,g,g.right)
end

local function lr_rotate(gg,g,parent)
    ll_rotate(g,parent,parent.right)
    return rr_rotate(gg,g,g.left)
end

avl_node = function(gg,g,parent)
    if not gg then return end                   --没有gg p就是跟结点了，根结点不可能需要调整 
    if g.root then return end
  
    local u, uright = get_unode(g,parent)
    if not u or not u.is_red then               --u 是黑色
        if g.right == parent then
            if parent.right ~= nil and parent.right.is_red then         --RR型 左旋
                return ll_rotate(gg,g,parent)
            else                                --RL型 先右旋再左旋
                return rl_rotate(gg,g,parent)
            end
        else
            if parent.left ~= nil and parent.left.is_red then          --LL型 右旋
                return rr_rotate(gg,g,parent)
            else                                --LR型 先左旋再右旋
                return lr_rotate(gg,g,parent)
            end
        end
    else                                        --u 是红色
        parent.is_red = false
        u.is_red = false

        if gg.root then return end              --说明g是root结点 不用变色

        g.is_red = true

        if not gg.is_red then return end
         --p u g 变色  已g为cur 基点，继续调整
        return gg
    end
end

local function add_node(g,parent,node,k,v)
	if node.k == k then
		return
	end
	
    local new = nil
    local v_n = nil  --调整点
	if node.k > k then
		if node.left then
			new, v_n = add_node(parent,node,node.left,k,v)
		else
            new = new_node(k,v)
			node.left = new

            if node.is_red then                 --父结点是红色，打破不能连续2红特性，需要调整
                v_n = avl_node(g,parent,node)
            end
		end
	else
		if node.right then
			new, v_n = add_node(parent,node,node.right,k,v)
		else
            new = new_node(k,v)
			node.right = new

            if node.is_red then                 --父结点是红色，打破不能连续2红特性，需要调整
                v_n = avl_node(g,parent,node)
            end
		end
	end

    if v_n == node then
        v_n = avl_node(g,parent,node)
    end

    return new, v_n
end

local M = {}
local mata = {__index = M}

function M:new()
    local t = {
        root = nil,
        len = 0,
    }
    setmetatable(t, mata)

    return t
end

function M:add_node(k, v)
    local res = true
	if not self.root then
		self.root = new_node(k,v)
        self.root.is_red = false
	else
		res = add_node(nil,self,self.root,k,v)
	end
	if res then
		self.len = self.len + 1
	end
	return res
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
    local rb = 'R'
    if not node.is_red then
        rb = 'B'
    end
	str = str .. indent .. branch .. tostring(node.k) .. rb .. '\n'

    local l_str = print_tree_helper(node.left, level + 1, "\\")
	if l_str then
		str = str .. l_str
	end
	return str
end

function M:print_tree_helper()
	return print_tree_helper(self.root,0,"")
end

--[[
    1.每个节点要么是红色，要么是黑色

    2.根结点永远是黑色

    3.nil结点都是黑色

    4.红色结点不能连续

    5.黑色结点所有路径数量一致
]]
--检测是否满足红黑树特性
function M:check()
    local root = self.root
    if not root then return end

    assert(not root.is_red)     --特性2

    local check_queue = {root, 1}

    local depth_map = {}
    while #check_queue > 0 do
        local node = table.remove(check_queue, 1)
        local depth = table.remove(check_queue, 1)
        local left = node.left
        local right = node.right

        if node.is_red then
            assert(not left or not left.is_red)       --特性4
            assert(not right or not right.is_red)     --特性4
        end

        if left then
            table.insert(check_queue, left)
            if not left.is_red then
                table.insert(check_queue, depth + 1)       --黑色深度加1
            else
                table.insert(check_queue, depth)
            end
        end

        if right then
            table.insert(check_queue, right)
            if not right.is_red then
                table.insert(check_queue, depth + 1)       --黑色深度加1
            else
                table.insert(check_queue, depth)
            end
        end

        if not left or not right then              --叶节点记录深度
            depth_map[depth] = true
        end
    end

    local isok = false
    for depth in pairs(depth_map) do
        assert(not isok)                            --特性5
        isok = true
    end
end

return M