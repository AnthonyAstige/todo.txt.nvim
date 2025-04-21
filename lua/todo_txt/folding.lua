local M = {}

-- Private functions for folding
local function todo_txt_fold_expr(lnum)
	local FOLD = "1"
	local NORMAL = "0"
	local line = vim.fn.getline(lnum)
	local context_pattern = vim.g.todo_txt_filter_context_pattern or ""
	local project_pattern = vim.g.todo_txt_filter_project_pattern or ""
	if
		(context_pattern ~= "" and (not string.find(line, context_pattern, 1, true)))
		or (project_pattern ~= "" and (not string.find(line, project_pattern, 1, true)))
	then
		return FOLD
	end

	return NORMAL
end

local function todo_fold_text()
	return "Filters: "
		.. (vim.g.todo_txt_filter_context_pattern or "")
		.. " "
		.. (vim.g.todo_txt_filter_project_pattern or "")
end

-- Expose the functions to the module
M.todo_txt_fold_expr = todo_txt_fold_expr
M.todo_fold_text = todo_fold_text

function M.setup_buffer_folding()
	-- Store the functions in buffer-local variables
	vim.b.todo_txt_fold_expr = M.todo_txt_fold_expr
	vim.b.todo_fold_text = M.todo_fold_text

	-- Set up folding using buffer-local Lua functions
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.vim.b.todo_txt_fold_expr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0 -- Close all folds
	vim.opt_local.foldtext = "v:lua.vim.b.todo_fold_text()"
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
