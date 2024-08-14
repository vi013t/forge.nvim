require("forge.util.table_utils")

local config = require("forge.config")
local lockfile = require("forge.lock")
local ui = require("forge.ui")

local lsp = require("forge.setup.lsp")
local formatter = require("forge.setup.formatter")
local highlighter = require("forge.setup.highlighter")

local forge = Table({})

-- Sets up forge.nvim with the specified configuration.
function forge.setup(user_config)
	config.set_config(user_config)
	lockfile.load()

	highlighter.setup_highlighters() -- Set up treesitter
	formatter.setup_formatters() -- Set up conform.nvim
	lsp.setup_lsps() -- Set up lspconfig / mason

	vim.api.nvim_create_user_command("Forge", function()
		ui.open_window()
		ui.update_view()
	end, {})
end

return forge
