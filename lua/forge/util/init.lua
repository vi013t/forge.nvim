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
---@param first any|table First object to compare
---@param second any|table Second object to compare
---@param ignore_metatable? boolean True to ignore metatables (a recursive function to tests tables inside tables)
function util.equals(first, second, ignore_metatable)
	if first == second then
		return true
	end
	local first_type = type(first)
	local second_type = type(second)
	if first_type ~= second_type then
		return false
	end
	if first_type ~= "table" then
		return false
	end

	if not ignore_metatable then
		local mt1 = getmetatable(first)
		if mt1 and mt1.__eq then
			return first == second
		end
	end

	local keySet = {}

	for key1, value1 in pairs(first) do
		local value2 = second[key1]
		if value2 == nil or util.equals(value1, value2, ignore_metatable) == false then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(second) do
		if not keySet[key2] then
			return false
		end
	end
	return true
end

return util
