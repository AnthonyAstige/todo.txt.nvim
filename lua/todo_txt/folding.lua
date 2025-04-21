local M = {}

local function has_no_due_date(line)
	return not string.find(line, "due:", 1, true)
end

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

function M.foldexpr(lnum)
	local FOLD = "1"
	local NORMAL = "0"
	local line = vim.fn.getline(lnum)
	local date_filter = vim.g.todo_txt_date_filter
	local context_pattern = vim.g.todo_txt_context_pattern
	local project_pattern = vim.g.todo_txt_project_pattern

	if date_filter == "now" then
		if not (is_due(line) or has_no_due_date(line)) then
			return FOLD
		end
	end

	-- TODO: Make these nil patterns work
	if context_pattern == nil and string.find(line, "@", 1, true) then
		return FOLD
	elseif project_pattern == nil and string.find(line, "+", 1, true) then
		return FOLD
	elseif
		(context_pattern ~= "" and (not string.find(line, context_pattern, 1, true)))
		or (project_pattern ~= "" and (not string.find(line, project_pattern, 1, true)))
	then
		return FOLD
	end

	return NORMAL
end

function M.foldtext()
	return "Focus : "
		.. (vim.g.todo_txt_context_pattern or "")
		.. " "
		.. (vim.g.todo_txt_project_pattern or "")
		.. " due:"
		.. vim.g.todo_txt_date_filter
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
    vim.cmd("normal! zx")
    vim.cmd("edit")
  end)
end

function M.setup_autocmd(cfg)
	local group = vim.api.nvim_create_augroup("TodoTxtFolding", { clear = true })

	-- Set up autocmd for specified filetypes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = cfg.filetypes,
		group = group,
		callback = M.setup_buffer_folding,
	})
end

return M
