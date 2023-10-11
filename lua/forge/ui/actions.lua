local ui = require("forge.ui")
local util = require("forge.util")

local public = {}

-- Closes the forge buffer
function public.close_window()
	ui.expanded_languages = {}
	vim.api.nvim_win_close(ui.window, true)
end

-- Expands a folder under the cursor.
function public.expand()
	local language_name = ui.get_language_under_cursor()

	local index_of_language = nil
	for index, line in ipairs(ui.lines) do
		if line.type == "language" and line.language == language_name then
			index_of_language = index
			break
		end
	end

	if util.contains(ui.expanded_languages, language_name) then
		util.remove(ui.expanded_languages, language_name)
		table.remove(ui.lines, index_of_language + 1)
		table.remove(ui.lines, index_of_language + 1)
		table.remove(ui.lines, index_of_language + 1)
		table.remove(ui.lines, index_of_language + 1)
		table.remove(ui.lines, index_of_language + 1)
		table.remove(ui.lines, index_of_language + 1)
	else
		table.insert(ui.expanded_languages, language_name)
		table.insert(ui.lines, index_of_language + 1, { type = "compiler", language = language_name })
		table.insert(ui.lines, index_of_language + 2, { type = "highlighter", language = language_name })
		table.insert(ui.lines, index_of_language + 3, { type = "linter", language = language_name })
		table.insert(ui.lines, index_of_language + 4, { type = "formatter", language = language_name })
		table.insert(ui.lines, index_of_language + 5, { type = "debugger", language = language_name })
		table.insert(ui.lines, index_of_language + 6, { type = "additional tools", language = language_name })
	end

	ui.update_view()
end

function public.move_cursor_down()
	ui.cursor_row = math.min(ui.cursor_row + 1, vim.api.nvim_buf_line_count(ui.buffer))
	ui.update_view()
end

function public.move_cursor_up()
	ui.cursor_row = math.max(ui.cursor_row - 1, 1)
	ui.update_view()
end

return public
