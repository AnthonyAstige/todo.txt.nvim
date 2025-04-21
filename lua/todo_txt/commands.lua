local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")
local folding = require("todo_txt.folding")

local function set_date_filter(filter)
	vim.g.todo_txt_date_filter = filter
	folding.refresh_folding()
end

function M.create_commands(cfg)
	api.nvim_create_user_command("TodoTxtProject", function()
		local items = tags.scan_tags("%+", cfg.todo_file)
		if #items == 0 then
			vim.notify("todo.txt: No projects (+) found in " .. cfg.todo_file, vim.log.levels.WARN)
			return
		end
		vim.ui.select(items, { prompt = "Project> ", kind = "todo_project" }, function(selected)
			if selected then
				vim.g.todo_txt_project_pattern = "+" .. fn.escape(selected, "+")
				folding.refresh_folding()
			end
		end)
	end, { desc = "Focus project (+Tag) todo's" })

	api.nvim_create_user_command("TodoTxtContext", function()
		local items = tags.scan_tags("@", cfg.todo_file)
		if #items == 0 then
			vim.notify("todo.txt: No contexts (@) found in " .. cfg.todo_file, vim.log.levels.WARN)
			return
		end
		vim.ui.select(items, { prompt = "Context> ", kind = "todo_context" }, function(selected)
			if selected then
				vim.g.todo_txt_context_pattern = "@" .. fn.escape(selected, "@")
				folding.refresh_folding()
			end
		end)
	end, { desc = "Focus context (@Tag) todo's" })

	api.nvim_create_user_command("TodoTxtExit", function()
		vim.g.todo_txt_context_pattern = ""
		vim.g.todo_txt_project_pattern = ""
		set_date_filter("all")
		folding.refresh_folding()
	end, { desc = "Clear all focus" })

	api.nvim_create_user_command("TodoTxtAll", function()
		set_date_filter("all")
		folding.refresh_folding()
	end, { desc = "Focus todos due: all" })

	api.nvim_create_user_command("TodoTxtNow", function()
		set_date_filter("now")
		folding.refresh_folding()
	end, { desc = "Focus todos due: today, past, or without due date" })
end

return M
