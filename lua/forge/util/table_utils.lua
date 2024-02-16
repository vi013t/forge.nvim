local util = require("forge.util")

-- Checks whether a list-like table contains a value.
--
-- TODO: This should just use vim's built-in vim.tbl_contains, but when I tried replacing it
-- with that, it didn't work. At some point I need to find the difference and switch to the
-- built-in function. The other functions in this file may have similar issues, I should carefully
-- review the vim api at some point and make sure I'm not reinventing the wheel here.
--
---@param value any
--
---@return boolean contained whether the table contains the value
function table:contains(value)
	for _, table_value in ipairs(self) do
		if util.equals(table_value, value) then
			return true
		end
	end
	return false
end

-- Gets the index of a value in an array.
--
---@generic T
---@param value T
--
---@return T?
function table:index_of(value)
	for index, table_value in ipairs(self) do
		if util.equals(table_value, value) then
			return index
		end
	end
	return nil
end

-- Removes the given value from an array
--
---@param to_remove any The element to remove
function table:remove_value(to_remove)
	local index_to_remove = nil
	for index, value in ipairs(self) do
		if util.equals(value, to_remove) then
			index_to_remove = index
			break
		end
	end

	if index_to_remove ~= nil then
		table.remove(self, index_to_remove)
	end
end

-- Creates a new table with the table metatable.
--
---@param values table<any, any>
---
---@return table<any, any>
function Table(values)
	return setmetatable(values, { __index = table })
end
