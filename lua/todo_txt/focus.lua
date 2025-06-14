local M = {}

local estimate = require("todo_txt.estimate")

-- Helper function to check if a line has a project tag (e.g., +ProjectName)
local function has_project_tag(line)
  -- match '+tag' at start of line or preceded by whitespace,
  -- with at least one non-space character after '+'
  return string.match(line, "^%+%S+") or string.match(line, "%s%+%S+")
end

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
	-- Empty lines are removed during sorting, so we shouldn't encounter them
	if line == "" then
		return false
	end

	local date_filter = vim.g.todo_txt_date_filter
	local context_pattern = vim.g.todo_txt_context_pattern
	local project_pattern = vim.g.todo_txt_project_pattern
	local hidden_projects = vim.g.todo_txt_hidden_projects or {}
	local estimate_filter = vim.g.todo_txt_estimate_filter or "all"

	-- Check date filter first
	if date_filter == "current" then
		if not (is_due(line) or has_no_due_date(line)) then
			return false -- Not due now or undated, so out of focus for "current" filter
		end
	elseif date_filter == "due" then
		if not is_due(line) then
			return false -- Not due now, so out of focus for "due" filter
		end
	elseif date_filter == "scheduled" then
		if has_no_due_date(line) then
			return false -- No due date, so out of focus for "scheduled" filter
		end
	elseif date_filter == "unscheduled" then
		if not has_no_due_date(line) then
			return false -- Has due date, so out of focus for "unscheduled" filter
		end
	end
	-- Note: "all" date filter doesn't exclude any lines based on date.

	-- Check context filter
	if context_pattern == nil then -- Filter requires *no* context tag
		if string.find(line, "@", 1, true) then
			return false -- Line has a context tag, so out of focus
		end
	else
		for _, pattern in ipairs(context_pattern) do
			if not string.find(line, pattern, 1, true) then
				return false -- Line missing one of the required context tags
			end
		end
	end
	-- Note: context_pattern == "" means no context filtering is applied.

	-- Check project filter
	if project_pattern == nil then -- Filter requires *no* project tag
		if has_project_tag(line) then
			return false -- Line has a project tag, so out of focus
		end
	elseif project_pattern ~= "" then -- Filter requires a specific project tag
		if not string.find(line, project_pattern, 1, true) then
			return false -- Line does not have the required project tag
		end
	end
	-- Note: project_pattern == "" means no project filtering is applied.

	-- Check if any hidden projects match this line
	for _, hidden_pattern in ipairs(hidden_projects) do
		-- Convert -project to +project for matching
		local project_to_match = string.gsub(hidden_pattern, "^%-", "+")
		if string.find(line, project_to_match, 1, true) then
			return false -- Line has a hidden project tag, so out of focus
		end
	end

	-- Check estimate filter
	if not estimate.matches_filter(line, estimate_filter) then
		return false -- Line doesn't match the estimate filter
	end

	-- If none of the filters excluded the line, it's in focus
	return true
end

return M
