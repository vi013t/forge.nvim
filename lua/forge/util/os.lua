local public = {}

function public.get_os()
	if package.config:sub(1, 1) == '\\' then return "windows" else return "unix" end
end

function public.command_exists(command_name)
	if public.get_os() == "windows" then
		vim.fn.system(("where %s > nul 2>&1"):format(command_name))
		return tonumber(os.getenv("errorlevel")) == 0
	end

	return not vim.fn.system(("command -v %s"):format(command_name)):match("%s*")
end

function public.language_is_installed(language)
	for _, command in ipairs(language.compilers) do
		if public.command_exists(command) then return true end
	end
	return false
end

return public
