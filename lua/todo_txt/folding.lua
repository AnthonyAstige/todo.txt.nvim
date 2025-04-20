local M = {}

local fn = vim.fn
local api = vim.api

-- Store the active filter pattern globally for foldexpr access
vim.g.todo_filter_pattern = nil

-- Fold expression function:
-- Determines fold level based on the global filter pattern.
-- Lines matching the pattern get level '0' (visible), others get '1' (folded).
-- Needs to be global for foldexpr
_G.TodoFilterFoldExpr = function(lnum)
	local pattern = vim.g.todo_filter_pattern
	-- If no pattern is set, don't fold anything
	if not pattern or pattern == "" then
		return "0"
	end

	local line = fn.getline(lnum)
	-- Check if the line contains the pattern
	-- Use vim.regex to handle potential magic characters in the pattern
	local regex = vim.regex(pattern)
	return regex:match_str(line) and "0" or "1"
end

-- Sets up buffer-local options for folding when a relevant file is opened.
function M.setup_buffer_folding()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.TodoFilterFoldExpr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0 -- Start with folds closed
	-- Trigger an initial fold calculation after setting options
	vim.cmd("normal! zx")
end

-- Sets up the autocommand for buffer folding.
function M.setup_autocmd(cfg)
	local group = api.nvim_create_augroup("TodoFilterFolding", { clear = true })
	api.nvim_create_autocmd("FileType", {
		pattern = cfg.filetypes,
		group = group,
		callback = M.setup_buffer_folding,
		desc = "Setup todo.txt folding for relevant filetypes",
	})
end

return M
