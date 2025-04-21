local M = {}
-- TODO: Look through all code "filter" and replace with "focus" as appropriate

local config = require("todo_txt.config")
local folding = require("todo_txt.folding")
local commands = require("todo_txt.commands")
local keymaps = require("todo_txt.keymaps")
local sorting = require("todo_txt.sorting")

local cfg -- Holds merged user and default config

-- TODO: Integrate with lualine?

-- Main setup function, called by users (e.g., via LazyVim opts)
-- Merges user options with defaults and initializes the plugin features.
M.setup = function(user_opts)
	-- Merge user options with defaults
	cfg = vim.tbl_deep_extend("force", {}, config.defaults, user_opts or {})

	-- Validate todo_file existence
	if vim.fn.filereadable(cfg.todo_file) == 0 then
		vim.notify("todo.txt: todo_file not found or readable: " .. cfg.todo_file, vim.log.levels.WARN)
	end

	-- Set global date_filter from config
	vim.g.todo_txt_date_filter = cfg.date_focus_start
	vim.g.todo_txt_context_pattern = cfg.context_focus_start
	vim.g.todo_txt_project_pattern = cfg.project_focus_start

	-- Create commands, keymaps, and setup folding autocmd
	commands.create_commands(cfg)
	keymaps.create_keymaps(cfg)

	-- Setup autocmd for filetype detection (sort and fold)
	local group = vim.api.nvim_create_augroup("TodoTxtSetup", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = cfg.filetypes,
		group = group,
		callback = function()
			sorting.sort_buffer()
			folding.setup_buffer_folding()
			folding.refresh_folding()
		end,
	})

	vim.notify("todo.txt.nvim loaded successfully!", vim.log.levels.INFO)
end

return M
