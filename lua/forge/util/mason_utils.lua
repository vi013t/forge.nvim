local _ = require("mason-core.functional")
local platform = require("mason-core.platform")

local mason_registry = require("mason-registry")
local registry = require("forge.tools.registry")
require("forge.tools.refresher")
local ui = require("forge.ui")

local mason_utils = {}

function mason_utils.package_is_installed(package_name)
	for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
		if internal_name == package_name then
			return true
		end
	end
	return false
end

local function join_handles(handles)
	local a = require("mason-core.async")
	local Optional = require("mason-core.optional")

	_.each(
		---@param handle InstallHandle
		function(handle)
			handle:on("stdout", vim.schedule_wrap(vim.api.nvim_out_write))
			handle:on("stderr", vim.schedule_wrap(vim.api.nvim_err_write))
		end,
		handles
	)

	a.run_blocking(function()
		a.wait_all(_.map(
			---@param handle InstallHandle
			function(handle)
				return function()
					a.wait(function(resolve)
						if handle:is_closed() then
							resolve()
						else
							handle:once("closed", resolve)
						end
					end)
				end
			end,
			handles
		))
		local failed_packages = _.filter_map(function(handle)
			if not handle.package:is_installed() then
				return Optional.of(handle.package.name)
			else
				return Optional.empty()
			end
		end, handles)

		if _.length(failed_packages) > 0 then
			a.wait(vim.schedule) -- wait for scheduler for logs to finalize
			a.wait(vim.schedule) -- logs have been written
			vim.api.nvim_err_writeln("")
			vim.api.nvim_err_writeln(("The following packages failed to install: %s"):format(_.join(", ", failed_packages)))
			vim.cmd([[1cq]])
		end
	end)
end

local filter_valid_packages = _.filter(function(pkg_specifier)
	local notify = require("mason-core.notify")
	local Package = require("mason-core.package")
	local registry = require("mason-registry")
	local package_name = Package.Parse(pkg_specifier)
	local ok = pcall(registry.get_package, package_name)
	if ok then
		return true
	else
		notify(("%q is not a valid package."):format(pkg_specifier), vim.log.levels.ERROR)
		return false
	end
end)

local function mason_install(package_specifiers, opts)
	opts = opts or {}
	local Package = require("mason-core.package")
	local local_mason_registry = require("mason-registry")

	local install_packages = _.map(function(pkg_specifier)
		local package_name, version = Package.Parse(pkg_specifier)
		local pkg = local_mason_registry.get_package(package_name)
		return pkg:install({
			version = version,
			debug = opts.debug,
			force = opts.force,
			strict = opts.strict,
			target = opts.target,
		})
	end)

	if platform.is_headless then
		local_mason_registry.refresh()
		local valid_packages = filter_valid_packages(package_specifiers)
		if #valid_packages ~= #package_specifiers then
			return vim.cmd([[1cq]])
		end
		join_handles(install_packages(valid_packages))
	end
end

---@param language Language
---@param internal_name string
---@param name string
---@param type string
function mason_utils.install_package(language, internal_name, name, type)
	print("Installing " .. internal_name .. "...")
	mason_install(internal_name)
	-- vim.cmd(("MasonInstall %s"):format(internal_name))
	-- vim.schedule(function()
	-- 	vim.cmd("bdelete")
	-- end)
	table.insert(language["installed_" .. type .. "s"], { name = name, internal_name = internal_name })

	for _, language_key in ipairs(registry.language_keys) do
		local other_language = registry.languages[language_key]
		for _, tool in ipairs(other_language["installed_" .. type .. "s"]) do
			if tool.internal_name == internal_name then
				table.insert(other_language["installed_" .. type .. "s"], { name = name, internal_name = internal_name })
				break
			end
		end
	end

	---@type integer
	local index = nil
	for line_index, ui_line in ipairs(ui.lines) do
		if ui_line.internal_name == internal_name then
			index = line_index
			break
		end
	end

	if index ~= nil then
		ui.cursor_row = index
	end
end

---@param language Language
---@param internal_name string
---@param type string
function mason_utils.uninstall_package(language, internal_name, type)
	print("Uninstalling " .. internal_name .. "...")
	vim.cmd(("MasonUninstall %s"):format(internal_name))
	vim.schedule(function()
		vim.cmd("bdelete")
	end)
	print(("%s was successfully uninstalled"):format(internal_name))

	local index = nil
	for tool_index, tool in ipairs(language["installed_" .. type .. "s"]) do
		if tool.internal_name == internal_name then
			index = tool_index
			break
		end
	end

	table.remove(language["installed_" .. type .. "s"], index)
	for _, language_key in ipairs(registry.language_keys) do
		local other_language = registry.languages[language_key]
		for tool_index, tool in ipairs(other_language["installed_" .. type .. "s"]) do
			if tool.internal_name == internal_name then
				table.remove(other_language["installed_" .. type .. "s"], tool_index)
				break
			end
		end
	end

	---@type integer
	index = nil
	for line_index, ui_line in ipairs(ui.lines) do
		if ui_line.internal_name == internal_name then
			index = line_index
			break
		end
	end

	if index ~= nil then
		ui.cursor_row = index
	end
end

function mason_utils.toggle_package(language, internal_name, name, type)
	if mason_utils.package_is_installed(internal_name) then
		mason_utils.uninstall_package(language, internal_name, type)
	else
		mason_utils.install_package(language, internal_name, name, type)
	end
end

return mason_utils
