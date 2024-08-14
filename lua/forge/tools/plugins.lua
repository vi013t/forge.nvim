local config = require("forge.config")
local registry = require("forge.tools.registry")
local string_utils = require("forge.util.string_utils")

--- The plugins module is a collection of functions for handling Neovim plugins that are managed by Forge. This
--- includes things like installing plugins, uninstalling plugins, getting plugin config locations, reloading
--- the Forge plugin cache, etc.
local plugins = {}

--- Returns the path of the plugin file for a plugin installed and managed by Forge. When Forge installs a plugin,
--- a configuration file for that plugin gets placed in `<NEOVIM-CONFIG>/lua/<PLUGIN-DIRECTORY>/forge/<PLUGIN>.lua`.
--- This function takes the "module name" of a plugin, and returns the path to this file.
---
--- @param module_name string The name of the main Lua module for the plugin. This is the string you would `require`
--- in your config to set up the plugin; For example, for `Noice.nvim`, you'd do `require("noice").setup({ ... })`,
--- so this paramater should be "noice".
---
--- @return string path The path to the configuration file for the given plugin.
function plugins.plugin_file(module_name)
	return ("%s/lua/%s/forge/%s.lua"):format(vim.fn.stdpath("config"), config.options.plugin_directory, module_name)
end

--- Returns the path of the Forge plugin file. Forge manages a file located at `<NEOVIM-CONFIG>/lua/<PLUGIN-DIRECTORY/forge.lua`.
--- when you install a plugin through Forge, it gets its own file created, and that file has to be `require`d somewhere
--- in the Neovim config; This happens in this file.
---
--- @return string path The path to the main Forge plugin file
function plugins.forge_plugin_file()
	return ("%s/lua/%s/forge.lua"):format(vim.fn.stdpath("config"), config.options.plugin_directory)
end

--- Checks if a plugin is installed.
---
--- @param module_name string The name of the main Lua module for the plugin. This is the string you would `require`
--- in your config to set up the plugin; For example, for `Noice.nvim`, you'd do `require("noice").setup({ ... })`,
--- so this paramater should be "noice". For VimScript plugins which dont have Lua modules, pass `true` for the
--- second parameter (`is_global_variables`), and instead of a module name, pass a global variable name for this
--- argument.
---
--- @param is_global_variable? boolean Whether the first parameter actually refers to a global variable name instead
--- of a Lua module name.
---
--- @return boolean is_installed Whether the given plugin is currently installed.
function plugins.is_installed(module_name, is_global_variable)
	if is_global_variable then
		return vim.fn.exists("g:" .. module_name) ~= 0
	else
		local is_installed = pcall(require, module_name)
		return is_installed
	end
end

--- Reloads the Forge plugin file. Forge manages a file located at `<NEOVIM-CONFIG>/lua/<PLUGIN-DIRECTORY/forge.lua`.
--- when you install a plugin through Forge, it gets its own file created, and that file has to be `require`d somewhere
--- in the Neovim config; This happens in this file. This function checks the Forge registry for all plugins installed
--- through Forge, and ensures that the Forge file is up-to-date with all installed plugins.
---
--- @return nil
function plugins.reload_forge_plugin_file()
	-- Load all "language additional tools" plugins
	local all_plugins = "return {\n"
	for _, language_key in ipairs(registry.language_keys) do
		local registry_language = registry.languages[language_key]
		for _, additional_tool in ipairs(registry_language.additional_tools) do
			-- Check if the tool is installed
			local is_installed
			for _, installed_additional_tool in ipairs(registry_language.installed_additional_tools) do
				if installed_additional_tool.internal_name == additional_tool.internal_name then
					is_installed = true
				end
			end
			if not is_installed then
				goto continue
			end

			-- If it is installed, add it to the plugins
			if additional_tool.type == "plugin" then
				all_plugins = ('%s\trequire("%s.forge.%s"),\n'):format(
					all_plugins,
					config.options.plugin_directory,
					additional_tool.module
				)
			end

			::continue::
		end
	end

	-- Load installed "global tool" plugins
	for _, global_tool in pairs(registry.global_tools) do
		for _, entry in ipairs(global_tool.entries) do
			if entry.is_installed then
				all_plugins = ('%s\trequire("%s.forge.%s"),\n'):format(
					all_plugins,
					config.options.plugin_directory,
					entry.module
				)
			end
		end
	end

	-- Write to the file
	all_plugins = all_plugins .. "}"
	local forge_file = assert(io.open(plugins.forge_plugin_file(), "w"))
	forge_file:write(all_plugins)
	forge_file:close()
end

--- Installs a plugin. By default, this will do nothing if the plugin is already installed, unless `forge_reinstall = true`.
---
--- @param module_name string The name of the plugin's Lua module. This determines the name of the plugin's config file.
---
--- @param plugin_name string The name of the plugin. This should be the name as displayed on GitHub, i.e., `userName/pluginName`,
--- for example, `folke/noice.nvim`
---
--- @param default_configuration string The plugin's "default configuration" including default `opts` and `config`, etc. This should
--- not include the plugin name itself. One example is `opts = {}, event = "InsertEnter"`.
---
--- @param force_reinstall? boolean Whether to force reinstall the plugin if it's already installed. This will wipe the plugin's
--- existing configuration and replace it with a fresh one as well.
---
--- @return nil
function plugins.install(module_name, plugin_name, default_configuration, force_reinstall)
	-- Check if it's already installed
	local is_installed = pcall(require, module_name)
	if is_installed and not force_reinstall then
		return
	end

	print("Installing " .. plugin_name .. "...")

	-- Make the forge directory if it doesn't exist
	vim.fn.mkdir(vim.fn.stdpath("config") .. "/lua/" .. config.options.plugin_directory .. "/forge", "p")

	-- Make the plugin file
	local plugin_file = assert(io.open(plugins.plugin_file(module_name), "w"))
	plugin_file:write(
		('return {\n\t"%s",\n%s\n}'):format(plugin_name, string_utils.unindent(default_configuration) or "")
	)
	-- TODO: give all plugins default config and remove the default ""
	plugins.reload_forge_plugin_file()

	print("[Forge] Plugin installed. Reload Neovim to use it.")
end

--- Uninstalls a plugin. This will do nothing if the plugin is not installed.
---
--- @param module_name string The name of the plugin's Lua module. This determines the name of the plugin's config file,
--- which needs to be known so that it can be deleted.
---
--- @param plugin_name string The name of the plugin. This should be the name as displayed on GitHub, i.e., `userName/pluginName`,
--- for example, `folke/noice.nvim`. This is used just to print an uninstallation message.
---
--- @return nil
function plugins.uninstall(module_name, plugin_name)
	-- Check if it's already not installed
	local is_installed = pcall(require, module_name)
	if not is_installed then
		return
	end
	print("Uninstalling " .. plugin_name .. "...")
	assert(os.remove(plugins.plugin_file(module_name)))
	plugins.reload_forge_plugin_file()
	print("[Forge] Plugin uninstalled. Reload Neovim to clear it.")
end

--- Installs a plugin if it's not installed already, and if it is, uninstalls it.
---
--- @param module_name string The name of the plugin's Lua module. This determines the name of the plugin's config file.
---
--- @param plugin_name string The name of the plugin. This should be the name as displayed on GitHub, i.e., `userName/pluginName`,
--- for example, `folke/noice.nvim`
---
--- @param default_configuration string The plugin's "default configuration" including default `opts` and `config`, etc. This should
--- not include the plugin name itself. One example is `opts = {}, event = "InsertEnter"`.
---
--- @return nil
function plugins.toggle_install(module_name, plugin_name, default_configuration)
	if plugins.is_installed(module_name) then
		plugins.uninstall(module_name, plugin_name)
	else
		plugins.install(module_name, plugin_name, default_configuration)
	end
end

return plugins
