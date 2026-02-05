local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")
local folding = require("todo_txt.folding")
local sorting = require("todo_txt.sorting")
local hyperfocus = require("todo_txt.hyperfocus")
local jot = require("todo_txt.jot")
local links = require("todo_txt.links")
local state = require("todo_txt.state")
local focus = require("todo_txt.focus")
local estimate = require("todo_txt.estimate")

local function refresh()
	state.save()
	sorting.sort_buffer()
	folding.refresh_folding()
end

-- Scan for tags only in currently focused (visible) lines
local function scan_visible_tags(sym)
	local tag_map = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for _, line in ipairs(lines) do
		if focus.is_focused(line) then
			for tag in line:gmatch(sym .. "([%w_:-]+)") do
				tag_map[tag] = true
			end
		end
	end

	local tag_list = {}
	for tag, _ in pairs(tag_map) do
		table.insert(tag_list, tag)
	end
	table.sort(tag_list)
	return tag_list
end

function M.create_commands(cfg)
	-- Basic operations
	api.nvim_create_user_command("TodoTxtOpen", function()
		if cfg.todo_file and cfg.todo_file ~= "" then
			local todo_dir = vim.fn.fnamemodify(cfg.todo_file, ":h")
			vim.cmd.cd(todo_dir)
			vim.cmd.edit(cfg.todo_file)
		else
			vim.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		end
	end, { desc = "Open the configured todo.txt file" })

	api.nvim_create_user_command("TodoTxtUnfocus", function()
		vim.g.todo_txt_context_pattern = {}
		vim.g.todo_txt_project_pattern = ""
		vim.g.todo_txt_hidden_projects = {}
		vim.g.todo_txt_hidden_contexts = {}
		vim.g.todo_txt_estimate_filter = "all"
		vim.g.todo_txt_date_filter = "all"
		state.save()
		sorting.sort_buffer()
		hyperfocus.disable_hyperfocus()
		folding.refresh_folding()
	end, { desc = "Clear all focus" })

	api.nvim_create_user_command("TodoTxtRefresh", function()
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Sort and refresh folding" })

	api.nvim_create_user_command("TodoTxtHyperfocus", function()
		hyperfocus.toggle()
	end, { desc = "Toggle myopic focus (show only current line)" })

	api.nvim_create_user_command("TodoTxtJot", function()
		jot.jot_todo(cfg)
	end, { desc = "Jot down a new todo item" })

	api.nvim_create_user_command("TodoTxtJotThenQuit", function()
		jot.jot_then_quit(cfg)
	end, { desc = "Jot down a new todo item and quit Neovim" })

	api.nvim_create_user_command("TodoTxtOpenLink", function()
		links.open_link_on_current_line(cfg)
	end, { desc = "Open link on current line" })

	-- ==================== PROJECT COMMANDS ====================

	api.nvim_create_user_command("TodoTxtProjectAdd", function()
		local current_project = vim.g.todo_txt_project_pattern or ""
		local items = tags.scan_tags("%+", cfg.todo_file)
		if #items == 0 then
			vim.notify("No projects found", vim.log.levels.INFO)
			return
		end

		local items_set = {}
		for _, item in ipairs(items) do
			items_set[item] = true
		end

		local select_options = { "[Clear]" }
		for _, item in ipairs(items) do
			table.insert(select_options, item)
		end

		local prompt_str = "Focus Project"
		if current_project ~= "" and current_project ~= "has" then
			prompt_str = "Focus Project (" .. current_project .. ")> "
		end

		vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_project" }, function(selected)
			if selected == nil then
				return
			elseif items_set[selected] then
				vim.g.todo_txt_project_pattern = "+" .. fn.escape(selected, "+")
				vim.g.todo_txt_hidden_projects = {}
				refresh()
			else
				vim.g.todo_txt_project_pattern = ""
				vim.g.todo_txt_hidden_projects = {}
				refresh()
			end
		end)
	end, { desc = "Select a project to focus on" })

	api.nvim_create_user_command("TodoTxtProjectHide", function()
		local current_hidden = vim.g.todo_txt_hidden_projects or {}
		local items
		if vim.g.todo_txt_project_pattern and vim.g.todo_txt_project_pattern ~= "" then
			items = tags.scan_tags("%+", cfg.todo_file)
		else
			items = scan_visible_tags("%+")
		end

		local hidden_map = {}
		for _, pattern in ipairs(current_hidden) do
			hidden_map[string.sub(pattern, 2)] = true
		end

		local items_set = {}
		local select_options = { "[Clear]" }
		for _, item in ipairs(items) do
			if not hidden_map[item] then
				items_set[item] = true
				table.insert(select_options, item)
			end
		end

		local prompt_str = "Hide Project"
		if #current_hidden > 0 then
			prompt_str = "Hide Project (" .. table.concat(current_hidden, ", ") .. ")> "
		end

		vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_hide_project" }, function(selected)
			if selected == nil then
				return
			elseif items_set[selected] then
				table.insert(current_hidden, "-" .. fn.escape(selected, "-"))
				vim.g.todo_txt_hidden_projects = current_hidden
				vim.g.todo_txt_project_pattern = ""
				refresh()
			else
				vim.g.todo_txt_hidden_projects = {}
				refresh()
			end
		end)
	end, { desc = "Hide project(s) from view" })

	api.nvim_create_user_command("TodoTxtProjectAny", function()
		vim.g.todo_txt_project_pattern = ""
		vim.g.todo_txt_hidden_projects = {}
		refresh()
	end, { desc = "Clear project filter (show any)" })

	api.nvim_create_user_command("TodoTxtProjectHas", function()
		vim.g.todo_txt_project_pattern = "has"
		vim.g.todo_txt_hidden_projects = {}
		refresh()
	end, { desc = "Focus tasks with any project" })

	api.nvim_create_user_command("TodoTxtProjectNone", function()
		vim.g.todo_txt_project_pattern = nil
		vim.g.todo_txt_hidden_projects = {}
		refresh()
	end, { desc = "Focus tasks without projects" })

	-- ==================== CONTEXT COMMANDS ====================

	api.nvim_create_user_command("TodoTxtContextAdd", function()
		local current_filter = vim.g.todo_txt_context_pattern or {}
		local items = tags.scan_tags("@", cfg.todo_file)

		local selected_map = {}
		if type(current_filter) == "table" then
			for _, pattern in ipairs(current_filter) do
				selected_map[string.sub(pattern, 2)] = true
			end
		end

		local items_set = {}
		local select_options = { "[Clear]" }
		for _, item in ipairs(items) do
			if not selected_map[item] then
				items_set[item] = true
				table.insert(select_options, item)
			end
		end

		local prompt_str = "Add Context"
		if type(current_filter) == "table" and #current_filter > 0 then
			prompt_str = "Add Context (" .. table.concat(current_filter, ", ") .. ")> "
		end

		vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_context" }, function(selected)
			if selected == nil then
				return
			elseif items_set[selected] then
				local new_pattern = "@" .. fn.escape(selected, "@")
				local filter = vim.g.todo_txt_context_pattern
				if type(filter) == "table" then
					table.insert(filter, new_pattern)
					vim.g.todo_txt_context_pattern = filter
				else
					vim.g.todo_txt_context_pattern = { new_pattern }
				end
				vim.g.todo_txt_hidden_contexts = {}
				refresh()
			else
				vim.g.todo_txt_context_pattern = {}
				vim.g.todo_txt_hidden_contexts = {}
				refresh()
			end
		end)
	end, { desc = "Add a context to focus on" })

	api.nvim_create_user_command("TodoTxtContextHide", function()
		local current_hidden = vim.g.todo_txt_hidden_contexts or {}
		local items
		local context_filter = vim.g.todo_txt_context_pattern
		if type(context_filter) == "table" and #context_filter > 0 then
			items = tags.scan_tags("@", cfg.todo_file)
		else
			items = scan_visible_tags("@")
		end

		local hidden_map = {}
		for _, pattern in ipairs(current_hidden) do
			hidden_map[string.sub(pattern, 2)] = true
		end

		local items_set = {}
		local select_options = { "[Clear]" }
		for _, item in ipairs(items) do
			if not hidden_map[item] then
				items_set[item] = true
				table.insert(select_options, item)
			end
		end

		local prompt_str = "Hide Context"
		if #current_hidden > 0 then
			prompt_str = "Hide Context (" .. table.concat(current_hidden, ", ") .. ")> "
		end

		vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_hide_context" }, function(selected)
			if selected == nil then
				return
			elseif items_set[selected] then
				table.insert(current_hidden, "-" .. fn.escape(selected, "-"))
				vim.g.todo_txt_hidden_contexts = current_hidden
				vim.g.todo_txt_context_pattern = {}
				refresh()
			else
				vim.g.todo_txt_hidden_contexts = {}
				refresh()
			end
		end)
	end, { desc = "Hide context(s) from view" })

	api.nvim_create_user_command("TodoTxtContextAny", function()
		vim.g.todo_txt_context_pattern = {}
		vim.g.todo_txt_hidden_contexts = {}
		refresh()
	end, { desc = "Clear context filter (show any)" })

	api.nvim_create_user_command("TodoTxtContextHas", function()
		vim.g.todo_txt_context_pattern = "has"
		vim.g.todo_txt_hidden_contexts = {}
		refresh()
	end, { desc = "Focus tasks with any context" })

	api.nvim_create_user_command("TodoTxtContextNone", function()
		vim.g.todo_txt_context_pattern = nil
		vim.g.todo_txt_hidden_contexts = {}
		refresh()
	end, { desc = "Focus tasks without contexts" })

	-- ==================== DUE DATE COMMANDS ====================

	api.nvim_create_user_command("TodoTxtDueAny", function()
		vim.g.todo_txt_date_filter = "all"
		refresh()
	end, { desc = "Any due status (show all)" })

	api.nvim_create_user_command("TodoTxtDueHas", function()
		vim.g.todo_txt_date_filter = "scheduled"
		refresh()
	end, { desc = "Has due date (scheduled)" })

	api.nvim_create_user_command("TodoTxtDueNone", function()
		vim.g.todo_txt_date_filter = "unscheduled"
		refresh()
	end, { desc = "No due date (unscheduled)" })

	api.nvim_create_user_command("TodoTxtDueCurrent", function()
		vim.g.todo_txt_date_filter = "current"
		refresh()
	end, { desc = "Current: today, past, or undated" })

	api.nvim_create_user_command("TodoTxtDueDue", function()
		vim.g.todo_txt_date_filter = "due"
		refresh()
	end, { desc = "Due: today or past only" })

	-- ==================== ESTIMATE COMMANDS ====================

	api.nvim_create_user_command("TodoTxtEstimateHas", function()
		vim.g.todo_txt_estimate_filter = "has"
		refresh()
	end, { desc = "Focus todos with any estimate" })

	api.nvim_create_user_command("TodoTxtEstimateNone", function()
		vim.g.todo_txt_estimate_filter = "none"
		refresh()
	end, { desc = "Focus todos without estimate" })

	api.nvim_create_user_command("TodoTxtEstimateMax", function()
		local _, current_max = estimate.get_bounds()
		local prompt = "Max estimate ≤ (e.g., 30m, 2h)"
		if current_max then
			prompt = prompt .. " [current: " .. estimate.format_minutes(current_max) .. "]"
		end
		prompt = prompt .. ": "
		vim.ui.input({ prompt = prompt }, function(input)
			if not input or input == "" then
				return
			end
			local minutes = estimate.parse_estimate_string(input)
			if not minutes then
				vim.notify("Invalid estimate format. Use: 5m, 2h, 3d, 1w, 1mo, 1y", vim.log.levels.WARN)
				return
			end
			estimate.set_max_bound(minutes)
			refresh()
		end)
	end, { desc = "Set max estimate bound" })

	api.nvim_create_user_command("TodoTxtEstimateMin", function()
		local current_min, _ = estimate.get_bounds()
		local prompt = "Min estimate ≥ (e.g., 30m, 2h)"
		if current_min then
			prompt = prompt .. " [current: " .. estimate.format_minutes(current_min) .. "]"
		end
		prompt = prompt .. ": "
		vim.ui.input({ prompt = prompt }, function(input)
			if not input or input == "" then
				return
			end
			local minutes = estimate.parse_estimate_string(input)
			if not minutes then
				vim.notify("Invalid estimate format. Use: 5m, 2h, 3d, 1w, 1mo, 1y", vim.log.levels.WARN)
				return
			end
			estimate.set_min_bound(minutes)
			refresh()
		end)
	end, { desc = "Set min estimate bound" })

	api.nvim_create_user_command("TodoTxtEstimateAny", function()
		vim.g.todo_txt_estimate_filter = "all"
		refresh()
	end, { desc = "Clear estimate filter (show any)" })
end

return M
