local M = {}

local focus = require("todo_txt.focus")

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
	local project = vim.g.todo_txt_project_pattern
	local context_str = context or "@nil"
	local project_str = project or "+nil"

	local parts = {}
	if context_str ~= "" then
		table.insert(parts, context_str)
	end
	if project_str ~= "" then
		table.insert(parts, project_str)
	end

	local focus_str = table.concat(parts, " ")

	local display_str = focus_str ~= "" and (focus_str .. " ") or ""

	return "Focus: " .. display_str .. "due:" .. vim.g.todo_txt_date_filter
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
		vim.cmd("normal! ggzx")
	end)
end

return M
