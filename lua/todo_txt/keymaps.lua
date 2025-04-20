local M = {}

-- Sets up the keymaps based on the configuration.
function M.create_keymaps(cfg)
	local map_opts = { noremap = true, silent = true }

	if cfg.keymaps.project then
		vim.keymap.set(
			"n",
			cfg.keymaps.project,
			"<Cmd>TodoTxtFilterProject<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Filter TODO by Project" })
		)
	end
	if cfg.keymaps.context then
		vim.keymap.set(
			"n",
			cfg.keymaps.context,
			"<Cmd>TodoTxtFilterContext<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Filter TODO by Context" })
		)
	end
	if cfg.keymaps.clear then
		vim.keymap.set(
			"n",
			cfg.keymaps.clear,
			"<Cmd>TodoTxtFilterClear<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Clear TODO Filters (eXpand)" })
		)
	end
end

return M
