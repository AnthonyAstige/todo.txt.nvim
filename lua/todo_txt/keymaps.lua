local M = {}

function M.create_keymaps(cfg)
	local map_opts = { noremap = true, silent = true }

	if cfg.keymaps.project then
		vim.keymap.set(
			"n",
			cfg.keymaps.project,
			"<Cmd>TodoTxtProject<CR>",
			vim.tbl_extend("force", map_opts, { desc = "TODO Project" })
		)
	end
	if cfg.keymaps.context then
		vim.keymap.set(
			"n",
			cfg.keymaps.context,
			"<Cmd>TodoTxtContext<CR>",
			vim.tbl_extend("force", map_opts, { desc = "TODO Context" })
		)
	end
	if cfg.keymaps.clear then
		vim.keymap.set(
			"n",
			cfg.keymaps.clear,
			"<Cmd>TodoTxtExit<CR>",
			vim.tbl_extend("force", map_opts, { desc = "TODO Exit" })
		)
	end
end

return M
