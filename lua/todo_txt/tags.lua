local M = {}

local fn = vim.fn

-- Scan for tags (symbol: '+' for projects, '@' for contexts)
-- Returns a list of unique tags found in the configured todo_file.
function M.scan_tags(sym, todo_file)
	local tags = {}
	local file = io.open(todo_file, "r")
	if not file then
		vim.notify("todo.txt: Could not open todo file: " .. todo_file, vim.log.levels.ERROR)
		return {}
	end

	for line in file:lines() do
		-- Match tags containing alphanumeric characters, underscores, colons, and hyphens
		for tag in line:gmatch(sym .. "([%w_:-]+)") do
			tags[tag] = true
		end
	end
	file:close()

	local tag_list = {}
	for tag, _ in pairs(tags) do
		table.insert(tag_list, tag)
	end
	table.sort(tag_list) -- Sort for consistent order
	return tag_list
end

return M
