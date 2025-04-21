-- Default configuration options for todo.txt.nvim
local M = {}

M.defaults = {
	-- Path to your todo.txt file
	todo_file = vim.fn.expand("~/todo.txt/todo.txt"),

	-- Keymaps for filtering actions
	keymaps = {
		top = "<leader>t", -- Menu top
		due = "<leader>td", -- Menu top: due
		project = "<leader>t+", -- Set Project
		context = "<leader>t@", -- Set Context
		exit = "<leader>tx",
		all = "<leader>tda", -- Show Dates: All
		now = "<leader>tdn", -- Show Dates: Now
	},

	-- Filetypes to activate folding and commands for
	-- Ensure 'todo' or similar is set for your todo.txt files
	-- e.g., via vim.filetype.add() or an ftplugin
	filetypes = { "todo", "todos", "todo.txt" },

	-- TODO: Add these to README
	-- How to focus at app loading
	date_focus_start = "now",
	project_focus_start = "",
	-- project_focus_start = nil, -- TODO: Make work with nil default
	context_focus_start = "",
}

return M
