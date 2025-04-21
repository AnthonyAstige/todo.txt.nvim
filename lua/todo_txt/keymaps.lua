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
	if cfg.keymaps.clear then
		vim.keymap.set(
			"n",
			cfg.keymaps.clear,
			"<Cmd>TodoTxtExit<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Exit" })
		)
	end
end

return M
