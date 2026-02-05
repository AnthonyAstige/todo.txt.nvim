-- Default configuration options for todo.txt.nvim
local M = {}

M.defaults = {
	-- Path to your todo.txt file
	todo_file = vim.fn.expand("~/todo.txt/todo.txt"),

	-- Keymaps for plugin actions
	-- Grammar: <leader>tf = Focus, then category (p/c/d/e), then action
	-- Universal actions: a=any, ~=has, 0=none
	-- Category-specific: +/- for project/context, c/d for due, </> for estimate
	keymaps = {
		top = "<leader>t", -- Base menu key
		open_file = "<leader>to", -- Open the configured todo.txt file
		open_file_alt = "<leader>tt", -- Alternative shortcut to open todo.txt file
		focus = "<leader>tf", -- Focus submenu key
		jot = "<leader>tj", -- Jot down a new todo
		hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
		unfocus = "<leader>tu", -- Unfocus / Clear all focus
		refresh = "<leader>tr", -- Refresh view (sort & fold)
		open_link = "<leader>tl", -- Open link on current line

		-- Project submenu: <leader>tfp
		project_menu = "<leader>tfp", -- Project submenu key
		project_add = "<leader>tfp+", -- Add/select project to focus
		project_hide = "<leader>tfp-", -- Hide project
		project_any = "<leader>tfpa", -- Any project (clear filter)
		project_has = "<leader>tfp~", -- Has project (tasks with any project)
		project_none = "<leader>tfp0", -- No project (tasks without projects)

		-- Context submenu: <leader>tfc
		context_menu = "<leader>tfc", -- Context submenu key
		context_add = "<leader>tfc+", -- Add context to focus
		context_hide = "<leader>tfc-", -- Hide context
		context_any = "<leader>tfca", -- Any context (clear filter)
		context_has = "<leader>tfc~", -- Has context (tasks with any context)
		context_none = "<leader>tfc0", -- No context (tasks without contexts)

		-- Due submenu: <leader>tfd
		due_menu = "<leader>tfd", -- Due date focus submenu key
		due_any = "<leader>tfda", -- Any due status (all)
		due_has = "<leader>tfd~", -- Has due date (scheduled)
		due_none = "<leader>tfd0", -- No due date (unscheduled)
		due_current = "<leader>tfdc", -- Current (today/past/undated)
		due_due = "<leader>tfdd", -- Due (today/past only)

		-- Estimate submenu: <leader>tfe
		estimate_menu = "<leader>tfe", -- Estimate submenu key
		estimate_any = "<leader>tfea", -- Any estimate (clear filter)
		estimate_has = "<leader>tfe~", -- Has estimate
		estimate_none = "<leader>tfe0", -- No estimate
		estimate_max = "<leader>tfe<", -- Set max bound
		estimate_min = "<leader>tfe>", -- Set min bound
	},

	-- Filetypes to activate folding and commands for
	-- Ensure 'todo' or similar is set for your todo.txt files
	-- e.g., via vim.filetype.add() or an ftplugin
	filetypes = { "todo", "todos", "todo.txt" },

	startup = {
		focus = {
			date = "current",
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
