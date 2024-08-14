local string_utils = {}

function string_utils.unindent(text)
	-- Split the text into lines
	local lines = {}
	for text_line in text:gmatch("[^\r\n]+") do
		table.insert(lines, text_line)
	end

	-- Find the minimum leading whitespace
	local min_indent = math.huge
	for _, text_line in ipairs(lines) do
		if text_line:match("^%s*$") then
			goto continue
		end
		local indent = text_line:match("^(%s*)")
		if indent and #indent < min_indent then
			min_indent = #indent
		end
		::continue::
	end

	-- Remove the minimum leading whitespace from each line
	local result = {}
	for _, text_line in ipairs(lines) do
		if text_line:match("^%s*$") then
			table.insert(result, text_line)
			goto continue
		end
		local trimmed_line = text_line:sub(min_indent + 1)
		table.insert(result, trimmed_line)
		::continue::
	end

	-- Join the result into a single string
	return table.concat(result, "\n")
end

return string_utils
