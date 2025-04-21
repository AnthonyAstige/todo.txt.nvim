local M = {}

local enabled = false

local function enable_myopic()
	vim.opt_local.conceallevel = 2
	vim.opt_local.concealcursor = "" -- Set concealcursor to empty to show text under cursor
	vim.cmd([[syntax match TodoTxtConceal /./ conceal]])
	enabled = true
end

local function disable_myopic()
	vim.opt_local.conceallevel = 0
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
