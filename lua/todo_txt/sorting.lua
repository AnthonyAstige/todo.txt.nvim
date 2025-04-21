local M = {}

local api = vim.api
local focus = require("todo_txt.focus")

--- Custom comparison function for sorting lines.
--- Prioritizes focused lines, then sorts alphabetically.
--- @param a string First line to compare.
--- @param b string Second line to compare.
--- @return boolean True if line 'a' should come before line 'b'.
local function compare_lines(a, b)
	local a_is_focused = focus.is_focused(a)
	local b_is_focused = focus.is_focused(b)

	if a_is_focused and not b_is_focused then
		return true -- Focused lines come first
	elseif not a_is_focused and b_is_focused then
		return false -- Unfocused lines come after focused lines
	else
		-- Both have the same focus status, sort alphabetically
		return a < b
	end
end

--- Sorts the lines in the current buffer based on focus and alphabetical order.
function M.sort_buffer()
	local buf = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

	-- Filter out empty lines before sorting, keep track of their original indices if needed
	-- For simplicity here, we'll just remove them and add them back at the end if necessary,
	-- or simply sort them along, they usually end up at the top or bottom depending on comparison.
	-- Let's keep them for now, alphabetical sort will handle them.

	table.sort(lines, compare_lines)

	-- Replace buffer content with sorted lines
	-- Use nvim_buf_set_lines which is atomic and handles undo history correctly.
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
