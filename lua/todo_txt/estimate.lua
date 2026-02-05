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

function M.matches_filter(line, filter)
	local minutes = M.get_estimate(line)

	if filter == "all" then
		return true
	elseif filter == "has" then
		return minutes ~= nil
	elseif filter == "none" then
		return minutes == nil
	elseif filter == "short" then
		return minutes and minutes <= 15
	elseif filter == "medium" then
		return minutes and minutes >= 16 and minutes <= 60
	elseif filter == "long" then
		return minutes and minutes > 60 and minutes <= 240
	elseif filter == "day" then
		if not minutes then
			return false
		end
		local est_tag = line:match("~(%S+)")
		return (minutes > 240 and minutes <= 1200) or (est_tag and est_tag:match("d$"))
	elseif filter == "week" then
		if not minutes then
			return false
		end
		local est_tag = line:match("~(%S+)")
		return minutes > 1200 or (est_tag and est_tag:match("w$"))
	else
		-- Check for custom threshold filters like "<60" or ">120"
		local op, threshold = filter:match("^([<>])(%d+)$")
		if op and threshold then
			threshold = tonumber(threshold)
			if not minutes then
				return false
			end
			if op == "<" then
				return minutes <= threshold
			else -- op == ">"
				return minutes >= threshold
			end
		end
	end

	return true
end

return M

