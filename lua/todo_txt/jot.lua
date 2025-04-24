-- Module for jotting down new todo items
local M = {}

local api = vim.api
local utils = require("todo_txt.utils")

--- Helper function to add a todo item with customizable behavior.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file`.
--- @param opts table Options:
---   - prompt string: The prompt text for vim.ui.input.
---   - cancel_msg string|nil: The message to show if input is cancelled. If nil, no message.
---   - error_msg_prefix string: The prefix for the error message if the file cannot be opened.
---   - success_msg_prefix string|nil: The prefix for the success message. If nil, no message.
---   - on_success_callback function|nil: A function to call after the todo is successfully added and file is closed.
---   - on_cancel_callback function|nil: A function to call if input is cancelled.
local function add_todo_item(cfg, opts)
	opts = opts or {}
	local prompt = opts.prompt or "Input: "
	local cancel_msg = opts.cancel_msg
	local error_msg_prefix = opts.error_msg_prefix or "Error: "
	local success_msg_prefix = opts.success_msg_prefix
	local on_success_callback = opts.on_success_callback
	local on_cancel_callback = opts.on_cancel_callback

	if not cfg.todo_file or cfg.todo_file == "" then
		utils.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = prompt }, function(input)
		if input == nil or input == "" then
			-- Handle cancellation
			if cancel_msg then
				utils.notify(cancel_msg, vim.log.levels.INFO)
			end
			if on_cancel_callback then
				on_cancel_callback()
			end
			return -- Always return after handling cancellation
		end

		-- Handle successful input (write to file, notify, callback)
		local file = io.open(cfg.todo_file, "a")
		if not file then
			-- Handle file error
			utils.notify(error_msg_prefix .. cfg.todo_file, vim.log.levels.ERROR)
			-- Do NOT quit on error
			return -- Return after handling error
		end

		-- File write success
		file:write(input .. "\n")
		file:close()

		if success_msg_prefix then
			utils.notify(success_msg_prefix .. input, vim.log.levels.INFO)
		end

		if on_success_callback then
			on_success_callback()
		end
		-- Quit logic is handled by the callbacks, not here
	end)
end

--- Prompts the user for a new todo item and appends it to the configured todo file.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file`.
function M.jot_todo(cfg)
	add_todo_item(cfg, {
		prompt = "New Todo: ",
		cancel_msg = "Jot cancelled.",
		error_msg_prefix = "Error opening todo file: ",
		success_msg_prefix = "Todo added: ",
		on_success_callback = function()
			-- Logic specific to jot_todo: checktime on loaded buffers
			for _, bufnr in ipairs(api.nvim_list_bufs()) do
				if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_get_name(bufnr) == cfg.todo_file then
					vim.cmd("silent! checktime")
					break
				end
			end
		end,
		-- on_cancel_callback is nil, default behavior (notify and return)
	})
end

--- Prompts the user for a new todo item, appends it to the configured todo file, and quits Neovim.
--- Quits on cancellation or success, but not on file error. Does not notify on success.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file`.
function M.jot_then_quit(cfg)
	add_todo_item(cfg, {
		prompt = "New Todo (and Quit): ",
		error_msg_prefix = "Error opening todo file: ",
		on_success_callback = function()
			vim.cmd.quit()
		end,
		on_cancel_callback = function()
			vim.cmd.quit()
		end,
	})
end

return M
