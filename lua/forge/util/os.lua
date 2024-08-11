local public = {}

-- Gets the current operating system. Note that this returns "unix" for WSL.
--
---@return string os the operating system
function public.get_os()
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
function public.command_exists(command_name)
	if public.get_os() == "windows" then
		local exit_code = os.execute(("where %s > nul 2>&1"):format(command_name))
		return exit_code == 0
	end

	return io.popen(("command -v %s"):format(command_name)):read("*a") ~= ""
end

-- Checks if a compiler/interpreter is installed.
--
---@return boolean is_installed whether the compiler is installed
function public.language_is_installed(language)
	for _, command in ipairs(language.compilers) do
		if public.command_exists(command) then
			return true
		end
	end
	return false
end

---@class PackageManager
---@field install function

---@type table<string, PackageManager>
public.package_managers = {
	pacman = {
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
		install = function(package)
			return ("apt install %s"):format(package)
		end,
	},
	dnf = {
		install = function(package)
			return ("dnf install %s"):format(package)
		end,
	},
	brew = {
		install = function(package)
			return ("brew install %s"):format(package)
		end,
	},
	choco = {
		install = function(package)
			return ("choco install %s"):format(package)
		end,
	},
}

--- Returns the system's package manager, or nil if none are found.
---
---@return PackageManager|nil, string|nil package_manager
function public.get_package_manager()
	for package_manager, _ in pairs(public.package_managers) do
		if public.command_exists(package_manager) then
			return public.package_managers[package_manager], package_manager
		end
	end

	return nil, nil
end

--- Installs a package with the system's package manager. This will prompt the user for their password,
--- and execute the package manager's install command as root.
---
---@param package_name string
function public.install_package(language_name, package_name)
	local package_manager, package_manager_name = public.get_package_manager()

	-- If no package manager is found, print a message and return.
	-- Technically we only need to check one of these for nil,
	-- but checking both makes the LSP happy
	if package_manager == nil or package_manager_name == nil then
		print("No package manager found.")
		return
	end

	-- Get password
	local password = vim.fn.inputsecret(
		("Enter your password to install %s (%s) with %s: "):format(language_name, package_name, package_manager_name)
	)

	-- Install package
	-- NOTE: this may be be a security risk, as we are passing the password to the shell, and the password can end up
	-- stored in plain text in the shell history. We should investigate how to avoid this if possible.
	print("Installing " .. package_name .. " with " .. package_manager_name("..."))
	-- NOTE: currently this does not work with `vim.system`, which the docs say is preferred over `vim.fn.system`.
	-- In the event that `vim.fn.system` gets deprecated, we should investigate how to use `vim.system` instead.
	local output = vim.fn.system(("echo %s | sudo -S %s"):format(password, package_manager.install(package_name)))
	print(output)
	print("Installed " .. package_name .. " with " .. package_manager_name .. ".")
	-- TODO: if for some reason the package manager fails, we should print an error message.
	-- this could be due to no internet connection or something.
end

return public
