local registry = require("forge.registry")
local public = Table({})

function public.setup_formatters()
	-- Get available formatters
	local formatters_by_ft = Table({})
	for _, language_key in ipairs(registry.language_keys) do
		local language = registry.languages[language_key]
		if #language.installed_formatters > 0 then
			formatters_by_ft[language_key] = { language.installed_formatters[1].internal_name }
		end
	end

	local additional_filetypes = {
		--typescriptreact = { registry.languages.typescript.installed_formatters[1].internal_name },
		--javascriptreact = { registry.languages.javascript.installed_formatters[1].internal_name },
	}

	formatters_by_ft = vim.tbl_extend("force", formatters_by_ft, additional_filetypes)

	-- Set up formatters
	require("conform").setup({
		formatters_by_ft = formatters_by_ft,
		format_on_save = { timeout_ms = 500, lsp_fallback = true },
	})
end

return public
