local M = {}

local function is_past_due(line)
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
	end

	return false
end

function M.foldexpr(lnum)
	local FOLD = "1"
	local NORMAL = "0"
	local line = vim.fn.getline(lnum)
	local context_pattern = vim.g.todo_txt_context_pattern or ""
	local project_pattern = vim.g.todo_txt_project_pattern or ""

	if is_past_due(line) then
		return FOLD
	end

	if
		(context_pattern ~= "" and (not string.find(line, context_pattern, 1, true)))
		or (project_pattern ~= "" and (not string.find(line, project_pattern, 1, true)))
	then
		return FOLD
	end

	return NORMAL
end

function M.foldtext()
	return "Filters: " .. (vim.g.todo_txt_context_pattern or "") .. " " .. (vim.g.todo_txt_project_pattern or "")
end

function M.setup_buffer_folding()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.require('todo_txt.folding').foldexpr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0 -- Close all folds
	vim.opt_local.foldtext = "v:lua.require('todo_txt.folding').foldtext()"
	vim.cmd("normal! zx")
end

function M.refresh_folding()
	vim.cmd("edit") -- Only thing that seems to 100% work since cursor position can't get in the way
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
