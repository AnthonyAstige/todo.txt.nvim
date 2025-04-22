-- Default configuration options for todo.txt.nvim
local M = {}

M.defaults = {
	-- Path to your todo.txt file
	todo_file = vim.fn.expand("~/todo.txt/todo.txt"),

	-- Keymaps for plugin actions
	keymaps = {
		top = "<leader>t", -- Base menu key
		focus = "<leader>tf", -- Focus submenu key
		due = "<leader>tfd", -- Due date focus submenu key
		hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
		project = "<leader>tf+", -- Focus: Project
		context = "<leader>tf@", -- Focus: Context
		unfocus = "<leader>tu", -- Unfocus / Clear all focus
		refresh = "<leader>tr", -- Refresh view (sort & fold)
		all = "<leader>tfda", -- Focus Due: All
		now = "<leader>tfdn", -- Focus Due: Now
	},

	-- Filetypes to activate folding and commands for
	-- Ensure 'todo' or similar is set for your todo.txt files
	-- e.g., via vim.filetype.add() or an ftplugin
	filetypes = { "todo", "todos", "todo.txt" },

	startup = {
		focus = {
			date = "now",
			project = nil, -- Focus on todo's with no project
			context = "",
		},
		hyperfocus_enabled = true,
	},
}

return M
