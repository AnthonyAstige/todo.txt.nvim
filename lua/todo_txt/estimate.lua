local M = {}

local function parse_estimate(tag_value)
	if not tag_value then
		return nil
	end

	-- Match number followed by unit: m, h, d, w, mo, y
	local num, suffix = tag_value:match("^(%d+)(mo?)$")
	if not num then
		num, suffix = tag_value:match("^(%d+)([hdwy])$")
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
	return parse_estimate(est_tag)
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
	end

	return true
end

return M

