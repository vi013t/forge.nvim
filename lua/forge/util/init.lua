local util = {}

-- Checks whether the given string is a hex color.
--
---@param color string The string to check
--
---@return boolean is_hex_color Whether the given string is a hex color
function util.is_hex_color(color)
	if not color then
		return false
	end
	return color:match("^#%x%x%x%x%x%x$")
end

-- Converts a string from snake_case to Title Case.
--
---@param str string The string in snake case to convert.
--
---@return string title_case The string in title case
function util.snake_case_to_title_case(str)
	local words = Table({})
	for word in str:gmatch("([^_]+)") do
		word = word:gsub("^%l", string.upper)
		words:insert(word)
	end
	return words:concat(" ")
end

-- Checks if two objects are equal, with proper checking for tables.
--
-- https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua
--
---@param o1 any|table First object to compare
---@param o2 any|table Second object to compare
---@param ignore_mt? boolean True to ignore metatables (a recursive function to tests tables inside tables)
function util.equals(o1, o2, ignore_mt)
	if o1 == o2 then
		return true
	end
	local o1Type = type(o1)
	local o2Type = type(o2)
	if o1Type ~= o2Type then
		return false
	end
	if o1Type ~= "table" then
		return false
	end

	if not ignore_mt then
		local mt1 = getmetatable(o1)
		if mt1 and mt1.__eq then
			return o1 == o2
		end
	end

	local keySet = {}

	for key1, value1 in pairs(o1) do
		local value2 = o2[key1]
		if value2 == nil or util.equals(value1, value2, ignore_mt) == false then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(o2) do
		if not keySet[key2] then
			return false
		end
	end
	return true
end

return util
