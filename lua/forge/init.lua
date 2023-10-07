local registry = require("forge.registry")
local config = require("forge.config")
local ui = require("forge.ui")

local public = {}

-- Sets up forge.nvim with the specified configuration.
function public.setup(user_config)
	if config.config.developer_mode then print("Developer mode enabled") end
	config.set_config(user_config)
	registry.refresh_installations()
	vim.api.nvim_create_user_command("Forge", function()
		ui.open_window()
		ui.update_view()
	end, {})
end

return public;
