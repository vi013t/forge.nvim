require("forge.util.table_utils")

local config = require("forge.config")
local lockfile = require("forge.lock")
local ui = require("forge.ui")

local lsp = require("forge.setup.lsp")
local formatter = require("forge.setup.formatter")
local highlighter = require("forge.setup.highlighter")
local autocomplete = require("forge.setup.autocomplete")

local public = Table({})

-- Sets up forge.nvim with the specified configuration.
function public.setup(user_config)
	config.set_config(user_config)
	lockfile.load()

	highlighter.setup_highlighters()
	formatter.setup_formatters()

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			lsp.setup_lsps()
			autocomplete.setup_autocomplete()
		end,
	})

	vim.api.nvim_create_user_command("Forge", function()
		ui.open_window()
		ui.update_view()
	end, {})
end

return public
