local M = {}

local fn = vim.fn
local api = vim.api

-- Global fold expression function that folds every line
_G.TodoFilterFoldExpr = function(lnum)
	local pattern = vim.g.todo_filter_pattern
	-- If no pattern is set, don't fold anything
	if not pattern or pattern == "" then
		return "0"
	end

	local line = fn.getline(lnum)
	-- Check if the line contains the pattern
	return string.find(line, pattern, 1, true) and "0" or "1"
end

function M.setup_buffer_folding()
	-- Set folding options for the current buffer
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.TodoFilterFoldExpr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0

	-- Force refresh folding
	vim.cmd("normal! zM") -- Close all folds
end

function M.setup_autocmd(cfg)
	local group = api.nvim_create_augroup("TodoFilterFolding", { clear = true })

	-- Set up autocmd for specified filetypes
	api.nvim_create_autocmd("FileType", {
		pattern = cfg.filetypes,
		group = group,
		callback = M.setup_buffer_folding,
	})

	-- Also set up BufEnter to ensure folding is applied when switching buffers
	api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		group = group,
		callback = function()
			local ft = vim.bo.filetype
			-- Only apply to configured filetypes
			if vim.tbl_contains(cfg.filetypes, ft) then
				M.setup_buffer_folding()
			end
		end,
	})
end

return M
