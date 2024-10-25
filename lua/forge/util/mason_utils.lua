local mason_registry = require("mason-registry")
local registry = require("forge.tools.registry")
local refresher = require("forge.tools.refresher")
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

---@param language Language
---@param internal_name string
---@param name string
---@param type string
function mason_utils.install_package(language, internal_name, name, type)
	print("Installing " .. internal_name .. "...")
	vim.cmd(("MasonInstall %s"):format(internal_name))
	vim.schedule(function()
		vim.cmd("bdelete")
	end)
	table.insert(language["installed_" .. type .. "s"], { name = name, internal_name = internal_name })

	for _, language_key in ipairs(registry.language_keys) do
		local other_language = registry.languages[language_key]
		for _, tool in ipairs(other_language["installed_" .. type .. "s"]) do
			if tool.internal_name == internal_name then
				table.insert(
					other_language["installed_" .. type .. "s"],
					{ name = name, internal_name = internal_name }
				)
				break
			end
		end
	end

	refresher.refresh_installed_totals(language)

	---@type integer
	local index = nil
	for line_index, ui_line in ipairs(ui.lines) do
		if ui_line.internal_name == internal_name then
			index = line_index
			break
		end
	end

	ui.cursor_row = index
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

	refresher.refresh_installed_totals(language)

	---@type integer
	index = nil
	for line_index, ui_line in ipairs(ui.lines) do
		if ui_line.internal_name == internal_name then
			index = line_index
			break
		end
	end

	ui.cursor_row = index
end

function mason_utils.toggle_package(language, internal_name, name, type)
	if mason_utils.package_is_installed(internal_name) then
		mason_utils.uninstall_package(language, internal_name, type)
	else
		mason_utils.install_package(language, internal_name, name, type)
	end
end

return mason_utils
