-- Default configuration options for todo.txt.nvim
local M = {}

M.defaults = {
	-- Path to your todo.txt file
	todo_file = vim.fn.expand("~/todo.txt/todo.txt"),

	-- Keymaps for plugin actions
	keymaps = {
		top = "<leader>t", -- Base menu key
		open_file = "<leader>to", -- Open the configured todo.txt file
		focus = "<leader>tf", -- Focus submenu key
		due = "<leader>tfd", -- Due date focus submenu key
		jot = "<leader>tj", -- Jot down a new todo
		hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
		project = "<leader>tf+", -- Focus: Project
		context = "<leader>tf@", -- Focus: Context
		unfocus = "<leader>tu", -- Unfocus / Clear all focus
		refresh = "<leader>tr", -- Refresh view (sort & fold)
		all = "<leader>tfda", -- Focus Due: All
		now = "<leader>tfdn", -- Focus Due: Now (today/past/undated)
		due_only = "<leader>tfdd", -- Focus Due: Due only (today/past, excludes undated)
		open_link = "<leader>tl", -- Open link on current line
	},

	-- Filetypes to activate folding and commands for
	-- Ensure 'todo' or similar is set for your todo.txt files
	-- e.g., via vim.filetype.add() or an ftplugin
	filetypes = { "todo", "todos", "todo.txt" },

	startup = {
		focus = {
			date = "now",
			project = nil, -- Focus on todo's with no project
			context = {}, -- No filter default
		},
		hyperfocus_enabled = true,
		-- Whether to load and save the focus state (date, project, context) between Neovim sessions.
		load_focus_state = true,
	},

	-- Projects to always include in the jot project selection list
	seeded_projects = { "shop", "health", "work", "personal" },

	-- List of file extensions considered text files for the open_link command.
	-- Files with these extensions will be opened in Neovim. Others externally.
	text_file_extensions = {
		".c",
		".cfg",
		".conf",
		".cpp",
		".css",
		".editorconfig",
		".gitattributes",
		".gitignore",
		".h",
		".hpp",
		".html",
		".ini",
		".js",
		".json",
		".log",
		".lua",
		".md",
		".nix",
		".py",
		".sh",
		".toml",
		".ts",
		".tsx",
		".txt",
		".vim",
		".xml",
		".yaml",
		".yml",
	},
}

return M
