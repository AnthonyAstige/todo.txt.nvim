local M = {}

local enabled = false

local function enable_myopic()
	vim.opt_local.conceallevel = 2
	-- TODO: Make this actually work ... concealcursor doesn't seem to be showing what's under it .. though everythign does hide
	vim.opt_local.concealcursor = "nvic"
	vim.cmd([[syntax match TodoTxtConceal /./ conceal]])
	enabled = true
end

local function disable_myopic()
	vim.opt_local.conceallevel = 0
	vim.opt_local.concealcursor = ""
	vim.cmd([[syntax clear TodoTxtConceal]])
	enabled = false
end

function M.toggle()
	if enabled then
		disable_myopic()
	else
		enable_myopic()
	end
end

return M
