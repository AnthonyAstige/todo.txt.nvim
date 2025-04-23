local M = {}

--- Wrapper around vim.notify that adds a default title.
-- @param msg string The message to display.
-- @param level vim.log.levels The notification level (e.g., vim.log.levels.INFO).
-- @param opts table Optional table of extra options for vim.notify.
function M.notify(msg, level, opts)
	local default_opts = { title = "todo.txt.nvim" }
	local merged_opts = vim.tbl_deep_extend("force", {}, default_opts, opts or {})
	vim.notify(msg, level, merged_opts)
end

return M
