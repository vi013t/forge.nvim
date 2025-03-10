local registry = require("forge.tools.registry")
local config = require("forge.config")
local formatter = table_metatable({})

function formatter.setup_formatters()
	-- Get available formatters
	local formatters_by_ft = table_metatable({})
	for _, language_key in ipairs(registry.language_keys) do
		local language = registry.languages[language_key]
		if #language.installed_formatters > 0 then
			formatters_by_ft[language_key] = { language.installed_formatters[1].internal_name }
		end
	end

	formatters_by_ft = vim.tbl_extend("force", formatters_by_ft, {})

	-- Set up formatters
	require("conform").setup({
		formatters_by_ft = formatters_by_ft,
		format_on_save = function(bufnr)
			if vim.tbl_contains(config.options.autoformat.ignore, vim.bo[bufnr].filetype) then
				return
			end

			return { timeout_ms = 500, lsp_fallback = true }
		end
	})
end

return formatter
