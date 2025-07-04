local M = {}
-- TODO: Look through all code "filter" and replace with "focus" as appropriate

local config = require("todo_txt.config")
local folding = require("todo_txt.folding")
local commands = require("todo_txt.commands")
local keymaps = require("todo_txt.keymaps")
local sorting = require("todo_txt.sorting")
local hyperfocus = require("todo_txt.hyperfocus")
local utils = require("todo_txt.utils")
local state = require("todo_txt.state")

local cfg -- Holds merged user and default config

-- Main setup function, called by users (e.g., via LazyVim opts)
-- Merges user options with defaults and initializes the plugin features.
M.setup = function(user_opts)
	-- Merge user options with defaults
	cfg = vim.tbl_deep_extend("force", {}, config.defaults, user_opts or {})

	-- Validate todo_file existence
	if vim.fn.filereadable(cfg.todo_file) == 0 then
		utils.notify("todo_file not found or readable: " .. cfg.todo_file, vim.log.levels.WARN)
	end

	-- Set global date_filter from config (may be overridden by saved state)
	vim.g.todo_txt_date_filter = cfg.startup.focus.date
	vim.g.todo_txt_context_pattern = cfg.startup.focus.context
	-- Convert startup context config (table of names) to internal format (nil/table of patterns)
	local patterns = {}
	for _, ctx in ipairs(cfg.startup.focus.context) do
		table.insert(patterns, "@" .. ctx)
	end
	vim.g.todo_txt_context_pattern = patterns
	vim.g.todo_txt_project_pattern = cfg.startup.focus.project
	vim.g.todo_txt_hidden_projects = vim.g.todo_txt_hidden_projects or {}

	-- Restore previous focus state if present & enabled
	if cfg.startup.load_focus_state then
		state.load()
	end

	commands.create_commands(cfg)
	keymaps.create_global_keymaps(cfg)

	-- Setup autocmd for filetype detection (sort, fold, buffer-local keymaps)
	local group = vim.api.nvim_create_augroup("TodoTxtSetup", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = cfg.filetypes,
		group = group,
		callback = function(args)
			-- Set buffer-local keymaps for physical line movement (ignoring wrapping)
			-- This is the default, but just in case it was overridden
			local map_opts = { noremap = true, silent = true, buffer = args.buf }
			vim.keymap.set("n", "j", "j", map_opts)
			vim.keymap.set("n", "k", "k", map_opts)

			keymaps.create_buffer_keymaps(cfg, args.buf)
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
					utils.notify("Hyperfocus enabled", vim.log.levels.INFO)
					hyperfocus.enable_hyperfocus(true)
				end)
			end,
		})
	end
end

return M
