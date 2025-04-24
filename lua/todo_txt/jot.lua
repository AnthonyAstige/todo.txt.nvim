-- Module for jotting down new todo items
local M = {}

local api = vim.api
local utils = require("todo_txt.utils")
local tags = require("todo_txt.tags") -- Added dependency

local function has_project_tag(line)
	return string.match(line, "^%+%S+") or string.match(line, "%s%+%S+")
end

--- Helper function to write a todo item to the configured file.
--- Handles file opening, writing, closing, and error/success notifications/callbacks.
--- @param file_path string The path to the todo.txt file.
--- @param todo_item string The todo item string to write.
--- @param error_prefix string The prefix for the error message if the file cannot be opened.
--- @param success_prefix string|nil The prefix for the success message. If nil, no message.
--- @param success_cb function|nil A function to call after the todo is successfully added and file is closed.
local function write_todo_to_file(file_path, todo_item, error_prefix, success_prefix, success_cb)
	local file = io.open(file_path, "a")
	if not file then
		utils.notify(error_prefix .. file_path, vim.log.levels.ERROR)
		return
	end

	file:write(todo_item .. "\n")
	file:close()

	if success_prefix then
		utils.notify(success_prefix .. todo_item, vim.log.levels.INFO)
	end

	if success_cb then
		success_cb()
	end
end

--- Helper function to prompt the user to select or enter a project.
--- This is called after the initial todo input if no project tag was found.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file` and `cfg.seeded_projects`.
--- @param original_input string The todo item string entered by the user (without a project tag).
--- @param opts table Options passed from the original add_todo_item call (contains callbacks/messages).
local function prompt_for_project(cfg, original_input, opts)
	local scanned_projects = tags.scan_tags("%+", cfg.todo_file)
	local seeded_projects = cfg.seeded_projects or {} -- Get from config

	-- Combine and unique projects
	local project_set = {}
	for _, proj in ipairs(seeded_projects) do
		project_set[proj] = true
	end
	for _, proj in ipairs(scanned_projects) do
		project_set[proj] = true
	end

	local project_list = {}
	for proj, _ in pairs(project_set) do
		table.insert(project_list, "+" .. proj) -- Add the '+' prefix for display/selection
	end
	table.sort(project_list)

	-- Add special options at the top
	table.insert(project_list, 1, "No Project")

	vim.ui.select(project_list, { prompt = "Select Project ", kind = "todo_project_select" }, function(selected_project)
		if selected_project == nil then
			if opts.cancel_msg then
				utils.notify(opts.cancel_msg, vim.log.levels.INFO)
			end
			if opts.on_cancel_callback then
				opts.on_cancel_callback()
			end
			return
		elseif selected_project == "No Project" then
			-- Write original input without project
			write_todo_to_file(
				cfg.todo_file,
				original_input,
				opts.error_msg_prefix,
				opts.success_msg_prefix,
				opts.on_success_callback
			)
		elseif selected_project then
			local final_todo = original_input .. " " .. selected_project -- selected_project already has '+'
			write_todo_to_file(
				cfg.todo_file,
				final_todo,
				opts.error_msg_prefix,
				opts.success_msg_prefix,
				opts.on_success_callback
			)
		end
	end)
end

--- Helper function to add a todo item with customizable behavior.
--- This function now includes the project selection logic if no project is initially provided.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file` and `cfg.seeded_projects`.
--- @param opts table Options:
---   - prompt string: The prompt text for vim.ui.input.
---   - cancel_msg string|nil: The message to show if input is cancelled. If nil, no message.
---   - error_msg_prefix string: The prefix for the error message if the file cannot be opened.
---   - success_msg_prefix string|nil: The prefix for the success message. If nil, no message.
---   - on_success_callback function|nil: A function to call after the todo is successfully added and file is closed.
---   - on_cancel_callback function|nil: A function to call if input is cancelled.
---   - prompt_for_project_if_missing boolean: If true, prompts for a project if none is provided initially. If false, adds the item without prompting.
local function add_todo_item(cfg, opts)
	opts = opts or {}
	local prompt = opts.prompt or "Input: "
	local cancel_msg = opts.cancel_msg
	local error_msg_prefix = opts.error_msg_prefix or "Error: "
	local success_msg_prefix = opts.success_msg_prefix
	local on_success_callback = opts.on_success_callback
	local on_cancel_callback = opts.on_cancel_callback
	local prompt_for_project_if_missing = opts.prompt_for_project_if_missing

	if not cfg.todo_file or cfg.todo_file == "" then
		utils.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = prompt }, function(input)
		if input == nil or input == "" then
			if cancel_msg then
				utils.notify(cancel_msg, vim.log.levels.INFO)
			end
			if on_cancel_callback then
				on_cancel_callback()
			end
			return
		end

		if has_project_tag(input) then
			write_todo_to_file(cfg.todo_file, input, error_msg_prefix, success_msg_prefix, on_success_callback)
		else
			if prompt_for_project_if_missing then
				prompt_for_project(cfg, input, opts)
			else
				write_todo_to_file(cfg.todo_file, input, error_msg_prefix, success_msg_prefix, on_success_callback)
			end
		end
	end)
end

--- Prompts the user for a new todo item and appends it to the configured todo file.
--- Includes project selection if no project is provided in the initial input.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file` and `cfg.seeded_projects`.
function M.jot_todo(cfg)
	add_todo_item(cfg, {
		prompt = "New Todo: ",
		cancel_msg = "Jot cancelled.",
		error_msg_prefix = "Error opening todo file: ",
		success_msg_prefix = "Todo added: ",
		on_success_callback = function()
			for _, bufnr in ipairs(api.nvim_list_bufs()) do
				if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_get_name(bufnr) == cfg.todo_file then
					vim.cmd("silent! checktime")
					break
				end
			end
		end,
		-- on_cancel_callback is nil, default behavior (notify and return)
		prompt_for_project_if_missing = true,
	})
end

--- Prompts the user for a new todo item, appends it to the configured todo file, and quits Neovim.
--- If no project is provided in the initial input, the item is added without a project tag (no prompt).
--- Quits on cancellation or success, but not on file error. Does not notify on success.
--- @param cfg table The plugin configuration table, expected to have `cfg.todo_file` and `cfg.seeded_projects`.
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
		prompt_for_project_if_missing = false,
	})
end

return M
