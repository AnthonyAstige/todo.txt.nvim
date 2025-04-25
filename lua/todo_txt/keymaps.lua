local M = {}

local wk_status, wk = pcall(require, "which-key")

--- Creates global keymaps (like opening the file or jotting).
--- These are available regardless of filetype.
--- @param cfg table The plugin configuration.
function M.create_global_keymaps(cfg)
	local map_opts = { noremap = true, silent = true }

	if wk_status then
		wk.add({
			cfg.keymaps.top,
			group = "Todo",
			mode = { "n" },
		})
	end

	if cfg.keymaps.open_file then
		vim.keymap.set(
			"n",
			cfg.keymaps.open_file,
			"<Cmd>TodoTxtOpen<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Open todo.txt" })
		)
	end

	if cfg.keymaps.jot then
		vim.keymap.set("n", cfg.keymaps.jot, "<Cmd>TodoTxtJot<CR>", vim.tbl_extend("force", map_opts, { desc = "Jot" }))
	end
end

--- Creates buffer-local keymaps for focus-related actions.
--- These are only active in buffers matching the configured filetypes.
--- @param cfg table The plugin configuration.
--- @param bufnr number The buffer number to apply keymaps to.
function M.create_buffer_keymaps(cfg, bufnr)
	local map_opts = { noremap = true, silent = true, buffer = bufnr }

	if wk_status then
		wk.add({
			cfg.keymaps.focus,
			group = "Focus",
			mode = { "n" },
			buffer = bufnr,
		})
		wk.add({
			cfg.keymaps.due,
			group = "Due",
			mode = { "n" },
			buffer = bufnr,
		})
	end

	if cfg.keymaps.hyperfocustoggle then
		vim.keymap.set(
			"n",
			cfg.keymaps.hyperfocustoggle,
			"<Cmd>TodoTxtHyperfocus<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Hyperfocus" })
		)
	end
	if cfg.keymaps.project then
		vim.keymap.set(
			"n",
			cfg.keymaps.project,
			"<Cmd>TodoTxtProject<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Project" })
		)
	end
	if cfg.keymaps.context then
		vim.keymap.set(
			"n",
			cfg.keymaps.context,
			"<Cmd>TodoTxtContext<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Context" })
		)
	end
	if cfg.keymaps.unfocus then
		vim.keymap.set(
			"n",
			cfg.keymaps.unfocus,
			"<Cmd>TodoTxtUnfocus<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Unfocus" })
		)
	end

	if cfg.keymaps.all then
		vim.keymap.set("n", cfg.keymaps.all, "<Cmd>TodoTxtAll<CR>", vim.tbl_extend("force", map_opts, { desc = "Any" }))
	end

	if cfg.keymaps.now then
		vim.keymap.set("n", cfg.keymaps.now, "<Cmd>TodoTxtNow<CR>", vim.tbl_extend("force", map_opts, { desc = "Now" }))
	end

	if cfg.keymaps.refresh then
		vim.keymap.set(
			"n",
			cfg.keymaps.refresh,
			"<Cmd>TodoTxtRefresh<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Refresh" })
		)
	end

	if cfg.keymaps.open_link then
		vim.keymap.set(
			"n",
			cfg.keymaps.open_link,
			"<Cmd>TodoTxtOpenLink<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Open link" })
		)
	end
end

return M
