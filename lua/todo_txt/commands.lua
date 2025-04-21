local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")
local folding = require("todo_txt.folding")

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
	end, { desc = "Filter todo list by project (+Tag) using vim.ui.select" })

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
	end, { desc = "Filter todo list by context (@Tag) using vim.ui.select" })

	api.nvim_create_user_command("TodoTxtClear", function()
		vim.g.todo_txt_context_pattern = ""
		vim.g.todo_txt_project_pattern = ""
		folding.refresh_folding()
	end, { desc = "Clear current todo filter" })
end

return M
