local ui = require("forge.ui")
local util = require("forge.util")
local registry = require("forge.registry")
local treesitter_parsers = require("nvim-treesitter.parsers")
local lock = require("forge.lock")

local public = {}

function public.do_nothing() end

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

function public.install()
	local line = ui.lines[ui.cursor_row]

	---@type language
	local language = nil
	for _, registered_language in pairs(registry.languages) do
		if registered_language.name == line.language then
			language = registered_language
			break
		end
	end

	-- Highlighter
	if line.type == "highlighter_listing" then
		if treesitter_parsers.has_parser(language.highlighters[1].internal_name) then
			vim.cmd(("TSUninstall %s"):format(language.highlighters[1].internal_name))
		else
			vim.cmd(("TSInstall %s"):format(language.highlighters[1].internal_name))
		end

		ui.currently_installing = { language = language.name, type = "highlighters_listing" }
		ui.update_view()
	end
end

public.uninstall = public.install

-- Expands a folder under the cursor.
--
---@return nil
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

-- Moves the cursor down one row in the buffer.
--
---@return nil
function public.move_cursor_down()
	ui.cursor_row = math.min(ui.cursor_row + 1, vim.api.nvim_buf_line_count(ui.buffer))
	ui.update_view()
end

-- Moves the cursor up one row in the buffer.
--
---@return nil
function public.move_cursor_up()
	ui.cursor_row = math.max(ui.cursor_row - 1, 1)
	ui.update_view()
end

-- Moves the cursor to the top of the buffer.
--
---@return nil
function public.set_cursor_to_top()
	ui.cursor_row = 1
	ui.update_view()
end

-- Moves the cursor to the bottom of the buffer.
--
---@return nil
function public.set_cursor_to_bottom()
	ui.cursor_row = vim.api.nvim_buf_line_count(ui.buffer)
	ui.update_view()
end

-- Refreshes installations 
--
---@return nil
function public.refresh()
	ui.is_refreshing = true -- TODO: this doesn't show
	ui.update_view()
	registry.refresh_installations()
	lock.save()
	ui.is_refreshing = false
	ui.update_view()
end

return public
