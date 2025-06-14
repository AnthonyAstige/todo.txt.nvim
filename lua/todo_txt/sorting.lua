local M = {}

local api = vim.api
local focus = require("todo_txt.focus")
local estimate = require("todo_txt.estimate")

--- Extract priority from a line (A, B, C, etc.)
--- @param line string The line to extract priority from.
--- @return string|nil The priority letter, or nil if no priority.
local function get_priority(line)
	return line:match("^%(([A-Z])%)")
end

--- Custom comparison function for sorting lines.
--- Prioritizes: 1) focused vs unfocused, 2) priority, 3) estimate size, 4) alphabetical.
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
		-- Both have the same focus status
		local a_priority = get_priority(a)
		local b_priority = get_priority(b)

		-- Compare priorities
		if a_priority and not b_priority then
			return true -- Prioritized items come first
		elseif not a_priority and b_priority then
			return false
		elseif a_priority and b_priority and a_priority ~= b_priority then
			return a_priority < b_priority -- A < B < C
		else
			-- Same priority or both have no priority, compare estimates
			local a_estimate = estimate.get_estimate(a)
			local b_estimate = estimate.get_estimate(b)

			if a_estimate and b_estimate and a_estimate ~= b_estimate then
				return a_estimate < b_estimate -- Smaller estimates first
			elseif a_estimate and not b_estimate then
				return true -- Items with estimates come before those without
			elseif not a_estimate and b_estimate then
				return false
			else
				-- Same estimate or both have no estimate, sort alphabetically
				return a < b
			end
		end
	end
end

--- Sorts the lines in the current buffer based on focus and alphabetical order.
function M.sort_buffer()
	local buf = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

	-- Filter out empty lines
	local content_lines = {}
	for _, line in ipairs(lines) do
		if line ~= "" then
			table.insert(content_lines, line)
		end
	end

	-- Sort the content lines
	table.sort(content_lines, compare_lines)

	-- Replace buffer content with sorted lines (no empty lines)
	api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
end

return M
