local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")
local folding = require("todo_txt.folding")
local sorting = require("todo_txt.sorting")
local hyperfocus = require("todo_txt.hyperfocus")

local function set_date_filter(filter)
	vim.g.todo_txt_date_filter = filter
	folding.refresh_folding()
end

function M.create_commands(cfg)
	api.nvim_create_user_command("TodoTxtProject", function()
		local items = tags.scan_tags("%+", cfg.todo_file)
		table.insert(items, 1, "No Project")
		table.insert(items, 2, "Any Project")
		vim.ui.select(items, { prompt = "Project> ", kind = "todo_project" }, function(selected)
			if selected == "No Project" then
				vim.g.todo_txt_project_pattern = nil -- Indicate we want no project
			elseif selected == "Any Project" then
				vim.g.todo_txt_project_pattern = "" -- Clear focus
			elseif selected then
				vim.g.todo_txt_project_pattern = "+" .. fn.escape(selected, "+")
			end
			sorting.sort_buffer()
			folding.refresh_folding()
		end)
	end, { desc = "Focus project (+Tag) todo's" })

	api.nvim_create_user_command("TodoTxtContext", function()
		local items = tags.scan_tags("@", cfg.todo_file)
		table.insert(items, 1, "No Context")
		table.insert(items, 2, "Any Context")
		vim.ui.select(items, { prompt = "Context> ", kind = "todo_context" }, function(selected)
			if selected == "No Context" then
				vim.g.todo_txt_context_pattern = nil -- Indicate we want no context
			elseif selected == "Any Context" then
				vim.g.todo_txt_context_pattern = "" -- Clear focus
			elseif selected then
				vim.g.todo_txt_context_pattern = "@" .. fn.escape(selected, "@")
			end
			sorting.sort_buffer()
			folding.refresh_folding()
		end)
	end, { desc = "Focus context (@Tag) todo's" })

	api.nvim_create_user_command("TodoTxtUnfocus", function()
		vim.g.todo_txt_context_pattern = ""
		vim.g.todo_txt_project_pattern = ""
		set_date_filter("all")
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

	api.nvim_create_user_command("TodoTxtNow", function()
		set_date_filter("now")
		sorting.sort_buffer()
		folding.refresh_folding()
	end, { desc = "Focus todos due: today, past, or without due date" })

	api.nvim_create_user_command("TodoTxtHyperfocus", function()
		hyperfocus.toggle()
	end, { desc = "Toggle myopic focus (show only current line)" })
end

return M
