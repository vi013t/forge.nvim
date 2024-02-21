local registry = require("forge.registry")
local config = require("forge.config")

local public = Table({})

public.install_chocolately =
	[[@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))]]

-- Saves the registry languages to the lockfile
--
---@return nil
function public.save()
	vim.fn.mkdir(vim.fn.fnamemodify(config.options.lockfile, ":p:h"), "p")
	local lock_file = assert(io.open(config.options.lockfile, "w"))
	lock_file:write(vim.fn.json_encode(registry.languages))
end

-- Load the lockfile if it exists, otherwise refresh the refresh_installations
--
---@return nil
function public.load()
	local lockfile = io.open(config.options.lockfile, "r")
	if lockfile then
		registry.languages = vim.fn.json_decode(lockfile:read("*a"))
		registry.generate_language_keys()
		registry.sort_languages()
	else
		registry.refresh_installations()
		public.save()
	end
end

return public
