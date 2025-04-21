local M = {}

-- Helper function to check if a line has no due date tag.
local function has_no_due_date(line)
	return not string.find(line, "due:", 1, true)
end

-- Helper function to check if a line's due date is today or in the past.
local function is_due(line)
	local due_date = string.match(line, "due:(%d%d%d%d%-%d%d%-%d%d)")
	if not due_date then
		return false
	end

	local year, month, day = string.match(due_date, "(%d%d%d%d)-(%d%d)-(%d%d)")
	if not year or not month or not day then
		return false
	end
	year, month, day = tonumber(year), tonumber(month), tonumber(day)

	local today = os.date("*t")
	local due = { year = year, month = month, day = day }

	if due.year < today.year then
		return true
	elseif due.year == today.year and due.month < today.month then
		return true
	elseif due.year == today.year and due.month == today.month and due.day < today.day then
		return true
	elseif due.year == today.year and due.month == today.month and due.day == today.day then
		return true
	end

	return false
end

--- Checks if a given line is currently in focus based on global filters.
--- @param line string The line content to check.
--- @return boolean True if the line is in focus, false otherwise.
function M.is_focused(line)
	local date_filter = vim.g.todo_txt_date_filter
	local context_pattern = vim.g.todo_txt_context_pattern
	local project_pattern = vim.g.todo_txt_project_pattern

	-- Check date filter first
	if date_filter == "now" then
		if not (is_due(line) or has_no_due_date(line)) then
			return false -- Not due now or undated, so out of focus for "now" filter
		end
	end
	-- Note: "all" date filter doesn't exclude any lines based on date.

	-- Check context filter
	if context_pattern == nil then -- Filter requires *no* context tag
		if string.find(line, "@", 1, true) then
			return false -- Line has a context tag, so out of focus
		end
	elseif context_pattern ~= "" then -- Filter requires a specific context tag
		if not string.find(line, context_pattern, 1, true) then
			return false -- Line does not have the required context tag
		end
	end
	-- Note: context_pattern == "" means no context filtering is applied.

	-- Check project filter
	if project_pattern == nil then -- Filter requires *no* project tag
		if string.find(line, "+", 1, true) then
			return false -- Line has a project tag, so out of focus
		end
	elseif project_pattern ~= "" then -- Filter requires a specific project tag
		if not string.find(line, project_pattern, 1, true) then
			return false -- Line does not have the required project tag
		end
	end
	-- Note: project_pattern == "" means no project filtering is applied.

	-- If none of the filters excluded the line, it's in focus
	return true
end

return M
