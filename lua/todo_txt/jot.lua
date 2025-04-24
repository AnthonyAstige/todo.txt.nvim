-- Module for jotting down new todo items
local M = {}

local api = vim.api
local utils = require("todo_txt.utils")

--- Prompts the user for a new todo item and appends it to the configured todo file.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file`.
function M.jot_todo(cfg)
	if not cfg.todo_file or cfg.todo_file == "" then
		utils.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "New Todo: " }, function(input)
		if input == nil or input == "" then
			utils.notify("Jot cancelled.", vim.log.levels.INFO)
			return
		end

		local file = io.open(cfg.todo_file, "a")
		if not file then
			utils.notify("Error opening todo file: " .. cfg.todo_file, vim.log.levels.ERROR)
			return
		end

		file:write(input .. "\n")
		file:close()

		utils.notify("Todo added: " .. input, vim.log.levels.INFO)

		for _, bufnr in ipairs(api.nvim_list_bufs()) do
			if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_get_name(bufnr) == cfg.todo_file then
				vim.cmd("silent! checktime")
				break
			end
		end
	end)
end

--- Prompts the user for a new todo item, appends it to the configured todo file, and quits Neovim.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file`.
function M.jot_then_quit(cfg)
	if not cfg.todo_file or cfg.todo_file == "" then
		utils.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "New Todo (and Quit): " }, function(input)
		if input == nil or input == "" then
			utils.notify("Jot cancelled. Not quitting.", vim.log.levels.INFO)
			return
		end

		local file = io.open(cfg.todo_file, "a")
		if not file then
			utils.notify("Error opening todo file: " .. cfg.todo_file .. ". Not quitting.", vim.log.levels.ERROR)
			return
		end

		file:write(input .. "\n")
		file:close()

		utils.notify("Todo added: " .. input .. ". Quitting.", vim.log.levels.INFO)

		-- Quit Neovim after successfully adding the todo
		vim.cmd.quit()
	end)
end

return M
