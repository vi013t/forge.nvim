local ui = require("forge.ui")
local registry = require("forge.registry")
local treesitter_parsers = require("nvim-treesitter.parsers")
local lock = require("forge.lock")
local mason_utils = require("forge.util.mason_utils")

local public = Table {}

function public.do_nothing() end

-- Closes the forge buffer
function public.close_window()
	ui.expanded_languages = Table {}
	ui.expanded_compilers = Table {}
	ui.expanded_highlighters = Table {}
	ui.expanded_linters = Table {}
	ui.expanded_formatters = Table {}
	ui.expanded_debuggers = Table {}
	ui.expanded_additional_tools = Table {}
	vim.api.nvim_win_close(ui.window, true)
end

function public.toggle_install()
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
			registry.refresh_installed_totals(language)
			registry.after_refresh()
			ui.update_view()
		else
			vim.cmd(("TSInstall %s"):format(line.internal_name))
			table.insert(language.installed_linters, { name = line.name, internal_name = line.internal_name })
			registry.refresh_installed_totals(language)
			registry.after_refresh()
			ui.update_view()
		end

	-- Linter
	elseif line.type == "linter_listing" then
		if mason_utils.package_is_installed(line.internal_name) then
			print("Uninstalling " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for linter_index, linter in ipairs(language.installed_linters) do
				if linter.internal_name == line.internal_name then
					index = linter_index
					break
				end
			end

			table.remove(language.installed_linters, index)
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			table.insert(language.installed_linters, { name = line.name, internal_name = line.internal_name })
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		end

	-- Formatter
	elseif line.type == "formatter_listing" then
		if mason_utils.package_is_installed(line.internal_name) then
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for formatter_index, formatter in ipairs(language.installed_formatters) do
				if formatter.internal_name == line.internal_name then
					index = formatter_index
					break
				end
			end

			table.remove(language.installed_formatters, index)
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			table.insert(language.installed_formatters, { name = line.name, internal_name = line.internal_name })
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		end

	-- Debugger 
	elseif line.type == "debugger_listing" then
		if mason_utils.package_is_installed(line.internal_name) then
			print("Uninstalling " .. line.internal_name .. "...")
			vim.cmd(("MasonUninstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			print(("%s was successfully uninstalled"):format(line.internal_name))

			local index = nil
			for debugger_index, debugger in ipairs(language.installed_debuggers) do
				if debugger.internal_name == line.internal_name then
					index = debugger_index
					break
				end
			end

			table.remove(language.installed_debuggers, index)
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		else
			print("Installing " .. line.internal_name .. "...")
			vim.cmd(("MasonInstall %s"):format(line.internal_name))
			vim.schedule(function() vim.cmd("bdelete") end)
			table.insert(language.installed_debuggers, { name = line.name, internal_name = line.internal_name })
			registry.refresh_installed_totals(language)
			registry.after_refresh()

			---@type integer
			local index = nil
			for line_index, ui_line in ipairs(ui.lines) do
				if ui_line.internal_name == line.internal_name then
					index = line_index
					break
				end
			end

			ui.cursor_row = index
			ui.update_view()
		end
	end

	lock.save()
end

-- Expands a folder under the cursor.
--
---@return nil
function public.expand()
	if ui.lines[ui.cursor_row].type == "language" then
		local index_of_language = ui.cursor_row
		local language_name = ui.lines[ui.cursor_row].language

		if ui.expanded_languages:contains(language_name) then
			ui.expanded_languages:remove_value(language_name)
			ui.lines:remove(index_of_language + 1)
			ui.lines:remove(index_of_language + 1)
			ui.lines:remove(index_of_language + 1)
			ui.lines:remove(index_of_language + 1)
			ui.lines:remove(index_of_language + 1)
			ui.lines:remove(index_of_language + 1)
		else
			ui.expanded_languages:insert(language_name)
			ui.lines:insert(index_of_language + 1, { type = "compiler", language = language_name })
			ui.lines:insert(index_of_language + 2, { type = "highlighter", language = language_name })
			ui.lines:insert(index_of_language + 3, { type = "linter", language = language_name })
			ui.lines:insert(index_of_language + 4, { type = "formatter", language = language_name })
			ui.lines:insert(index_of_language + 5, { type = "debugger", language = language_name })
			ui.lines:insert(index_of_language + 6, { type = "additional_tools", language = language_name })
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

				if ui["expanded_" .. plural_tool]:contains(language_name) then
					for _, _ in ipairs(language[plural_tool]) do
						ui.lines:remove(index_of_tool+ 1)
					end
					ui["expanded_" .. plural_tool]:remove_value(language_name)
				else
					for index, language_tool in ipairs(language[plural_tool]) do
						ui.lines:insert(index_of_tool + index, { type = tool .. "_listing", language = language_name, name = language_tool.name, internal_name = language_tool.internal_name })
					end
					ui["expanded_" .. plural_tool]:insert(language_name)
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
	vim.schedule(function()
		registry.refresh_installations()
		lock.save()
		ui.is_refreshing = false
		ui.update_view()
		print("[forge.nvim] Refresh complete")
	end)
end

return public
