local ui = require("forge.ui")
local registry = require("forge.tools.registry")
local lock = require("forge.lock")
local mason_utils = require("forge.util.mason_utils")
local os_utils = require("forge.util.os")
local refresher = require("forge.tools.refresher")
local plugins = require("forge.tools.plugins")
local treesitter_utils = require("forge.util.treesitter_utils")
local lazy_utils = require("forge.util.lazy_utils")

--- The public exports of `actions.lua`
local ui_actions = table_metatable({})

function ui_actions.do_nothing() end

-- Closes the forge buffer
function ui_actions.close_window()
	ui.expanded_languages = table_metatable({})
	ui.expanded_compilers = table_metatable({})
	ui.expanded_highlighters = table_metatable({})
	ui.expanded_linters = table_metatable({})
	ui.expanded_formatters = table_metatable({})
	ui.expanded_debuggers = table_metatable({})
	ui.expanded_additional_tools = table_metatable({})
	vim.api.nvim_win_close(ui.window, true)
end

function ui_actions.toggle_install()
	local line = ui.lines[ui.cursor_row]

	---@type Language
	local language = nil
	for _, registered_language in pairs(registry.languages) do
		if registered_language.name == line.language then
			language = registered_language
			break
		end
	end

	-- Language
	if line.type == "language" then
		os_utils.install_package(language, language.compilers[1].internal_name, language.compilers[1].name)
		for _, highlighter in ipairs(language.highlighters) do
			treesitter_utils.install_highlighter(language, highlighter.internal_name, highlighter.name)
		end

		-- Compiler
	elseif line.type == "compiler_listing" then
		os_utils.toggle_package(language, line.internal_name, line.name)
		refresher.refresh_installed_totals(language)

		-- All highlighters
	elseif line.type == "highlighter" then
		for _, highlighter in ipairs(language.highlighters) do
			treesitter_utils.install_highlighter(language, highlighter.internal_name, highlighter.name)
		end

		-- Individual Highlighter
	elseif line.type == "highlighter_listing" then
		treesitter_utils.toggle_highlighter(language, line.internal_name, line.name)

		-- Linter
	elseif line.type == "linter_listing" then
		mason_utils.toggle_package(language, line.internal_name, line.name, "linter")

		-- Formatter
	elseif line.type == "formatter_listing" then
		mason_utils.toggle_package(language, line.internal_name, line.name, "formatter")

		-- Debugger
	elseif line.type == "debugger_listing" then
		mason_utils.toggle_package(language, line.internal_name, line.name, "debugger")

		-- Additional Tools
	elseif line.type == "additional_tools_listing" then
		lazy_utils.toggle_plugin(language, line.internal_name)

		-- Global Tools
	elseif line.type == "global_tool_listing" then
		line.entry.is_installed = true
		plugins.toggle_install(line.entry.module, line.entry.internal_name, line.entry.default_config)
	end

	registry.sort_languages()
	ui.reset_lines()
	ui.update_view()

	lock.save()
end

-- Expands a folder under the cursor.
--
---@return nil
function ui_actions.expand()
	-- Expanding a language
	if ui.lines[ui.cursor_row].type == "language" then
		local language_name = ui.lines[ui.cursor_row].language

		-- Collapse language
		if ui.expanded_languages:contains(language_name) then
			ui.expanded_languages:remove_value(language_name)

			-- Expand language
		else
			ui.expanded_languages:insert(language_name)
		end

		-- Global tool
	elseif ui.lines[ui.cursor_row].type == "global_tool" then
		local tool_name = ui.lines[ui.cursor_row].tool

		-- Collapse tool
		if ui.expanded_global_tools:contains(tool_name) then
			ui.expanded_global_tools:remove_value(tool_name)

			-- Expand tool
		else
			ui.expanded_global_tools:insert(tool_name)
		end

		-- Expanding a tool
	else
		for _, tool in ipairs({ "compiler", "highlighter", "linter", "formatter", "debugger", "additional_tools" }) do
			if ui.lines[ui.cursor_row].type == tool then
				local plural_tool = tool .. "s"
				if tool == "additional_tools" then
					plural_tool = tool
				end

				local language_name = ui.lines[ui.cursor_row].language

				if ui["expanded_" .. plural_tool]:contains(language_name) then
					ui["expanded_" .. plural_tool]:remove_value(language_name)
				else
					ui["expanded_" .. plural_tool]:insert(language_name)
				end
			end
		end
	end

	ui.reset_lines()
	ui.update_view()
end

-- Moves the cursor down one row in the buffer.
--
---@return nil
function ui_actions.move_cursor_down()
	ui.cursor_row = math.min(ui.cursor_row + 1, vim.api.nvim_buf_line_count(ui.buffer))
	ui.update_view()
end

-- Moves the cursor up one row in the buffer.
--
---@return nil
function ui_actions.move_cursor_up()
	ui.cursor_row = math.max(ui.cursor_row - 1, 1)
	ui.update_view()
end

-- Moves the cursor to the top of the buffer.
--
---@return nil
function ui_actions.set_cursor_to_top()
	ui.cursor_row = 1
	ui.update_view()
end

-- Moves the cursor to the bottom of the buffer.
--
---@return nil
function ui_actions.set_cursor_to_bottom()
	ui.cursor_row = vim.api.nvim_buf_line_count(ui.buffer)
	ui.update_view()
end

-- Refreshes installations
--
---@return nil
function ui_actions.refresh()
	ui.refresh_percentage = 0
	ui.update_view()
	vim.defer_fn(function()
		refresher.refresh_installations()
	end, 0)
	ui.refresh_percentage = nil
	ui.update_view()
	print("[Forge] Refresh complete.")
end

--- Configure a plugin. This is called when you press "c" while the cursor line is on an additional tool
--- of type "plugin". This will open the plugin's configuration file.
function ui_actions.configure()
	-- Additional tool configuration
	if ui.lines[ui.cursor_row].type == "additional_tools_listing" then
		local language_name = ui.lines[ui.cursor_row].language

		local language = registry.get_language_by_name(language_name)
		---@cast language Language

		local plugin
		for _, additional_tool in ipairs(language.additional_tools) do
			if additional_tool.internal_name == ui.lines[ui.cursor_row].internal_name then
				plugin = additional_tool
			end
		end

		if not plugin then
			error("Cannot find plugin: " .. ui.lines[ui.cursor_row].internal_name)
		end

		local plugin_file_path = plugins.plugin_file(plugin.module)
		ui_actions.close_window()
		vim.cmd("ex " .. plugin_file_path)

		-- Global tool configuration
	elseif ui.lines[ui.cursor_row].type == "global_tool_listing" then
		local plugin_file_path = plugins.plugin_file(ui.lines[ui.cursor_row].entry.module)
		ui_actions.close_window()
		vim.cmd("ex " .. plugin_file_path)
	end
end

return ui_actions
