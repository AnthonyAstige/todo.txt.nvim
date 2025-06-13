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

local function set_date_filter(filter)
	vim.g.todo_txt_date_filter = filter
	state.save()
	folding.refresh_folding()
end

-- Scan for tags only in currently focused (visible) lines
local function scan_visible_tags(sym)
	local tag_map = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	
	for _, line in ipairs(lines) do
		if focus.is_focused(line) then
			-- Match tags containing alphanumeric characters, underscores, colons, and hyphens
			for tag in line:gmatch(sym .. "([%w_:-]+)") do
				tag_map[tag] = true
			end
		end
	end
	
	local tag_list = {}
	for tag, _ in pairs(tag_map) do
		table.insert(tag_list, tag)
	end
	table.sort(tag_list) -- Sort for consistent order
	return tag_list
end

local function prompt_for_context(cfg)
	local current_filter = vim.g.todo_txt_context_pattern
	local items = tags.scan_tags("@", cfg.todo_file)

	-- Prepare selection list
	local select_options = { "Any Context", "No Context" }
	-- Add existing contexts, filtering out those already selected if current_filter is a table
	local selected_contexts_map = {}
	if type(current_filter) == "table" then
		for _, pattern in ipairs(current_filter) do
			-- Store the name part, e.g., "home" from "@home"
			selected_contexts_map[string.sub(pattern, 2)] = true
		end
	end

	-- Add available contexts that are not already selected
	for _, item in ipairs(items) do
		if not selected_contexts_map[item] then
			table.insert(select_options, item) -- Add the name, e.g., "home"
		end
	end

	-- Build prompt string showing current selection
	local prompt_str = "Set Context Filter"
	if type(current_filter) == "table" and #current_filter > 0 then
		prompt_str = "Add to or replace current Context Filter of " .. table.concat(current_filter, ", ") .. "> "
	elseif current_filter == nil then
		prompt_str = "Replace current Context Filter of @none> "
	end

	vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_context_select" }, function(selected)
		if selected == nil then
			-- User cancelled
			return
		elseif selected == "Any Context" then
			vim.g.todo_txt_context_pattern = {}
		elseif selected == "No Context" then
			vim.g.todo_txt_context_pattern = nil -- Indicate we want no context
		elseif selected then
			-- User selected a specific context name (e.g., "home")
			local new_pattern = "@" .. fn.escape(selected, "@")
			local filter = vim.g.todo_txt_context_pattern
			local updated_filter

			-- Determine the updated filter based on the current state
			if type(filter) == "table" then
				-- Current filter is already a table, add to it if not present
				updated_filter = filter
				local found = false
				for _, existing_pattern in ipairs(updated_filter) do
					if existing_pattern == new_pattern then
						found = true
						break
					end
				end
				if not found then
					table.insert(updated_filter, new_pattern)
				end
			else
				updated_filter = { new_pattern }
			end

			vim.g.todo_txt_context_pattern = updated_filter
		end

		if selected ~= nil then
			state.save()
			sorting.sort_buffer()
			folding.refresh_folding()
		end
	end)
end

function M.create_commands(cfg)
	api.nvim_create_user_command("TodoTxtOpen", function()
		if cfg.todo_file and cfg.todo_file ~= "" then
			vim.cmd.edit(cfg.todo_file)
		else
			vim.notify("todo.txt file path is not configured.", vim.log.levels.WARN)
		end
	end, { desc = "Open the configured todo.txt file" })

	api.nvim_create_user_command("TodoTxtProject", function()
		local items = tags.scan_tags("%+", cfg.todo_file)
		table.insert(items, 1, "Any Project")
		table.insert(items, 2, "No Project")
		vim.ui.select(items, { prompt = "Project> ", kind = "todo_project" }, function(selected)
			-- User cancelled
			if selected == nil then
				return
			end

			if selected == "No Project" then
				vim.g.todo_txt_project_pattern = nil -- Indicate we want no project
			elseif selected == "Any Project" then
				vim.g.todo_txt_project_pattern = "" -- Clear focus
			elseif selected then
				vim.g.todo_txt_project_pattern = "+" .. fn.escape(selected, "+")
			end
			-- Clear hidden projects when setting project focus
			vim.g.todo_txt_hidden_projects = {}
			state.save()
			sorting.sort_buffer()
			folding.refresh_folding()
		end)
	end, { desc = "Focus project (+Tag) todo's" })

	api.nvim_create_user_command("TodoTxtHideProject", function()
		local current_hidden = vim.g.todo_txt_hidden_projects or {}
		-- If there's a project focus, show all projects; otherwise show only visible ones
		local items
		if vim.g.todo_txt_project_pattern and vim.g.todo_txt_project_pattern ~= "" then
			items = tags.scan_tags("%+", cfg.todo_file)
		else
			items = scan_visible_tags("%+")
		end

		-- Filter out already hidden projects
		local hidden_projects_map = {}
		for _, pattern in ipairs(current_hidden) do
			-- Store the name part, e.g., "work" from "-work"
			hidden_projects_map[string.sub(pattern, 2)] = true
		end

		-- Add available projects that are not already hidden
		local select_options = { "Clear All Hidden", "Show Currently Hidden" }
		for _, item in ipairs(items) do
			if not hidden_projects_map[item] then
				table.insert(select_options, item)
			end
		end

		-- Build prompt string showing current hidden projects
		local prompt_str = "Hide Project"
		if #current_hidden > 0 then
			prompt_str = "Add to hidden projects (" .. table.concat(current_hidden, ", ") .. ")> "
		end

		vim.ui.select(select_options, { prompt = prompt_str, kind = "todo_hide_project" }, function(selected)
			if selected == nil then
				-- User cancelled
				return
			elseif selected == "Clear All Hidden" then
				vim.g.todo_txt_hidden_projects = {}
			elseif selected == "Show Currently Hidden" then
				if #current_hidden > 0 then
					-- Allow unhiding specific projects
					vim.ui.select(current_hidden, { prompt = "Unhide Project> " }, function(unhide_pattern)
						if unhide_pattern then
							local new_hidden = {}
							for _, pattern in ipairs(current_hidden) do
								if pattern ~= unhide_pattern then
									table.insert(new_hidden, pattern)
								end
							end
							vim.g.todo_txt_hidden_projects = new_hidden
							state.save()
							sorting.sort_buffer()
							folding.refresh_folding()
						end
					end)
					return
				else
					vim.notify("No projects are currently hidden", vim.log.levels.INFO)
					return
				end
			elseif selected then
				-- User selected a specific project to hide
				local hide_pattern = "-" .. fn.escape(selected, "-")
				table.insert(current_hidden, hide_pattern)
				vim.g.todo_txt_hidden_projects = current_hidden
				-- Clear project focus when hiding projects
				vim.g.todo_txt_project_pattern = ""
			end

			if selected ~= nil and selected ~= "Show Currently Hidden" then
				state.save()
				sorting.sort_buffer()
				folding.refresh_folding()
			end
		end)
	end, { desc = "Hide project(s) from view" })

	api.nvim_create_user_command("TodoTxtContext", function()
		prompt_for_context(cfg)
	end, { desc = "Focus context" })

	api.nvim_create_user_command("TodoTxtUnfocus", function()
		vim.g.todo_txt_context_pattern = {}
		vim.g.todo_txt_project_pattern = ""
		vim.g.todo_txt_hidden_projects = {}
		set_date_filter("all")
		state.save()
		sorting.sort_buffer()
		hyperfocus.disable_hyperfocus()
		folding.refresh_folding()
	end, { desc = "Clear all focus" })

	api.nvim_create_user_command("TodoTxtSort", function()
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Sort buffer by focus then alphabetically" })

	api.nvim_create_user_command("TodoTxtAll", function()
		set_date_filter("all")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos due: all" })

	api.nvim_create_user_command("TodoTxtCurrent", function()
		set_date_filter("current")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos due: today, past, or without due date" })

	api.nvim_create_user_command("TodoTxtDue", function()
		set_date_filter("due")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos due: today or past only (excludes undated)" })

	api.nvim_create_user_command("TodoTxtScheduled", function()
		set_date_filter("scheduled")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos with any due date" })

	api.nvim_create_user_command("TodoTxtUnscheduled", function()
		set_date_filter("unscheduled")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos without a due date" })

	api.nvim_create_user_command("TodoTxtHyperfocus", function()
		hyperfocus.toggle()
	end, { desc = "Toggle myopic focus (show only current line)" })

	api.nvim_create_user_command("TodoTxtRefresh", function()
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Sort and refresh folding" })

	api.nvim_create_user_command("TodoTxtJot", function()
		jot.jot_todo(cfg)
	end, { desc = "Jot down a new todo item" })

	api.nvim_create_user_command("TodoTxtJotThenQuit", function()
		jot.jot_then_quit(cfg)
	end, {
		desc = "Jot down a new todo item and quit Neovim. Helps OS level shortcuts.",
	})

	api.nvim_create_user_command("TodoTxtOpenLink", function()
		links.open_link_on_current_line(cfg)
	end, { desc = "Open link on current line" })
end

return M
