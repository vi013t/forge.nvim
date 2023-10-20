local config = require("forge.config")
local lock = require("forge.lock")
local ui = require("forge.ui")

local public = {}

-- Sets up forge.nvim with the specified configuration.
function public.setup(user_config)
	config.set_config(user_config)
	lock.load()

	vim.api.nvim_create_user_command("Forge", function()
		ui.open_window()
		ui.update_view()
	end, {})
end

return public;
