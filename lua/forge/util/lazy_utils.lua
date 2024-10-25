local registry = require("forge.tools.registry")
local plugins = require("forge.tools.plugins")
local ui = require("forge.ui")

local lazy_utils = {}

function lazy_utils.toggle_plugin(language, internal_name)
	-- Get the full tool data
	local tool
	for _, additional_tool in ipairs(language.additional_tools) do
		if additional_tool.internal_name == internal_name then
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
				break
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
		error("[Forge] Error locating plugin: " .. internal_name)
	end

	plugins.toggle_install(tool.module, tool.internal_name, tool.default_config)

	---@type integer
	local index = nil
	do
		for line_index, ui_line in ipairs(ui.lines) do
			if ui_line.internal_name == internal_name then
				index = line_index
				break
			end
		end
	end

	ui.cursor_row = index
end

function lazy_utils.install_plugin(language, internal_name)
	-- Get the full tool data
	local tool
	for _, additional_tool in ipairs(language.additional_tools) do
		if additional_tool.internal_name == internal_name then
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
				break
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
		error("[Forge] Error locating plugin: " .. internal_name)
	end

	plugins.install(tool.module, tool.internal_name, tool.default_config)

	---@type integer
	local index = nil
	do
		for line_index, ui_line in ipairs(ui.lines) do
			if ui_line.internal_name == internal_name then
				index = line_index
				break
			end
		end
	end

	ui.cursor_row = index
end

function lazy_utils.uninstall_plugin(language, internal_name)
	-- Get the full tool data
	local tool
	for _, additional_tool in ipairs(language.additional_tools) do
		if additional_tool.internal_name == internal_name then
			tool = additional_tool
		end
	end

	-- Add the additional tool to the list of installed additional tools
	for _, language_key in ipairs(registry.language_keys) do
		local registry_language = registry.languages[language_key]
		local index = nil
		for tool_index, installed_additional_tool in ipairs(registry_language.installed_additional_tools) do
			if installed_additional_tool.internal_name == tool.internal_name then
				index = tool_index
				break
			end
		end
		table.remove(registry_language.installed_additional_tools, index)
	end

	-- Tool not found
	if not tool then
		error("[Forge] Error locating plugin: " .. internal_name)
	end

	plugins.uninstall(tool.module, tool.internal_name)

	---@type integer
	local index = nil
	do
		for line_index, ui_line in ipairs(ui.lines) do
			if ui_line.internal_name == internal_name then
				index = line_index
				break
			end
		end
	end

	ui.cursor_row = index
end

return lazy_utils
