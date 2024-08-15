local registry = require("forge.tools.registry")
local config = require("forge.config")
local plugins = require("forge.tools.plugins")
local os_utils = require("forge.util.os")
local parsers = require("nvim-treesitter.parsers")
local mason_registry = require("mason-registry")

local refresher = {}

function refresher.refresh_global_tools()
	-- Refresh global tools
	for tool_id, tool in pairs(registry.global_tools) do
		local installed_subtools = 0
		for _, entry in ipairs(tool.entries) do
			local has_plugin = pcall(require, entry.module)
			entry.is_installed = has_plugin
			if has_plugin then
				installed_subtools = installed_subtools + 1
			end

			if table.contains(config.options.install.global_tools, tool_id) then
				entry.is_installed = true
				plugins.install(entry.module, entry.internal_name, entry.default_config)
			end

			if table.contains(config.options.install.global_tools[tool_id] or {}, entry.module) then
				entry.is_installed = true
				plugins.install(entry.module, entry.internal_name, entry.default_config)
			end
		end
		tool.installed_entries = installed_subtools
	end

	-- Sort tools
	registry.global_tool_keys:sort(function(first, second)
		local first_percent =
			math.floor(100 * registry.global_tools[first].installed_entries / #registry.global_tools[first].entries)
		local second_percent =
			math.floor(100 * registry.global_tools[second].installed_entries / #registry.global_tools[second].entries)

		if first_percent > second_percent then
			return true
		elseif first_percent < second_percent then
			return false
		else
			return registry.global_tools[first].name:lower() < registry.global_tools[second].name:lower()
		end
	end)
end

function refresher.refresh_installation(language)
	-- Compiler
	local installed_compilers = table_metatable({})
	for _, compiler in ipairs(language.compilers) do
		if os_utils.command_exists(compiler.internal_name) then
			installed_compilers:insert(compiler)
		end
	end
	language.installed_compilers = installed_compilers

	-- Highlighter
	local installed_highlighters = table_metatable({})
	for _, highlighter in ipairs(language.highlighters) do
		if parsers.has_parser(highlighter.internal_name) then
			installed_highlighters:insert(highlighter)
		end
	end
	language.installed_highlighters = installed_highlighters

	-- Linter
	local installed_linters = table_metatable({})
	for _, linter in ipairs(language.linters) do
		for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
			if internal_name == linter.internal_name then
				installed_linters:insert(linter)
				break
			end
		end
	end
	language.installed_linters = installed_linters

	-- Formatter
	local installed_formatters = table_metatable({})
	for _, formatter in ipairs(language.formatters) do
		for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
			if internal_name == formatter.internal_name then
				installed_formatters:insert(formatter)
				break
			end
		end
	end
	language.installed_formatters = installed_formatters

	-- Debugger
	local installed_debuggers = table_metatable({})
	for _, debugger in ipairs(language.debuggers) do
		for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
			if internal_name == debugger.internal_name then
				installed_debuggers:insert(debugger)
				break
			end
		end
	end
	language.installed_debuggers = installed_debuggers

	local installed_additional_tools = table_metatable({})
	for _, additional_tool in ipairs(language.additional_tools) do
		if additional_tool.type == "plugin" then
			local has_plugin = pcall(require, additional_tool.module)
			if has_plugin then
				installed_additional_tools:insert(additional_tool)
			end
		end
	end
	language.installed_additional_tools = installed_additional_tools
end

function refresher.refresh_installations()
	registry.generate_language_keys()

	for _, language_name in ipairs(registry.language_keys) do
		local language = registry.languages[language_name]
		refresher.refresh_installation(language)
	end

	refresher.refresh_global_tools()

	-- Get the actual number of installatinons
	for key, _ in pairs(registry.languages) do
		local language = registry.languages[key]

		language.total = 1
		if #language.compilers > 0 then
			language.total = language.total + 1
		end
		if #language.highlighters > 0 then
			language.total = language.total + 1
		end
		if #language.linters > 0 then
			language.total = language.total + 1
		end
		if #language.formatters > 0 then
			language.total = language.total + 1
		end
		if #language.debuggers > 0 then
			language.total = language.total + 1
		end

		local actual_installed = 1
		if language.installed_compilers[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_highlighters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_linters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_formatters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_debuggers[1] then
			actual_installed = actual_installed + 1
		end

		language.installed_total = actual_installed
	end

	registry.sort_languages()
end

-- Refreshes the `installed_total` field of a language to accurately reflect the number of tool types installed for it.
--
---@param language Language
--
---@return nil
function refresher.refresh_installed_totals(language)
	local actual_installed = 1
	if language.installed_compilers[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_highlighters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_linters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_formatters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_additional_tools[1] then
		actual_installed = actual_installed + 1
	end
	language.installed_total = actual_installed
end

return refresher
