local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")
local folding = require("todo_txt.folding")

-- Creates the user commands and autocommands.
function M.create_commands(cfg)
	-- Command to filter by project
	api.nvim_create_user_command("TodoTxtFilterProject", function()
		local items = tags.scan_tags("%+", cfg.todo_file)
		if #items == 0 then
			vim.notify("todo.txt: No projects (+) found in " .. cfg.todo_file, vim.log.levels.WARN)
			return
		end
		vim.ui.select(items, { prompt = "Project> ", kind = "todo_project" }, function(selected)
			if selected then
				-- Escape '+' for Lua pattern matching and create the search pattern
				vim.g.todo_filter_pattern = "+" .. fn.escape(selected, "+")
				vim.cmd("redraw!") -- Redraw to apply potential syntax changes
				folding.refresh_folding() -- Apply folding immediately
				vim.notify("todo.txt: Filtering by project: +" .. selected)
			end
		end)
	end, { desc = "Filter todo list by project (+Tag) using vim.ui.select" })

	-- Command to filter by context
	api.nvim_create_user_command("TodoTxtFilterContext", function()
		local items = tags.scan_tags("@", cfg.todo_file)
		if #items == 0 then
			vim.notify("todo.txt: No contexts (@) found in " .. cfg.todo_file, vim.log.levels.WARN)
			return
		end
		vim.ui.select(items, { prompt = "Context> ", kind = "todo_context" }, function(selected)
			if selected then
				-- Escape '@' for Lua pattern matching and create the search pattern
				vim.g.todo_filter_pattern = "@" .. fn.escape(selected, "@")
				vim.cmd("redraw!")
				folding.refresh_folding() -- Apply folding immediately
				vim.notify("todo.txt: Filtering by context: @" .. selected)
			end
		end)
	end, { desc = "Filter todo list by context (@Tag) using vim.ui.select" })

	-- Command to clear the filter
	api.nvim_create_user_command("TodoTxtFilterClear", function()
		if vim.g.todo_filter_pattern then
			vim.g.todo_filter_pattern = nil
			folding.refresh_folding() -- Apply folding immediately
			vim.notify("todo.txt: Filter cleared.")
		else
			vim.notify("todo.txt: No filter active.", vim.log.levels.INFO)
		end
	end, { desc = "Clear current todo filter" })

	-- Command to manually trigger buffer folding setup
	api.nvim_create_user_command("TodoTxtRefreshFolding", function()
		vim.notify("todo.txt: Folding refreshed by reloading buffer.", vim.log.levels.INFO)
	end, { desc = "Manually refresh todo folding" })
end

return M
