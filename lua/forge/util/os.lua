local public = {}

---@return "windows" | "unix" operating_system The operating system of the user
function public.get_os()
	if package.config:sub(1, 1) == '\\' then return "windows" else return "unix" end
end

-- Checks if a shell command exists.
--
---@param command_name string The name of the command to check
--
---@return boolean exists Whether the command exists
function public.command_exists(command_name)
	if public.get_os() == "windows" then
		local error_level = os.execute(("where %s > nul 2>&1"):format(command_name))
		return error_level == 0
	end

	local error_level = os.execute(("command -v %s"):format(command_name))
	return error_level == 0
end

-- Checks if a compiler/interpreter is installed.
--
---@return boolean is_installed whether the compiler is installed
function public.language_is_installed(language)
	for _, command in ipairs(language.compilers) do
		if public.command_exists(command) then return true end
	end
	return false
end

return public
