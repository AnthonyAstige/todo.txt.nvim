local M = {}
-- TODO: Look through all code "filter" and replace with "focus" as appropriate

local config = require("todo_txt.config")
local folding = require("todo_txt.folding")
local commands = require("todo_txt.commands")
local keymaps = require("todo_txt.keymaps")
local sorting = require("todo_txt.sorting")
local hyperfocus = require("todo_txt.hyperfocus")

local cfg -- Holds merged user and default config

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
	vim.g.todo_txt_date_filter = cfg.startup.focus.date
	vim.g.todo_txt_context_pattern = cfg.startup.focus.context
	vim.g.todo_txt_project_pattern = cfg.startup.focus.project

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
		end,
	})

	if cfg.startup.hyperfocus_enabled then
		-- TODO: Solve flashing screen .. this is pretty early in lifecycle, so may need a folding hack
		vim.api.nvim_create_autocmd("BufReadPre", {
			pattern = cfg.todo_file,
			group = group,
			callback = function()
				hyperfocus.enable_hyperfocus(true)
				vim.schedule(function()
					vim.notify("todo.txt hyperfocus enabled")
					hyperfocus.enable_hyperfocus(true)
				end)
			end,
		})
	end
end

return M
