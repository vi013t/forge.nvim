local ui = require("forge.ui")
local registry = require("forge.tools.registry")
local treesitter_parsers = require("nvim-treesitter.parsers")
local lock = require("forge.lock")
local mason_utils = require("forge.util.mason_utils")
local os_utils = require("forge.util.os")
local refresher = require("forge.tools.refresher")
local plugins = require("forge.tools.plugins")

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

	-- Compiler
	if line.type == "compiler_listing" then
		-- Uninstall compiler
		if os_utils.command_exists(line.internal_name) then
			-- Install compiler
		else
			local package_manager = assert(os_utils.get_package_manager())
			local name = assert(line.internal_name)
			if language.packages and language.packages[package_manager.name] then
				name = language.packages[package_manager.name]
			end

			os_utils.install_package(language.name, name)
			table.insert(language.installed_compilers, { name = line.name, internal_name = line.internal_name })
			refresher.refresh_installed_totals(language)
		end

		-- Highlighter
	elseif line.type == "highlighter_listing" then -- TODO: refactor this mess
		if treesitter_parsers.has_parser(line.internal_name) then
			vim.cmd(("TSUninstall %s"):format(line.internal_name))

			local index = nil
			for linter_index, linter in ipairs(language.installed_linters) do
				if linter.internal_name == line.internal_name then
					index = linter_index
					break
				end
			end

			table.remove(language.installed_highlighters, index)
			refresher.refresh_installed_totals(language)
		else
			vim.cmd(("TSInstall %s"):format(line.internal_name))
			table.insert(language.installed_highlighters, { name = line.name, internal_name = line.internal_name })
			refresher.refresh_installed_totals(language)
		end

		-- Linter
	elseif line.type == "linter_listing" then
		if mason_utils.package_is_installed(line.internal_name) then
			print("Uninstalling " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for linter_index, linter in ipairs(language.installed_linters) do
				if linter.internal_name == line.internal_name then
					index = linter_index
					break
				end
			end

			table.remove(language.installed_linters, index)
			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for linter_index, linter in ipairs(other_language.installed_linters) do
					if linter.internal_name == line.internal_name then
						table.remove(other_language.installed_linters, linter_index)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)
			table.insert(language.installed_linters, { name = line.name, internal_name = line.internal_name })

			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for _, linter in ipairs(other_language.installed_linters) do
					if linter.internal_name == line.internal_name then
						table.insert(
							other_language.installed_linters,
							{ name = line.name, internal_name = line.internal_name }
						)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
		end

		-- Formatter
	elseif line.type == "formatter_listing" then
		if mason_utils.package_is_installed(line.internal_name) then
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for formatter_index, formatter in ipairs(language.installed_formatters) do
				if formatter.internal_name == line.internal_name then
					index = formatter_index
					break
				end
			end

			-- Remove the formatter from the list of installed formatters
			table.remove(language.installed_formatters, index)
			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for formatter_index, formatter in ipairs(other_language.installed_formatters) do
					if formatter.internal_name == line.internal_name then
						table.remove(other_language.installed_formatters, formatter_index)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)

			-- Add the formatter to the list of installed formatters
			table.insert(language.installed_formatters, { name = line.name, internal_name = line.internal_name })
			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for _, formatter in ipairs(other_language.installed_formatters) do
					if formatter.internal_name == line.internal_name then
						table.insert(
							other_language.installed_formatters,
							{ name = line.name, internal_name = line.internal_name }
						)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
		end

		-- Debugger
	elseif line.type == "debugger_listing" then
		-- Uninstall debugger
		if mason_utils.package_is_installed(line.internal_name) then
			print("Uninstalling " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for debugger_index, debugger in ipairs(language.installed_debuggers) do
				if debugger.internal_name == line.internal_name then
					index = debugger_index
					break
				end
			end

			-- Remove the debugger from the list of installed debuggers
			table.remove(language.installed_debuggers, index)
			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for debugger_index, debugger in ipairs(other_language.installed_debuggers) do
					if debugger.internal_name == line.internal_name then
						table.remove(other_language.installed_debuggers, debugger_index)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index

			-- Install debugger
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function()
				vim.cmd("bdelete")
			end)

			-- Add the debugger to the list of installed debuggers
			table.insert(language.installed_debuggers, { name = line.name, internal_name = line.internal_name })
			for _, language_key in ipairs(registry.language_keys) do
				local other_language = registry.languages[language_key]
				for _, debugger in ipairs(other_language.installed_debuggers) do
					if debugger.internal_name == line.internal_name then
						table.insert(
							other_language.installed_debuggers,
							{ name = line.name, internal_name = line.internal_name }
						)
						break
					end
				end
			end

			refresher.refresh_installed_totals(language)

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
		end

		-- Additional Tools
	elseif line.type == "additional_tools_listing" then
		-- TODO: non plugins

		-- Get the full tool data
		local tool
		for _, additional_tool in ipairs(language.additional_tools) do
			if additional_tool.internal_name == line.internal_name then
				tool = additional_tool
			end
		end

		-- Add the additional tool to the list of installed additional tools
		for _, language_key in ipairs(registry.language_keys) do
			local registry_language = registry.languages[language_key]
			local is_installed = false
			for _, installed_additional_tool in ipairs(registry_language.installed_additional_tools) do
				if installed_additional_tool.internal_name == tool.internal_name then
					is_installed = true
				end
			end
			if not is_installed then
				table.insert(
					registry_language.installed_additional_tools,
					{ name = tool.name, internal_name = tool.internal_name }
				)
			end
		end

		-- Tool not found
		if not tool then
			error("[Forge] Error locating plugin: " .. line.internal_name)
		end

		plugins.toggle_install(tool.module, tool.internal_name, tool.default_config)

		---@type integer
		local index = nil
		do
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end
		end

		ui.cursor_row = index

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
	if ui.lines[ui.cursor_row].type == "additional_tool_listing" then
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
			return
		end

		local plugin_file_path = plugins.plugin_file(plugin.module)
		ui_actions.close_window()
		vim.cmd("ex " .. plugin_file_path)
	elseif ui.lines[ui.cursor_row].type == "global_tool_listing" then
		local plugin_file_path = plugins.plugin_file(ui.lines[ui.cursor_row].entry.module)
		ui_actions.close_window()
		vim.cmd("ex " .. plugin_file_path)
	end
end

return ui_actions
