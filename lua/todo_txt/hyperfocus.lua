local M = {}

local started_up = false
local enabled = false

local function disable_hyperfocus()
	vim.opt_local.conceallevel = 0
	vim.cmd([[syntax clear TodoTxtConceal]])
	enabled = false
end

function M.enable_hyperfocus(startup_once)
	startup_once = startup_once == nil and false or startup_once -- Default false
	if startup_once and started_up then
		return
	end
	vim.opt_local.conceallevel = 2
	vim.opt_local.concealcursor = "" -- Set concealcursor to empty to show text under cursor
	vim.cmd([[syntax match TodoTxtConceal /./ conceal]])
	enabled = true
end

function M.toggle()
	if enabled then
		disable_hyperfocus()
	else
		M.enable_hyperfocus()
	end
end

return M
