require("forge.util.table_utils")

local config = require("forge.config")
local lockfile = require("forge.lock")
local ui = require("forge.ui")
local lsp = require("forge.lsp")

local public = Table {}

-- Sets up forge.nvim with the specified configuration.
function public.setup(user_config)
	config.set_config(user_config)
	lockfile.load()
	lsp.setup_lsps()

	vim.api.nvim_create_user_command("Forge", function()
		ui.open_window()
		ui.update_view()
	end, {})
end

return public;
