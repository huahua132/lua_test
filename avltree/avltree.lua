local function new_node()
	return {
		left = nil,
		right = nil,
		depth = 0,
		value = nil,
	}
end

local M = {}

return M