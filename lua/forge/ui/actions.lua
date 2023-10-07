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

	if util.contains(ui.expanded_languages, language_name) then
		util.remove(ui.expanded_languages, language_name)
	else
		table.insert(ui.expanded_languages, language_name)
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
