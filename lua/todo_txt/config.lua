-- Default configuration options for todo.txt.nvim
local M = {}

M.defaults = {
	-- Path to your todo.txt file
	todo_file = vim.fn.expand("~/todo.txt/todo.txt"),

	-- Keymaps for filtering actions
	keymaps = {
		top = "<leader>t", -- Menu top
		due = "<leader>td", -- Menu top: due
		hyperfocustoggle = "<leader>th",
		project = "<leader>t+", -- Set Project
		context = "<leader>t@", -- Set Context
		unfocus = "<leader>tu",
		all = "<leader>tda", -- Show Dates: All
		now = "<leader>tdn", -- Show Dates: Now
	},

	-- Filetypes to activate folding and commands for
	-- Ensure 'todo' or similar is set for your todo.txt files
	-- e.g., via vim.filetype.add() or an ftplugin
	filetypes = { "todo", "todos", "todo.txt" },

	-- TODO: Better naming here
	-- Focus at loading
	startup_focus_date = "now",
	startup_focus_project = nil, -- Focus on todo's with no project
	startup_focus_context = "",
	startup_hyperfocus_enabled = true,
}

return M
