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
	ui.expanded_highlighters = {}
	ui.expanded_linters = {}
	ui.expanded_formatters = {}
	ui.expanded_debuggers = {}
	ui.expanded_additional_tools = {}
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
			table.insert(ui.lines, index_of_language + 6, { type = "additional_tools", language = language_name })
		end
	else
		for _, tool in ipairs({ "compiler", "highlighter", "linter", "formatter", "debugger", "additional_tools" }) do
			if ui.lines[ui.cursor_row].type == tool then
				local plural_tool = tool .. "s"
				if tool == "additional_tools" then plural_tool = tool end

				local index_of_tool= ui.cursor_row
				local language_name = ui.lines[ui.cursor_row].language

				---@type language
				local language = nil
				for _, registry_language in pairs(registry.languages) do
					if registry_language.name == language_name then
						language = registry_language
						break
					end
				end

				if util.contains(ui["expanded_" .. plural_tool], language_name) then
					for _, _ in ipairs(language[plural_tool]) do
						table.remove(ui.lines, index_of_tool+ 1)
					end
					util.remove(ui["expanded_" .. plural_tool], language_name)
				else
					for index, language_tool in ipairs(language[plural_tool]) do
						table.insert(ui.lines, index_of_tool + index, { type = tool .. "_listing", language = language_name, name = language_tool.name })
					end
					table.insert(ui["expanded_" .. plural_tool], language_name)
				end
			end
		end
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
