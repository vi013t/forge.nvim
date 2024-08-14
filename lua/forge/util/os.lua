local os_utils = {}

-- Gets the current operating system. Note that this returns "unix" for WSL.
--
---@return string os the operating system
function os_utils.get_os()
	if package.config:sub(1, 1) == "\\" then
		return "windows"
	else
		return "unix"
	end
end

-- Checks whether a shell command can be found
--
-- PERF: make this async for better performance
--
---@param command_name string
--
---@return boolean exists whether the command can be found
function os_utils.command_exists(command_name)
	if os_utils.get_os() == "windows" then
		local exit_code = os.execute(("where %s > nul 2>&1"):format(command_name))
		return exit_code == 0
	end

	return io.popen(("command -v %s"):format(command_name)):read("*a") ~= ""
end

-- Checks if a compiler/interpreter is installed.
--
---@return boolean is_installed whether the compiler is installed
function os_utils.language_is_installed(language)
	for _, command in ipairs(language.compilers) do
		if os_utils.command_exists(command) then
			return true
		end
	end
	return false
end

---@class PackageManager
---@field install function
---@field name string

---@type table<string, PackageManager>
os_utils.package_managers = {
	pacman = {
		name = "pacman",
		install = function(package)
			-- --noconfirm: do not ask for confirmation
			-- -q: quiet, only display a little information
			-- -S: install the package
			return ("pacman --noconfirm -q -S %s"):format(package)
		end,
		uninstall = function(package)
			-- --noconfirm: do not ask for confirmation
			-- -q: quiet, only display a little information
			-- -R: remove the package
			return ("pacman --noconfirm -q -R %s"):format(package)
		end,
	},
	apt = {
		name = "apt",
		install = function(package)
			return ("apt install %s"):format(package)
		end,
	},
	dnf = {
		name = "dnf",
		install = function(package)
			return ("dnf install %s"):format(package)
		end,
	},
	brew = {
		name = "brew",
		install = function(package)
			return ("brew install %s"):format(package)
		end,
	},
	choco = {
		name = "choco",
		install = function(package)
			return ("choco install %s -y"):format(package)
		end,
		uninstall = function(package)
			return ("choco uninstall %s -y"):format(package)
		end,
	},
}

local system_package_manager = nil

--- Returns the system's package manager, or nil if none are found.
---
---@return PackageManager|nil package_manager
function os_utils.get_package_manager()
	if system_package_manager ~= nil then
		return system_package_manager
	end
	for package_manager, _ in pairs(os_utils.package_managers) do
		if os_utils.command_exists(package_manager) then
			system_package_manager = os_utils.package_managers[package_manager]
			return system_package_manager
		end
	end

	return nil
end

--- Installs a package with the system's package manager. This will prompt the user for their password,
--- and execute the package manager's install command as root.
---
---@param package_name string
function os_utils.install_package(language_name, package_name)
	local package_manager = os_utils.get_package_manager()

	-- If no package manager is found, print a message and return.
	-- Technically we only need to check one of these for nil,
	-- but checking both makes the LSP happy
	if package_manager == nil then
		print("No package manager found.")
		return
	end

	-- Install package

	print("Installing " .. package_name)

	-- Windows: Requires gsudo (or similar)
	if vim.fn.has("win32") then
		vim.fn.jobstart(("sudo %s"):format(package_manager.install(package_name)))

	-- Unix; Standard sudo command
	else
		-- NOTE: this may be be a security risk, as we are passing the password to the shell, and the password can end up
		-- stored in plain text in the shell history. We should investigate how to avoid this if possible. maybe looking
		-- at the source for vim-suda can help here... though I don't speak vimscript.

		-- NOTE: currently this does not work with `vim.system`, which the docs say is preferred over `vim.fn.system`.
		-- In the event that `vim.fn.system` gets deprecated, we should investigate how to use `vim.system` instead.
		local password = vim.fn.inputsecret(
			("Enter your password to install %s (%s) with %s: "):format(
				language_name,
				package_name,
				package_manager.name
			)
		)
		vim.fn.jobstart(("echo %s | sudo -S %s"):format(password, package_manager.install(package_name)))
	end

	print("Installed " .. package_name .. " with " .. package_manager.name .. ".")

	-- TODO: if for some reason the package manager fails, we should print an error message.
	-- this could be due to no internet connection or something.
end

return os_utils
