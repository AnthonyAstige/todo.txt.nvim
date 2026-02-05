local M = {}

-- Parse an estimate string like "5m", "2h", "3d" into minutes
-- Exported for use in commands.lua
function M.parse_estimate_string(str)
	if not str or str == "" then
		return nil
	end

	-- Match number followed by unit: m, h, d, w, mo, y
	local num, suffix = str:match("^(%d+)(mo?)$")
	if not num then
		num, suffix = str:match("^(%d+)([hdwy])$")
	end
	if not num then
		return nil
	end

	num = tonumber(num)
	if not num or num <= 0 then
		return nil
	end

	if suffix == "m" then
		return num
	elseif suffix == "h" then
		return num * 60
	elseif suffix == "d" then
		return num * 240
	elseif suffix == "w" then
		return num * 1200
	elseif suffix == "mo" then
		return num * 4800
	elseif suffix == "y" then
		return num * 57600
	end

	return nil
end

function M.get_estimate(line)
	local est_tag = line:match("~(%S+)")
	return M.parse_estimate_string(est_tag)
end

-- Parse filter string into min/max bounds
-- Returns: filter_type ("all", "has", "none", "range"), min, max
function M.parse_filter(filter)
	if not filter or filter == "all" then
		return "all", nil, nil
	elseif filter == "has" then
		return "has", nil, nil
	elseif filter == "none" then
		return "none", nil, nil
	else
		-- Parse range format: "MIN-MAX", "MIN-", "-MAX"
		local min_str, max_str = filter:match("^(%d*)-(%d*)$")
		if min_str ~= nil then
			local min = min_str ~= "" and tonumber(min_str) or nil
			local max = max_str ~= "" and tonumber(max_str) or nil
			return "range", min, max
		end
	end
	return "all", nil, nil
end

-- Build filter string from min/max bounds
function M.build_filter(min, max)
	if not min and not max then
		return "all"
	end
	local min_str = min and tostring(min) or ""
	local max_str = max and tostring(max) or ""
	return min_str .. "-" .. max_str
end

-- Get current min/max bounds from filter
function M.get_bounds()
	local filter = vim.g.todo_txt_estimate_filter or "all"
	local filter_type, min, max = M.parse_filter(filter)
	if filter_type == "range" then
		return min, max
	end
	return nil, nil
end

-- Set min bound, preserving existing max
function M.set_min_bound(min)
	local _, max = M.get_bounds()
	vim.g.todo_txt_estimate_filter = M.build_filter(min, max)
end

-- Set max bound, preserving existing min
function M.set_max_bound(max)
	local min, _ = M.get_bounds()
	vim.g.todo_txt_estimate_filter = M.build_filter(min, max)
end

function M.matches_filter(line, filter)
	local minutes = M.get_estimate(line)
	local filter_type, min, max = M.parse_filter(filter)

	if filter_type == "all" then
		return true
	elseif filter_type == "has" then
		return minutes ~= nil
	elseif filter_type == "none" then
		return minutes == nil
	elseif filter_type == "range" then
		if not minutes then
			return false
		end
		if min and minutes < min then
			return false
		end
		if max and minutes > max then
			return false
		end
		return true
	end

	return true
end

-- Format minutes as human-readable string
function M.format_minutes(minutes)
	if not minutes then
		return nil
	end
	if minutes >= 57600 then
		return string.format("%dy", minutes / 57600)
	elseif minutes >= 4800 then
		return string.format("%dmo", minutes / 4800)
	elseif minutes >= 1200 then
		return string.format("%dw", minutes / 1200)
	elseif minutes >= 240 then
		return string.format("%dd", minutes / 240)
	elseif minutes >= 60 then
		return string.format("%dh", minutes / 60)
	else
		return string.format("%dm", minutes)
	end
end

return M
