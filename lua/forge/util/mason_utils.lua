local mason_registry = require("mason-registry")

local mason_utils = {}

function mason_utils.package_is_installed(package_name)
	for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
		if internal_name == package_name then
			return true
		end
	end
	return false
end

return mason_utils
