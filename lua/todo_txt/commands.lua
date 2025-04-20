local M = {}

local api = vim.api
local fn = vim.fn
local tags = require("todo_txt.tags")

-- Creates the user commands for filtering.
function M.create_commands(cfg)
	-- Command to filter by project
	api.nvim_create_user_command("TodoFilterProject", function()
		local items = tags.scan_tags("%+", cfg.todo_file)
		if #items == 0 then
			vim.notify("todo.txt: No projects (+) found in " .. cfg.todo_file, vim.log.levels.WARN)
			return
		end
		vim.ui.select(items, { prompt = "Project> ", kind = "todo_project" }, function(selected)
			if selected then
				-- Escape '+' for Lua pattern matching and create the search pattern
				vim.g.todo_filter_pattern = "%+" .. fn.escape(selected, "+")
				vim.cmd("redraw!") -- Redraw to apply potential syntax changes
				vim.cmd("normal! zx") -- Recalculate folds and apply them
				vim.notify("todo.txt: Filtering by project: +" .. selected)
			end
		end)
	end, { desc = "Filter todo list by project (+Tag) using vim.ui.select" })

	-- Command to filter by context
	api.nvim_create_user_command("TodoFilterContext", function()
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
				vim.cmd("normal! zx") -- Recalculate folds
				vim.notify("todo.txt: Filtering by context: @" .. selected)
			end
		end)
	end, { desc = "Filter todo list by context (@Tag) using vim.ui.select" })

	-- Command to clear the filter
	api.nvim_create_user_command("TodoFilterClear", function()
		if vim.g.todo_filter_pattern then
			vim.g.todo_filter_pattern = nil
			vim.cmd("normal! zR") -- Open all folds
			vim.notify("todo.txt: Filter cleared.")
		else
			vim.notify("todo.txt: No filter active.", vim.log.levels.INFO)
		end
	end, { desc = "Clear current todo filter" })
end

return M
