local ui = require("forge.ui")
local util = require("forge.util")
local registry = require("forge.registry")

local public = {
	mappings = {
		q = "close_window",
		e = "expand",
		j = "move_cursor_down",
		k = "move_cursor_up",
		gg = "set_cursor_to_top",
		G = "set_cursor_to_bottom",
		["<Up>"] = "move_cursor_up",
		["<Down>"] = "move_cursor_down"
	}
}

-- Closes the forge buffer
function public.close_window()
	ui.expanded_languages = {}
	ui.expanded_compilers = {}
	vim.api.nvim_win_close(ui.window, true)
end

-- Expands a folder under the cursor.
function public.expand()
	if ui.lines[ui.cursor_row].type == "language" then
		local index_of_language = ui.cursor_row
		local language_name = ui.lines[ui.cursor_row].language

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
	elseif ui.lines[ui.cursor_row].type == "compiler" then
		local index_of_compiler = ui.cursor_row
		local language_name = ui.lines[ui.cursor_row].language

		---@type language
		local language = nil
		for _, registry_language in pairs(registry.languages) do
			if registry_language.name == language_name then
				language = registry_language
				break
			end
		end

		for index, compiler in ipairs(language.compilers) do
			table.insert(ui.lines, index_of_compiler + index, { type = "compiler_listing", language = language_name, name = compiler.name })
		end

		table.insert(ui.expanded_compilers, language_name)
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

function public.set_cursor_to_top()
	ui.cursor_row = 1
	ui.update_view()
end

function public.set_cursor_to_bottom()
	ui.cursor_row = vim.api.nvim_buf_line_count(ui.buffer)
	ui.update_view()
end

return public
