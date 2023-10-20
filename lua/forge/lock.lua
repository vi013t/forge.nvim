local registry = require("forge.registry")
local config = require("forge.config")

local public = {}

public.install_chocolately = [[@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))]]

function public.save()
	vim.fn.mkdir(vim.fn.fnamemodify(config.options.lockfile, ":p:h"), "p")
	local lock_file = assert(io.open(config.options.lockfile, "w"))
	lock_file:write(vim.fn.json_encode(registry.languages))
end

function public.load()
	local lockfile = io.open(config.options.lockfile, "r")
	if lockfile then
		registry.languages = assert(vim.fn.json_decode(lockfile:read("*a")))
		registry.before_refresh()
		registry.after_refresh()
	else
		registry.refresh_installations()
		public.save()
	end
end

return public
