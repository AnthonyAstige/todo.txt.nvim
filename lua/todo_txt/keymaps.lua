local M = {}

local wk_status, wk = pcall(require, "which-key")

function M.create_keymaps(cfg)
	local map_opts = { noremap = true, silent = true }

	if wk_status then
		wk.add({
			cfg.keymaps.top,
			group = "Todo.txt",
			mode = { "n" },
		})
		wk.add({
			cfg.keymaps.due,
			group = "Due",
			mode = { "n" },
		})
		wk.add({
			cfg.keymaps.hyperfocustoggle,
			"<Cmd>TodoTxtHyperfocus<CR>",
			group = "Hyperfocus",
			mode = { "n" },
		})
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
		vim.keymap.set("n", cfg.keymaps.all, "<Cmd>TodoTxtAll<CR>", vim.tbl_extend("force", map_opts, { desc = "All" }))
	end

	if cfg.keymaps.now then
		vim.keymap.set("n", cfg.keymaps.now, "<Cmd>TodoTxtNow<CR>", vim.tbl_extend("force", map_opts, { desc = "Now" }))
	end
end

return M
