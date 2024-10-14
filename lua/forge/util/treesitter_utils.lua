local refresher = require("forge.tools.refresher")
local treesitter_parsers = require("nvim-treesitter.parsers")

local treesitter_utils = {}

function treesitter_utils.install_highlighter(language, internal_name, name)
	vim.cmd(("TSInstall %s"):format(internal_name))
	table.insert(language.installed_highlighters, { name = name, internal_name = internal_name })
	refresher.refresh_installed_totals(language)
end

function treesitter_utils.uninstall_highlighter(language, internal_name)
	vim.cmd(("TSUninstall %s"):format(internal_name))

	local index = nil
	for linter_index, linter in ipairs(language.installed_linters) do
		if linter.internal_name == internal_name then
			index = linter_index
			break
		end
	end

	table.remove(language.installed_highlighters, index)
	refresher.refresh_installed_totals(language)
end

function treesitter_utils.toggle_highlighter(language, internal_name, name)
	if treesitter_parsers.has_parser(internal_name) then
		treesitter_utils.uninstall_highlighter(language, internal_name)
	else
		treesitter_utils.install_highlighter(language, internal_name, name)
	end
end

return treesitter_utils
