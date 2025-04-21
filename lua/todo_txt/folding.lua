local M = {}

local fn = vim.fn
local api = vim.api

-- Global fold expression function that folds every line
_G.TodoFilterFoldExpr = function(lnum)
	local line = fn.getline(lnum)
	local context_pattern = vim.g.todo_txt_filter_context_pattern or ""
	local project_pattern = vim.g.todo_txt_filter_project_pattern or ""
	vim.notify("TodoFilterFoldExpr(" .. lnum .. "): " .. context_pattern .. " " .. project_pattern)
	if
		(context_pattern ~= "" and string.find(line, context_pattern, 1, true))
		or (project_pattern ~= "" and string.find(line, project_pattern, 1, true))
	then
		vim.notify("Returning: 1")
		return "1"
	end

	vim.notify("Returning: 0")
	return "0"
end

_G.TodoFoldText = function()
	return "Filters: "
		.. (vim.g.todo_txt_filter_context_pattern or "")
		.. " "
		.. (vim.g.todo_txt_filter_project_pattern or "")
end

function M.setup_buffer_folding()
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldexpr = "v:lua.TodoFilterFoldExpr(v:lnum)"
	vim.opt_local.foldenable = true
	vim.opt_local.foldlevel = 0
	vim.opt_local.foldtext = "v:lua.TodoFoldText()"
end

-- Function to refresh folding in the current buffer
function M.refresh_folding()
	vim.cmd("normal! zx")
	vim.cmd("edit") -- Reload the current buffer
end

function M.setup_autocmd(cfg)
	vim.notify("Setting up autocmd")
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
