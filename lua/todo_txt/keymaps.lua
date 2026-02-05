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

	if cfg.keymaps.open_file_alt then
		vim.keymap.set(
			"n",
			cfg.keymaps.open_file_alt,
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

	-- Register which-key groups for submenus
	if wk_status then
		wk.add({
			cfg.keymaps.focus,
			group = "Focus",
			mode = { "n" },
			buffer = bufnr,
		})
		wk.add({
			cfg.keymaps.project_menu,
			group = "Project",
			mode = { "n" },
			buffer = bufnr,
		})
		wk.add({
			cfg.keymaps.context_menu,
			group = "Context",
			mode = { "n" },
			buffer = bufnr,
		})
		wk.add({
			cfg.keymaps.due_menu,
			group = "Due",
			mode = { "n" },
			buffer = bufnr,
		})
		wk.add({
			cfg.keymaps.estimate_menu,
			group = "Estimate",
			mode = { "n" },
			buffer = bufnr,
		})
	end

	-- Basic operations
	if cfg.keymaps.hyperfocustoggle then
		vim.keymap.set(
			"n",
			cfg.keymaps.hyperfocustoggle,
			"<Cmd>TodoTxtHyperfocus<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Hyperfocus" })
		)
	end

	if cfg.keymaps.unfocus then
		vim.keymap.set(
			"n",
			cfg.keymaps.unfocus,
			"<Cmd>TodoTxtUnfocus<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Unfocus all" })
		)
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

	-- ==================== PROJECT KEYMAPS ====================

	if cfg.keymaps.project_add then
		vim.keymap.set(
			"n",
			cfg.keymaps.project_add,
			"<Cmd>TodoTxtProjectAdd<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Add/Focus" })
		)
	end

	if cfg.keymaps.project_hide then
		vim.keymap.set(
			"n",
			cfg.keymaps.project_hide,
			"<Cmd>TodoTxtProjectHide<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Hide" })
		)
	end

	if cfg.keymaps.project_any then
		vim.keymap.set(
			"n",
			cfg.keymaps.project_any,
			"<Cmd>TodoTxtProjectAny<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Any" })
		)
	end

	if cfg.keymaps.project_none then
		vim.keymap.set(
			"n",
			cfg.keymaps.project_none,
			"<Cmd>TodoTxtProjectNone<CR>",
			vim.tbl_extend("force", map_opts, { desc = "None" })
		)
	end

	-- ==================== CONTEXT KEYMAPS ====================

	if cfg.keymaps.context_add then
		vim.keymap.set(
			"n",
			cfg.keymaps.context_add,
			"<Cmd>TodoTxtContextAdd<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Add" })
		)
	end

	if cfg.keymaps.context_hide then
		vim.keymap.set(
			"n",
			cfg.keymaps.context_hide,
			"<Cmd>TodoTxtContextHide<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Hide" })
		)
	end

	if cfg.keymaps.context_any then
		vim.keymap.set(
			"n",
			cfg.keymaps.context_any,
			"<Cmd>TodoTxtContextAny<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Any" })
		)
	end

	if cfg.keymaps.context_none then
		vim.keymap.set(
			"n",
			cfg.keymaps.context_none,
			"<Cmd>TodoTxtContextNone<CR>",
			vim.tbl_extend("force", map_opts, { desc = "None" })
		)
	end

	-- ==================== DUE DATE KEYMAPS ====================

	if cfg.keymaps.due_any then
		vim.keymap.set(
			"n",
			cfg.keymaps.due_any,
			"<Cmd>TodoTxtDueAny<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Any" })
		)
	end

	if cfg.keymaps.due_current then
		vim.keymap.set(
			"n",
			cfg.keymaps.due_current,
			"<Cmd>TodoTxtDueCurrent<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Current" })
		)
	end

	if cfg.keymaps.due_due then
		vim.keymap.set(
			"n",
			cfg.keymaps.due_due,
			"<Cmd>TodoTxtDueDue<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Due" })
		)
	end

	if cfg.keymaps.due_scheduled then
		vim.keymap.set(
			"n",
			cfg.keymaps.due_scheduled,
			"<Cmd>TodoTxtDueScheduled<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Scheduled" })
		)
	end

	if cfg.keymaps.due_unscheduled then
		vim.keymap.set(
			"n",
			cfg.keymaps.due_unscheduled,
			"<Cmd>TodoTxtDueUnscheduled<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Unscheduled" })
		)
	end

	-- ==================== ESTIMATE KEYMAPS ====================

	if cfg.keymaps.estimate_has then
		vim.keymap.set(
			"n",
			cfg.keymaps.estimate_has,
			"<Cmd>TodoTxtEstimateHas<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Has (~)" })
		)
	end

	if cfg.keymaps.estimate_none then
		vim.keymap.set(
			"n",
			cfg.keymaps.estimate_none,
			"<Cmd>TodoTxtEstimateNone<CR>",
			vim.tbl_extend("force", map_opts, { desc = "None (0)" })
		)
	end

	if cfg.keymaps.estimate_max then
		vim.keymap.set(
			"n",
			cfg.keymaps.estimate_max,
			"<Cmd>TodoTxtEstimateMax<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Max ≤" })
		)
	end

	if cfg.keymaps.estimate_min then
		vim.keymap.set(
			"n",
			cfg.keymaps.estimate_min,
			"<Cmd>TodoTxtEstimateMin<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Min ≥" })
		)
	end

	if cfg.keymaps.estimate_any then
		vim.keymap.set(
			"n",
			cfg.keymaps.estimate_any,
			"<Cmd>TodoTxtEstimateAny<CR>",
			vim.tbl_extend("force", map_opts, { desc = "Any" })
		)
	end
end

return M
