local registry = require("forge.tools.registry")
local config = require("forge.config")
local refresher = require("forge.tools.refresher")

local lock = table_metatable({})

--- Saves the registry languages to the lockfile
---
---@return nil
function lock.save()
	vim.fn.mkdir(vim.fn.fnamemodify(config.options.lockfile, ":p:h"), "p")
	local lock_file = assert(io.open(config.options.lockfile, "w"))
	lock_file:write(vim.fn.json_encode(registry.languages))
	lock_file:close()
end

--- Load the lockfile if it exists, otherwise refresh the refresh_installations
---
---@return nil
function lock.load()
	local lockfile = io.open(config.options.lockfile, "r")

	-- Lockfile exists! Load the cache
	if lockfile then
		registry.languages = vim.fn.json_decode(lockfile:read("*a"))
		lockfile:close()
		registry.generate_language_keys()
		registry.sort_languages()
		refresher.refresh_global_tools()

	-- No lockfile - Either first load or it was deleted. Locate installations and save to a new lockfile.
	else
		refresher.refresh_installations()
		lock.save()
	end
end

return lock
