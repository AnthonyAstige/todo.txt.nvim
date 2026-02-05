local M = {}

local focus = require("todo_txt.focus")

-- TODO: Fix below bug without this bandaid
--- Inserts a blank line at the beginning of the buffer if one doesn't exist.
--- This is a band-aid fix for a bug where all lines are shown when they are all folded.
--- The bug is triggered when the file is empty or starts without a blank line.
local function ensure_first_line_blank()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	if #lines == 0 or lines[1] ~= "" then
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "" })
	end
end

function M.foldexpr(lnum)
	local FOLD = "1"
	local NORMAL = "0"
	local line = vim.fn.getline(lnum)

	if focus.is_focused(line) then
		return NORMAL
	else
		return FOLD
	end
end

function M.foldtext()
	local context = vim.g.todo_txt_context_pattern
	local context_str = ""
	if context == nil then
		context_str = "@none"
	else
		context_str = table.concat(context, ",")
	end

	local project = vim.g.todo_txt_project_pattern
	local project_str = ""
	if project == nil then
		project_str = "+none"
	else
		project_str = project
	end

	local parts = {}
	if context_str ~= "" then
		table.insert(parts, context_str)
	end
	if project_str ~= "" then
		table.insert(parts, project_str)
	end

	-- Add hidden projects to display (after project focus, before due)
	local hidden_projects = vim.g.todo_txt_hidden_projects or {}
	for _, hidden_project in ipairs(hidden_projects) do
		table.insert(parts, hidden_project)
	end

	if vim.g.todo_txt_date_filter ~= "all" then
		table.insert(parts, "due:" .. vim.g.todo_txt_date_filter)
	end

	local estimate_filter = vim.g.todo_txt_estimate_filter
	if estimate_filter and estimate_filter ~= "all" then
		table.insert(parts, "~" .. estimate_filter)
	end

	local focus_str = table.concat(parts, " ")

	local display_str = focus_str ~= "" and (focus_str .. " ") or ""
	--vim.notify("Foldtext:" .. display_str)

	return "Focus: " .. display_str
end

function M.setup_buffer_folding()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.require('todo_txt.folding').foldexpr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0 -- Close all folds
	vim.opt_local.foldminlines = 0 -- Allow single line folds
	vim.opt_local.foldtext = "v:lua.require('todo_txt.folding').foldtext()"
end

function M.refresh_folding()
	-- Schedule folding refresh and buffer edit for the next event loop
	-- to allow background tasks to complete before refreshing the view.
	vim.schedule(function()
		ensure_first_line_blank()
		vim.cmd("normal! ggzx")
	end)
end

return M
