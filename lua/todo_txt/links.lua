local M = {}

local api = vim.api
local fn = vim.fn
local utils = require("todo_txt.utils")

-- Patterns for different types of valid link targets
local HTTP_URL_PATTERN = "^https?://%S+$"
local FILE_URL_PATTERN = "^file://%S+$"
local ABSOLUTE_PATH_PATTERN = "^/[%w%-_%.%/]+$"
local HOME_RELATIVE_PATTERN = "^~/[%w%-_%.%/]+$"
local RELATIVE_PATH_PATTERN = "^%.?/?[^%s]+$"

-- Pattern to find "link:" tags followed by non-space characters.
local LINK_TAG_PATTERN = "link:([^%s]+)"

-- Default list of extensions considered text files (can be overridden via config)

local function is_url(link)
	return link:match(HTTP_URL_PATTERN) or link:match(FILE_URL_PATTERN)
end

local function is_text_file(file_path, cfg)
	local text_extensions = cfg.text_file_extensions
	local ext = file_path:match("%.([^%.]+)$")
	if not ext then
		return false
	end
	ext = "." .. ext:lower()
	for _, text_ext in ipairs(text_extensions) do
		if ext == text_ext then
			return true
		end
	end
	return false
end

--- Finds link targets specified with "link:<target>" on a given line.
--- Validates each target against TARGET_VALIDATION_PATTERN.
--- @param line string The line content to scan.
--- @return table valid_links A list of valid link targets found.
--- @return table invalid_targets A list of targets found after "link:" that did not validate.
function M.find_links_on_line(line)
	local valid_links = {}
	local invalid_targets = {}
	local start_pos = 1

	while true do
		local match_start, match_end, target = string.find(line, LINK_TAG_PATTERN, start_pos)
		if not match_start then
			break
		end

		-- Validate the extracted target against each pattern type
		if
			target
			and (
				target:match(HTTP_URL_PATTERN)
				or target:match(FILE_URL_PATTERN)
				or target:match(ABSOLUTE_PATH_PATTERN)
				or target:match(HOME_RELATIVE_PATTERN)
				or target:match(RELATIVE_PATH_PATTERN)
			)
		then
			table.insert(valid_links, target)
		elseif target then
			table.insert(invalid_targets, target)
		end
		start_pos = match_end + 1 -- Continue searching after the current match
	end
	return valid_links, invalid_targets
end

local function open_externally(target)
	local os_name = vim.uv.os_uname().sysname
	local command
	if os_name == "Darwin" then
		command = { "open", target }
	elseif os_name == "Linux" then
		command = { "xdg-open", target }
	elseif os_name == "Windows_NT" then
		command = { "start", "", target }
	else
		utils.notify("Unsupported OS for opening externally: " .. os_name, vim.log.levels.WARN)
		return false
	end

	local cmd_string = table.concat(command, " ")
	fn.system(cmd_string)
	utils.notify("Opened externally: " .. target, vim.log.levels.INFO)
	return true
end

local function open_link(link, cfg)
	if is_url(link) then
		open_externally(link)
	else
		local file_path = fn.expand(link)
		if fn.filereadable(file_path) == 0 then
			utils.notify("File not found or readable: " .. file_path, vim.log.levels.ERROR)
			return
		end

		if is_text_file(file_path, cfg) then
			vim.cmd("edit " .. fn.fnameescape(file_path))
		else
			open_externally(file_path)
		end
	end
end

function M.open_link_on_current_line(cfg)
	local lnum = api.nvim_win_get_cursor(0)[1]
	local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
	if not line then
		return
	end -- Handle empty buffer case

	local valid_links, invalid_targets = M.find_links_on_line(line)

	-- Notify about any invalid targets found
	if #invalid_targets > 0 then
		local invalid_msg = "Invalid link target(s) found: " .. table.concat(invalid_targets, ", ")
		utils.notify(invalid_msg, vim.log.levels.WARN)
	end

	-- Process valid links
	if #valid_links == 0 then
		-- Only notify if no valid links *and* no invalid targets were found initially
		if #invalid_targets == 0 then
			utils.notify("No valid 'link:' tags found on the current line.", vim.log.levels.INFO)
		end
	elseif #valid_links == 1 then
		open_link(valid_links[1], cfg)
	else
		vim.ui.select(
			valid_links,
			{ prompt = "Select link to open:", kind = "todo_link_select" },
			function(selected_link)
				if selected_link then
					open_link(selected_link, cfg)
				else
					utils.notify("Link selection cancelled.", vim.log.levels.INFO)
				end
			end
		)
	end
end

return M
