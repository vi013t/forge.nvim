local mason_registry = require("mason-registry")

local public = {}

function public.package_is_installed(package_name)
	for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
		if internal_name == package_name then
			return true
		end
	end
	return false
end

return public
